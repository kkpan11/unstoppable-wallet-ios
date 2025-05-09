import BigInt
import Foundation
import HsExtensions
import MarketKit

class CexCoinService {
    let cexAsset: CexAsset
    private let currencyManager: CurrencyManager
    private let marketKit: MarketKit.Kit

    init(cexAsset: CexAsset, currencyManager: CurrencyManager, marketKit: MarketKit.Kit) {
        self.cexAsset = cexAsset
        self.currencyManager = currencyManager
        self.marketKit = marketKit
    }
}

extension CexCoinService: ICoinService {
    var rate: CurrencyValue? {
        guard let coin = cexAsset.coin else {
            return nil
        }

        let baseCurrency = currencyManager.baseCurrency

        return marketKit.coinPrice(coinUid: coin.uid, currencyCode: baseCurrency.code).map { coinPrice in
            CurrencyValue(currency: baseCurrency, value: coinPrice.value)
        }
    }

    func appValue(value: BigUInt) -> AppValue {
        let decimalValue = Decimal(bigUInt: value, decimals: CexAsset.decimals) ?? 0
        return appValue(value: decimalValue)
    }

    func appValue(value: Decimal) -> AppValue {
        AppValue(cexAsset: cexAsset, value: value)
    }

    // Example: Dollar, Bitcoin, Ether, etc
    func monetaryValue(value: BigUInt) -> Decimal {
        appValue(value: value).value
    }

    // Example: Cent, Satoshi, GWei, etc
    func fractionalMonetaryValue(value: Decimal) -> BigUInt {
        BigUInt(value.hs.roundedString(decimal: CexAsset.decimals)) ?? 0
    }

    func amountData(value: Decimal, sign: FloatingPointSign) -> AmountData {
        AmountData(
            appValue: appValue(value: Decimal(sign: sign, exponent: value.exponent, significand: value.significand)),
            currencyValue: rate.map {
                CurrencyValue(currency: $0.currency, value: $0.value * value)
            }
        )
    }

    func amountData(value: BigUInt, sign: FloatingPointSign = .plus) -> AmountData {
        amountData(value: Decimal(bigUInt: value, decimals: CexAsset.decimals) ?? 0, sign: sign)
    }
}
