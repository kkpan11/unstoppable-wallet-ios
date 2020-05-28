class GuidePresenter {
    weak var view: IGuideView?

    private let router: IGuideRouter
    private let interactor: IGuideInteractor

    private let guide: Guide

    init(guide: Guide, router: IGuideRouter, interactor: IGuideInteractor) {
        self.guide = guide
        self.router = router
        self.interactor = interactor
    }

}

extension GuidePresenter: IGuideViewDelegate {

    func onLoad() {
        view?.set(title: guide.title, imageUrl: guide.imageUrl)
    }

}

extension GuidePresenter: IGuideInteractorDelegate {
}