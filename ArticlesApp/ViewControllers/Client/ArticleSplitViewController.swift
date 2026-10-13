import UIKit

/// iPad shows the list on the left and the article on the right.
/// iPhone shows the list, then pushes the article.
final class ArticleSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    var showsSideBySide: Bool {
        traitCollection.userInterfaceIdiom == .pad
            && traitCollection.horizontalSizeClass == .regular
    }

    convenience init() {
        self.init(style: .doubleColumn)
        delegate = self
        preferredSplitBehavior = .tile
        preferredDisplayMode = .oneBesideSecondary
        primaryBackgroundStyle = .none
        presentsWithGesture = false
        displayModeButtonVisibility = .never
        minimumPrimaryColumnWidth = 320
        maximumPrimaryColumnWidth = 560
        preferredPrimaryColumnWidthFraction = 0.4
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showColumnsSideBySide()
        stopSplitViewGestures()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.showColumnsSideBySide()
        }
    }

    func showArticle(_ article: Article) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detail = storyboard.instantiateViewController(
            withIdentifier: "DetailViewController"
        ) as? DetailViewController else {
            return
        }
        detail.article = article

        if showsSideBySide {
            showColumnsSideBySide()
            setViewController(detail, for: .secondary)
        } else if let navigation = viewController(for: .primary) as? UINavigationController {
            navigation.pushViewController(detail, animated: true)
        }
    }

    func splitViewController(
        _ splitViewController: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        .primary
    }

    func splitViewController(
        _ splitViewController: UISplitViewController,
        displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode
    ) -> UISplitViewController.DisplayMode {
        .oneBesideSecondary
    }

    /// The split view's pan sits on top of the list and cancels scrolling and taps.
    private func stopSplitViewGestures() {
        guard showsSideBySide else { return }
        view.gestureRecognizers?.forEach { recognizer in
            if recognizer.isEnabled {
                recognizer.isEnabled = false
            }
        }
    }

    private func showColumnsSideBySide() {
        guard showsSideBySide else { return }
        preferredSplitBehavior = .tile
        primaryBackgroundStyle = .none
        presentsWithGesture = false
        if preferredDisplayMode != .oneBesideSecondary {
            preferredDisplayMode = .oneBesideSecondary
        }
    }
}

/// Root container. Its view sends each touch to the column under the finger.
/// UISplitViewController can draw the list on top of the article while still
/// giving the touch to the article underneath.
final class SplitTouchHostController: UIViewController {
    let split: ArticleSplitViewController

    init(split: ArticleSplitViewController) {
        self.split = split
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used")
    }

    override func loadView() {
        let touchView = ColumnTouchView()
        touchView.split = split
        view = touchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.page
        addChild(split)
        split.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(split.view)
        NSLayoutConstraint.activate([
            split.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            split.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            split.view.topAnchor.constraint(equalTo: view.topAnchor),
            split.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        split.didMove(toParent: self)
    }

    override var childForStatusBarStyle: UIViewController? { split }
}

private final class ColumnTouchView: UIView {
    weak var split: ArticleSplitViewController?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let split, split.showsSideBySide else {
            return super.hitTest(point, with: event)
        }

        let usePrimary = point.x <= divider(for: split)
        let column = usePrimary
            ? split.viewController(for: .primary)
            : split.viewController(for: .secondary)
        guard let columnView = column?.viewIfLoaded else {
            return super.hitTest(point, with: event)
        }

        columnView.isUserInteractionEnabled = true
        let localPoint = columnView.convert(point, from: self)
        return columnView.hitTest(localPoint, with: event) ?? super.hitTest(point, with: event)
    }

    private func divider(for split: ArticleSplitViewController) -> CGFloat {
        if let primary = split.viewController(for: .primary)?.viewIfLoaded {
            let frame = primary.convert(primary.bounds, to: self)
            if frame.minX <= 1, frame.width > 1, frame.width < bounds.width - 1 {
                return frame.maxX
            }
        }
        if split.primaryColumnWidth > 1, split.primaryColumnWidth < bounds.width - 1 {
            return split.primaryColumnWidth
        }
        return bounds.width * 0.4
    }
}
