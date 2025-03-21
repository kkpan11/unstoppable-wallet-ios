import Foundation
import MarketKit

class BitcoinOutgoingTransactionRecord: BitcoinTransactionRecord {
    let value: AppValue
    let to: String?
    let sentToSelf: Bool
    let replaceable: Bool

    init(token: Token, source: TransactionSource, uid: String, transactionHash: String, transactionIndex: Int, blockHeight: Int?, confirmationsThreshold: Int?, date: Date, fee: Decimal?, failed: Bool,
         lockInfo: TransactionLockInfo?, conflictingHash: String?, showRawTransaction: Bool,
         amount: Decimal, to: String?, sentToSelf: Bool, memo: String? = nil, replaceable: Bool)
    {
        value = AppValue(token: token, value: Decimal(sign: .minus, exponent: amount.exponent, significand: amount.significand))
        self.to = to
        self.sentToSelf = sentToSelf
        self.replaceable = replaceable

        super.init(
            source: source,
            uid: uid,
            transactionHash: transactionHash,
            transactionIndex: transactionIndex,
            blockHeight: blockHeight,
            confirmationsThreshold: confirmationsThreshold,
            date: date,
            fee: fee.flatMap { AppValue(token: token, value: $0) },
            failed: failed,
            lockInfo: lockInfo,
            conflictingHash: conflictingHash,
            showRawTransaction: showRawTransaction,
            memo: memo
        )
    }

    override var mainValue: AppValue? {
        value
    }
}
