import Combine
import SwiftUI

private let qrSize: CGFloat = 203
private let appIconSize: CGFloat = 47

struct ReceiveAddressView: View {
    @StateObject var viewModel: ReceiveAddressViewModel
    var onDismiss: (() -> Void)?

    @State private var hasAppeared = false
    @State private var warningAlertPopup: ReceiveAddressModule.PopupWarningItem?

    @State private var shareText: String?
    @State private var inputAmountPresented: Bool = false

    @Environment(\.presentationMode) private var presentationMode

    init(cexAsset: CexAsset, network: CexDepositNetwork?, provider: ICexDepositProvider) {
        _viewModel = StateObject(wrappedValue: ReceiveAddressViewModel.instance(
            cexAsset: cexAsset, network: network, provider: provider
        )
        )
    }

    init(wallet: Wallet, onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss

        _viewModel = StateObject(wrappedValue: ReceiveAddressViewModel.instance(wallet: wallet))
    }

    var body: some View {
        ScrollableThemeView {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case let .completed(viewItem):
                VStack(spacing: .margin12) {
                    if let description = viewItem.highlightedDescription {
                        HighlightedTextView(text: description.text, style: description.style)
                    }

                    ListSection {
                        qrView(item: viewItem.qrItem)
                        if let amount = viewItem.amount {
                            view(amount: amount)
                        }
                        if !viewItem.active {
                            notActive()
                        }
                        if let memo = viewItem.memo {
                            view(memo: memo)
                        }

                        if let usedAddresses = viewItem.usedAddresses, !usedAddresses.isEmpty {
                            NavigationRow(destination: {
                                UsedAddressesView(
                                    coinName: viewModel.coinName,
                                    usedAddresses: usedAddresses,
                                    onDismiss: onDismiss ?? { presentationMode.wrappedValue.dismiss() }
                                )
                            }) {
                                Text("deposit.used_addresses".localized).themeSubhead2()
                                Image.disclosureIcon
                            }
                        }
                    }
                }
                .padding(EdgeInsets(top: .margin12, leading: .margin16, bottom: .margin32, trailing: .margin16))

                Spacer().frame(height: 52)

                LazyVGrid(columns: viewModel.actions.map { _ in GridItem(.flexible(), alignment: .top) }, spacing: .margin16) {
                    ForEach(viewModel.actions, id: \.self) { action in
                        actionView(type: action)
                    }
                }
                .padding(.horizontal, .margin48)

                Spacer()
            case .failed:
                PlaceholderViewNew(image: Image("sync_error_48"), text: "sync_error".localized)
            }
        }
        .onChange(of: viewModel.popup) {
            guard hasAppeared else { return }
            warningAlertPopup = $0
        }
        .sheet(item: $shareText) { shareText in
            ActivityView.view(activityItems: [shareText])
        }
        .textFieldAlert(
            isPresented: $inputAmountPresented,
            amountChanged: viewModel.onAmountChanged(_:),
            content: {
                TextFieldAlert(
                    title: "deposit.enter_amount".localized,
                    message: nil,
                    initial: viewModel.initialText
                )
            }
        )
        .alertButtonTint(color: .themeJacob)
        .bottomSheet(item: $warningAlertPopup) { popup in
            BottomSheetView(
                icon: .warning,
                title: popup.title,
                items: [
                    .highlightedDescription(text: popup.description.text, style: popup.description.style),
                ],
                buttons: [
                    .init(style: .yellow, title: popup.doneButtonTitle) { warningAlertPopup = nil },
                ],
                onDismiss: { warningAlertPopup = nil }
            )
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true

            viewModel.onFirstAppear()
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("button.done".localized) {
                    if let onDismiss {
                        onDismiss()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .accentColor(.themeJacob)
    }

    @ViewBuilder private func qrView(item: ReceiveAddressModule.QrItem) -> some View {
        VStack(spacing: .margin24) {
            if let uiImage = UIImage.qrCodeImage(qrCodeString: item.uri ?? item.address, size: qrSize) {
                ZStack {
                    Image(uiImage: uiImage)
                        .frame(width: qrSize, height: qrSize)
                        .padding(.margin2)
                        .background(Color.white)

                    Image(AppIcon.main.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: appIconSize, height: appIconSize)
                        .padding(.margin8)
                        .background(Color.white)
                }
            }

            VStack(spacing: .margin12) {
                Text(item.address)
                    .textSubhead2(color: .themeLeah)
                    .multilineTextAlignment(.center)

                if let networkName = item.networkName {
                    Text(networkName)
                        .textSubhead2()
                        .multilineTextAlignment(.center)
                }
            }
        }
        .gesture(
            TapGesture()
                .onEnded {
                    handle(action: .copy)
                }
        )
        .padding(EdgeInsets(top: .margin24, leading: .margin32, bottom: .margin24, trailing: .margin32))
    }

    @ViewBuilder private func actionView(type: ReceiveAddressModule.ActionType) -> some View {
        VStack(spacing: .margin8) {
            Button(action: {
                handle(action: type)
            }) {
                Image(type.icon).renderingMode(.template)
            }
            .buttonStyle(PrimaryCircleButtonStyle(style: .gray))

            Text(type.title).textSubhead1()
        }
    }

    private func handle(action: ReceiveAddressModule.ActionType) {
        guard let data = viewModel.state.data else {
            return
        }
        switch action {
        case .amount:
            inputAmountPresented = true
        case .share:
            shareText = data.copyValue
            stat(page: .receive, event: .share(entity: .receiveAddress))
        case .copy:
            CopyHelper.copyAndNotify(value: data.copyValue)
            stat(page: .receive, event: .copy(entity: .receiveAddress))
        }
    }

    @ViewBuilder func view(amount: String) -> some View {
        ListRow {
            Text("deposit.amount".localized).textSubhead2()
            Spacer()
            Text(amount).textSubhead1(color: .themeLeah)
            Button(action: {
                viewModel.set(amount: "")
                stat(page: .receive, event: .removeAmount)
            }, label: {
                Image("trash_20").renderingMode(.template)
            })
            .buttonStyle(SecondaryCircleButtonStyle(style: .default))
        }
    }

    @ViewBuilder func notActive() -> some View {
        ListRow {
            Text("deposit.account".localized)
                .textSubhead2()
                .modifier(
                    Informed(infoDescription: .init(
                        title: "deposit.not_active.title".localized,
                        description: "deposit.not_active.tron_description".localized
                    )))
            Spacer()
            Text("deposit.not_active".localized).textSubhead1(color: .themeYellow)
        }
    }

    @ViewBuilder func view(memo: String) -> some View {
        ListRow {
            Text("cex_deposit.memo".localized)
                .textSubhead2()
                .modifier(
                    Informed(infoDescription: .init(
                        title: "cex_deposit.memo_warning.title".localized,
                        description: "cex_deposit.memo_warning.description".localized
                    )))
            Spacer()
            Text(memo).textSubhead1(color: .themeLeah)
            Button(action: {
                CopyHelper.copyAndNotify(value: memo)
            }, label: {
                Image("copy_20").renderingMode(.template)
            })
            .buttonStyle(SecondaryCircleButtonStyle(style: .default))
        }
    }
}
