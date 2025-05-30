import Foundation
import MarketKit
import TronKit

class TronExternalContractCallTransactionRecord: TronTransactionRecord {
    let incomingEvents: [TransferEvent]
    let outgoingEvents: [TransferEvent]

    init(source: TransactionSource, transaction: Transaction, baseToken: Token, incomingEvents: [TransferEvent], outgoingEvents: [TransferEvent]) {
        self.incomingEvents = incomingEvents
        self.outgoingEvents = outgoingEvents

        let spam = SpamAddressManager.isSpam(appValues: (incomingEvents + outgoingEvents).map(\.value))

        super.init(source: source, transaction: transaction, baseToken: baseToken, ownTransaction: false, spam: spam)
    }

    var combinedValues: ([AppValue], [AppValue]) {
        combined(incomingEvents: incomingEvents, outgoingEvents: outgoingEvents)
    }

    override var mainValue: AppValue? {
        let (incomingValues, outgoingValues) = combinedValues

        if incomingValues.count == 1, outgoingValues.isEmpty {
            return incomingValues[0]
        } else if incomingValues.isEmpty, outgoingValues.count == 1 {
            return outgoingValues[0]
        } else {
            return nil
        }
    }
}
