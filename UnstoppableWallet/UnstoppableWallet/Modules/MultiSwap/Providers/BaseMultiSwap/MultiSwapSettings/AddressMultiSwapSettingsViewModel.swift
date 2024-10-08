import Combine
import Foundation
import MarketKit
import UIKit

class AddressMultiSwapSettingsViewModel: ObservableObject, IMultiSwapSettingsField {
    var storage: MultiSwapSettingStorage
    let blockchainType: BlockchainType

    var syncSubject = PassthroughSubject<Void, Never>()

    @Published var addressResult: AddressInput.Result = .idle {
        didSet {
            syncAddressCautionState()
            syncSubject.send()
        }
    }

    @Published var isAddressActive: Bool = false {
        didSet {
            if isAddressActive {
                addressCautionState = .none
            } else {
                syncAddressCautionState()
            }
        }
    }

    @Published var addressCautionState: CautionState = .none
    @Published var address: String = ""

    init(storage: MultiSwapSettingStorage, blockchainType: BlockchainType) {
        self.storage = storage
        self.blockchainType = blockchainType

        if let initialAddress {
            address = initialAddress.title
            addressResult = .valid(.init(address: initialAddress, uri: nil))
        }
    }

    private func syncAddressCautionState() {
        switch addressResult {
        case let .invalid(failure):
            if let error = failure.error as? AddressParserChain.ParserError {
                switch error {
                case .validationError:
                    addressCautionState = isAddressActive ? .none : .caution(.init(text: failure.error.localizedDescription, type: .error))
                case .fetchError:
                    addressCautionState = .caution(.init(text: failure.error.localizedDescription, type: .error))
                }
            }
        default: addressCautionState = .none
        }
    }

    var state: BaseMultiSwapSettingsViewModel.FieldState {
        MultiSwapAddress.state(initial: initialAddress?.title, value: addressResult)
    }

    func onReset() {
        address = ""
    }

    func onDone() {
        let address: Address?
        switch addressResult {
        case let .valid(success):
            address = success.address
        default: address = nil
        }

        storage.set(recipient: address, blockchainType: blockchainType)
    }

    func changeAddressFocus(active: Bool) {
        isAddressActive = active
    }
}

extension AddressMultiSwapSettingsViewModel {
    var syncPublisher: AnyPublisher<Void, Never> {
        syncSubject.eraseToAnyPublisher()
    }

    var initialAddress: Address? {
        if let address = storage.recipient(blockchainType: blockchainType) {
            return address
        }
        return nil
    }
}

enum MultiSwapAddress {
    static let `default`: String = ""

    static func state(initial: String?, value: AddressInput.Result) -> BaseMultiSwapSettingsViewModel.FieldState {
        let initial = initial ?? `default`

        var valid = false
        var done = false

        let reset = value.text.lowercased() != MultiSwapAddress.default
        switch value {
        case .idle:
            valid = true
            done = !initial.isEmpty
        case let .valid(address):
            valid = true
            done = address.address.title.lowercased() != initial.lowercased()
        default: ()
        }

        return .init(valid: valid, changed: done, resetEnabled: reset)
    }
}
