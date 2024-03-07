import Kingfisher
import MarketKit
import SwiftUI

struct MultiSwapConfirmationView: View {
    @StateObject var viewModel: MultiSwapConfirmationViewModel
    @Binding var swapPresentationMode: PresentationMode

    @State private var feeSettingsPresented = false

    var body: some View {
        ThemeView {
            if viewModel.quoting {
                VStack(spacing: .margin12) {
                    ProgressView()
                    Text("Quoting...").textSubhead2()
                }
            } else if let quote = viewModel.quote {
                quoteView(quote: quote)
            }
        }
        .sheet(isPresented: $feeSettingsPresented) {
            viewModel.transactionService.settingsView(
                feeData: Binding<FeeData?>(get: { viewModel.quote?.feeData }, set: { _ in }),
                loading: $viewModel.quoting,
                feeToken: viewModel.feeToken,
                currency: viewModel.currency,
                feeTokenRate: $viewModel.feeTokenRate
            )
        }
        .navigationTitle("Confirm")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    feeSettingsPresented = true
                }) {
                    Image("manage_2_20").renderingMode(.template)
                }
                .disabled(viewModel.quoting)
            }
        }
        .onReceive(viewModel.finishSubject) {
            swapPresentationMode.dismiss()
        }
    }

    @ViewBuilder private func quoteView(quote: IMultiSwapConfirmationQuote) -> some View {
        VStack {
            ScrollView {
                VStack(spacing: .margin16) {
                    ListSection {
                        tokenRow(title: "You Send", token: viewModel.tokenIn, amount: viewModel.amountIn, rate: viewModel.rateIn)
                        tokenRow(title: "You Get", token: viewModel.tokenOut, amount: quote.amountOut, rate: viewModel.rateOut)
                    }

                    let priceSectionFields = quote.priceSectionFields(
                        tokenIn: viewModel.tokenIn,
                        tokenOut: viewModel.tokenOut,
                        feeToken: viewModel.feeToken,
                        currency: viewModel.currency,
                        tokenInRate: viewModel.rateIn,
                        tokenOutRate: viewModel.rateOut,
                        feeTokenRate: viewModel.feeTokenRate
                    )

                    if viewModel.price != nil || !priceSectionFields.isEmpty {
                        ListSection {
                            if let price = viewModel.price {
                                ListRow {
                                    Text("Price").textSubhead2()

                                    Spacer()

                                    Button(action: {
                                        viewModel.flipPrice()
                                    }) {
                                        HStack(spacing: .margin8) {
                                            Text(price)
                                                .textSubhead1(color: .themeLeah)
                                                .multilineTextAlignment(.trailing)

                                            Image("arrow_swap_3_20").themeIcon()
                                        }
                                    }
                                }
                            }

                            if !priceSectionFields.isEmpty {
                                ForEach(priceSectionFields.indices, id: \.self) { index in
                                    fieldRow(field: priceSectionFields[index])
                                }
                            }
                        }
                    }

                    let otherSections = quote.otherSections(
                        tokenIn: viewModel.tokenIn,
                        tokenOut: viewModel.tokenOut,
                        feeToken: viewModel.feeToken,
                        currency: viewModel.currency,
                        tokenInRate: viewModel.rateIn,
                        tokenOutRate: viewModel.rateOut,
                        feeTokenRate: viewModel.feeTokenRate
                    )

                    if !otherSections.isEmpty {
                        ForEach(otherSections.indices, id: \.self) { sectionIndex in
                            let section = otherSections[sectionIndex]

                            if !section.isEmpty {
                                ListSection {
                                    ForEach(section.indices, id: \.self) { index in
                                        fieldRow(field: section[index])
                                    }
                                }
                            }
                        }
                    }

                    let cautions = viewModel.transactionService.cautions + quote.cautions(feeToken: viewModel.feeToken)

                    if !cautions.isEmpty {
                        VStack(spacing: .margin12) {
                            ForEach(cautions.indices, id: \.self) { index in
                                HighlightedTextView(caution: cautions[index])
                            }
                        }
                    }
                }
                .padding(EdgeInsets(top: .margin12, leading: .margin16, bottom: .margin32, trailing: .margin16))
            }

            Button(action: {
                if viewModel.quoteTimeLeft > 0 {
                    viewModel.swap()
                } else {
                    viewModel.syncQuote()
                }
            }) {
                HStack(spacing: .margin8) {
                    if viewModel.swapping {
                        ProgressView()
                    }

                    Text(viewModel.quoteTimeLeft > 0 ? (viewModel.swapping ? "Swapping" : "Swap") : "Refresh")
                }
            }
            .disabled(viewModel.swapping)
            .buttonStyle(PrimaryButtonStyle(style: viewModel.quoteTimeLeft > 0 ? .yellow : .gray))
            .padding(.vertical, .margin16)
            .padding(.horizontal, .margin16)

            Text(bottomText())
                .textSubhead1()
                .padding(.bottom, .margin8)
        }
    }

    @ViewBuilder private func tokenRow(title: String, token: Token, amount: Decimal, rate: Decimal?) -> some View {
        ListRow {
            KFImage.url(URL(string: token.coin.imageUrl))
                .resizable()
                .placeholder {
                    Circle().fill(Color.themeSteel20)
                }
                .clipShape(Circle())
                .frame(width: .iconSize24, height: .iconSize24)

            VStack(spacing: 1) {
                HStack(spacing: .margin4) {
                    Text(title).textSubhead2(color: .themeLeah)

                    Spacer()

                    if let formatted = ValueFormatter.instance.formatFull(coinValue: CoinValue(kind: .token(token: token), value: amount)) {
                        Text(formatted).textSubhead1(color: .themeLeah)
                    }
                }

                HStack(spacing: .margin4) {
                    Text((token.protocolName ?? "coin_platforms.native".localized).uppercased()).textCaption()

                    Spacer()

                    if let rate, let formatted = ValueFormatter.instance.formatFull(currency: viewModel.currency, value: amount * rate) {
                        Text(formatted).textCaption()
                    }
                }
            }
        }
    }

    @ViewBuilder private func fieldRow(field: MultiSwapConfirmField) -> some View {
        switch field {
        case let .value(title, description, coinValue, currencyValue):
            ListRow(padding: EdgeInsets(top: .margin12, leading: description == nil ? .margin16 : 0, bottom: .margin12, trailing: .margin16)) {
                if let description {
                    Text(title)
                        .textSubhead2()
                        .modifier(Informed(description: description))
                } else {
                    Text(title)
                        .textSubhead2()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 1) {
                    if let coinValue, let formatted = ValueFormatter.instance.formatShort(coinValue: coinValue) {
                        Text(formatted)
                            .textSubhead1(color: .themeLeah)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text("n/a".localized)
                            .textSubhead1()
                            .multilineTextAlignment(.trailing)
                    }

                    if let currencyValue, let formatted = ValueFormatter.instance.formatShort(currencyValue: currencyValue) {
                        Text(formatted)
                            .textCaption()
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        case let .levelValue(title, value, level):
            ListRow {
                Text(title).textSubhead2()
                Spacer()
                Text(value).textSubhead1(color: color(valueLevel: level))
            }
        case let .address(title, value):
            ListRow {
                Text(title).textSubhead2()

                Spacer()

                Text(value)
                    .textSubhead1(color: .themeLeah)
                    .multilineTextAlignment(.trailing)

                Button(action: {
                    CopyHelper.copyAndNotify(value: value)
                }) {
                    Image("copy_20").renderingMode(.template)
                }
                .buttonStyle(SecondaryCircleButtonStyle(style: .default))
            }
        }
    }

    private func bottomText() -> String {
        if let quote = viewModel.quote, !quote.canSwap {
            return "Invalid Quote"
        } else if viewModel.swapping {
            return "Please wait"
        } else if viewModel.quoteTimeLeft > 0 {
            return "Quote expires in \(viewModel.quoteTimeLeft)"
        } else {
            return "Quote expired"
        }
    }

    private func color(valueLevel: MultiSwapValueLevel) -> Color {
        switch valueLevel {
        case .regular: return .themeLeah
        case .notAvailable: return .themeGray50
        case .warning: return .themeJacob
        case .error: return .themeLucian
        }
    }
}