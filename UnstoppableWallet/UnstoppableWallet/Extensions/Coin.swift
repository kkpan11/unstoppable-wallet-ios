import MarketKit
import UIKit

extension Coin {
    var imageUrl: String {
        let scale = Int(UIScreen.main.scale)
        return "https://cdn.blocksdecoded.com/coin-icons/32px/\(uid)@\(scale)x.png"
    }

    static func imageUrl(uid: String) -> String {
        let scale = Int(UIScreen.main.scale)
        return "https://cdn.blocksdecoded.com/coin-icons/32px/\(uid)@\(scale)x.png"
    }
}

extension Coin: Identifiable {
    public var id: String { uid }
}
