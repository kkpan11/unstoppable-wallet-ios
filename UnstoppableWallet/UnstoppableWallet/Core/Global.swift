import Combine
import Foundation
import RxCocoa
import RxSwift

func subscribe<T>(_ disposeBag: DisposeBag, _ driver: Driver<T>, _ onNext: ((T) -> Void)? = nil) {
    driver.drive(onNext: onNext).disposed(by: disposeBag)
}

func subscribe<T>(_ disposeBag: DisposeBag, _ signal: Signal<T>, _ onNext: ((T) -> Void)? = nil) {
    signal.emit(onNext: onNext).disposed(by: disposeBag)
}

func subscribe<T>(_ disposeBag: DisposeBag, _ observable: Observable<T>?, _ onNext: ((T) -> Void)? = nil) {
    observable?
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
        .subscribe(onNext: onNext)
        .disposed(by: disposeBag)
}

func subscribeSerial<T>(_ disposeBag: DisposeBag, _ observable: Observable<T>, _ onNext: ((T) -> Void)? = nil) {
    observable
        .subscribe(onNext: onNext)
        .disposed(by: disposeBag)
}

func subscribe<T>(_ scheduler: ImmediateSchedulerType, _ disposeBag: DisposeBag, _ observable: Observable<T>, _ onNext: ((T) -> Void)? = nil) {
    observable
        .observeOn(scheduler)
        .subscribe(onNext: onNext)
        .disposed(by: disposeBag)
}

func subscribe<T>(_ cancellables: inout Set<AnyCancellable>, _ publisher: AnyPublisher<T, Never>, _ receiveValue: @escaping ((T) -> Void)) {
    publisher
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: receiveValue)
        .store(in: &cancellables)
}
