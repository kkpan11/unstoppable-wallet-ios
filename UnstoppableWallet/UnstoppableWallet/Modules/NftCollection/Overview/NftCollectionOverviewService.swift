import RxSwift
import RxRelay

class NftCollectionOverviewService {
    private let collection: NftCollection
    private let provider: HsNftProvider
    private var disposeBag = DisposeBag()

    private let stateRelay = PublishRelay<DataStatus<Item>>()
    private(set) var state: DataStatus<Item> = .loading {
        didSet {
            stateRelay.accept(state)
        }
    }

    init(collection: NftCollection, provider: HsNftProvider) {
        self.collection = collection
        self.provider = provider

        sync()
    }

    private func sync() {
        disposeBag = DisposeBag()

        state = .loading

        provider.collectionSingle(uid: collection.uid)
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
                .subscribe(onSuccess: { [weak self] collection in
                    let item = Item(collection: collection)
                    self?.state = .completed(item)
                }, onError: { [weak self] error in
                    self?.state = .failed(error)
                })
                .disposed(by: disposeBag)
    }

}

extension NftCollectionOverviewService {

    var stateObservable: Observable<DataStatus<Item>> {
        stateRelay.asObservable()
    }

    func resync() {
        sync()
    }

}

extension NftCollectionOverviewService {

    struct Item {
        let collection: NftCollection
    }

}