//
//  CarouselViewController.swift
//  Vought Showcase
//
//  Created by Burhanuddin Rampurawala on 06/08/24.
//

import Foundation
import UIKit


final class CarouselViewController: UIViewController {
    
    /// Container view for the carousel
    @IBOutlet private weak var containerView: UIView!
    
    /// Carousel control with page indicator
//    @IBOutlet private weak var carouselControl: UIPageControl!
    
    // MARK: - Custom TilePageControl
    private let tilePageControl = TilePageControl()


    /// Page view controller for carousel
    private var pageViewController: UIPageViewController?
    
    /// Carousel items
    private var items: [CarouselItem] = []
    
    private var isAutoAdvancing: Bool = false
    private var isUserInteracting: Bool = false

    
    /// Current item index
    private var currentItemIndex: Int = 0 {
        didSet {
            // Update carousel control page
            self.tilePageControl.configure(numberOfPages: items.count, currentPage: currentItemIndex)
            resetAutoAdvanceTimer()
        }
    }

    /// Timer for automatic carousel advancement
    private var autoAdvanceTimer: Timer?
    
    /// Initializer
    /// - Parameter items: Carousel items
    public init(items: [CarouselItem]) {
        self.items = items
        super.init(nibName: "CarouselViewController", bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPageViewController()
        initTilePageControl()
        addTapGestureRecognizers()
        startAutoAdvanceTimer()
    }
    
    deinit {
        // Invalidate the timer when the view controller is deinitialized
        autoAdvanceTimer?.invalidate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        autoAdvanceTimer?.invalidate()
        isAutoAdvancing = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAutoAdvanceTimer()
    }

    
    /// Initialize page view controller
    private func initPageViewController() {

        // Create pageViewController
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal,
        options: nil)

        // Set up pageViewController
        pageViewController?.dataSource = self
        pageViewController?.delegate = self
        pageViewController?.setViewControllers(
            [getController(at: currentItemIndex)], direction: .forward, animated: true)

        guard let theController = pageViewController else {
            return
        }
        
        // Add pageViewController in container view
        add(asChildViewController: theController,
            containerView: containerView)
    }

    /// Initialize carousel control
    private func initTilePageControl() {
        tilePageControl.translatesAutoresizingMaskIntoConstraints = false
        tilePageControl.configure(numberOfPages: items.count, currentPage: currentItemIndex)
        
        view.addSubview(tilePageControl)
        
        NSLayoutConstraint.activate([
            tilePageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tilePageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tilePageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tilePageControl.heightAnchor.constraint(equalToConstant: 4)
        ])
        
        tilePageControl.backgroundColor = .clear
    }
    
    /// Add tap gestures for left and right side taps
    private func addTapGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    /// Handle tap gesture
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard !isUserInteracting else { return }
        isUserInteracting = true
        
        let location = gesture.location(in: self.view)
        
        let newIndex: Int
        let direction: UIPageViewController.NavigationDirection
        if location.x < view.bounds.width / 2 {
            newIndex = (currentItemIndex > 0) ? (currentItemIndex - 1) : (items.count - 1)
            direction = .reverse
        } else {
            newIndex = (currentItemIndex < items.count - 1) ? (currentItemIndex + 1) : 0
            direction = .forward
        }
        
        let newViewController = getController(at: newIndex)
        
        if pageViewController?.viewControllers?.first != newViewController {
            pageViewController?.setViewControllers([newViewController], direction: direction, animated: true) { [weak self] finished in
                guard let self = self else { return }
                self.isUserInteracting = false
            }
            currentItemIndex = newIndex
        } else {
            isUserInteracting = false
        }
    }



    /// Start the auto-advance timer
    private func startAutoAdvanceTimer() {
        print("Starting auto-advance timer.")
        autoAdvanceTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(autoAdvance), userInfo: nil, repeats: true)
    }
    
    private func resetAutoAdvanceTimer() {
        print("Resetting auto-advance timer.")
        autoAdvanceTimer?.invalidate() // Invalidate the existing timer
        autoAdvanceTimer = nil // Set to nil to ensure a new timer is created
        startAutoAdvanceTimer() // Start a new timer
    }
    
    @objc private func autoAdvance() {
        guard !isAutoAdvancing && !isUserInteracting else { return }
        
        isAutoAdvancing = true
        let newIndex = (currentItemIndex + 1) % items.count
        let direction: UIPageViewController.NavigationDirection = newIndex > currentItemIndex ? .forward : .reverse
        let newViewController = getController(at: newIndex)
        
        if let currentViewController = pageViewController?.viewControllers?.first,
           currentViewController != newViewController {
            pageViewController?.setViewControllers([newViewController], direction: direction, animated: true) { [weak self] finished in
                guard let self = self else { return }
                self.currentItemIndex = newIndex
                self.isAutoAdvancing = false
            }
        } else {
            isAutoAdvancing = false
        }
    }
    
    private func getController(at index: Int) -> UIViewController {
        guard index >= 0, index < items.count else {
            fatalError("Index out of bounds while fetching view controller.")
        }
        return items[index].getController()
    }


}

// MARK: UIPageViewControllerDataSource methods
extension CarouselViewController: UIPageViewControllerDataSource {
    
    /// Get previous view controller
    /// - Parameters:
    ///  - pageViewController: UIPageViewController
    ///  - viewController: UIViewController
    /// - Returns: UIViewController
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
            // Check if current item index is first item
            // If yes, return last item controller
            // Else, return previous item controller
            if currentItemIndex == 0 {
                return items.last?.getController()
            }
            return getController(at: currentItemIndex-1)
        }

    /// Get next view controller
    /// - Parameters:
    ///  - pageViewController: UIPageViewController
    ///  - viewController: UIViewController
    /// - Returns: UIViewController
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
           
            // Check if current item index is last item
            // If yes, return first item controller
            // Else, return next item controller
            if currentItemIndex + 1 == items.count {
                return items.first?.getController()
            }
            return getController(at: currentItemIndex + 1)
        }
}

// MARK: UIPageViewControllerDelegate methods
extension CarouselViewController: UIPageViewControllerDelegate {
    
    /// Page view controller did finish animating
    /// - Parameters:
    /// - pageViewController: UIPageViewController
    /// - finished: Bool
    /// - previousViewControllers: [UIViewController]
    /// - completed: Bool
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
            if completed,
               let visibleViewController = pageViewController.viewControllers?.first,
               let index = items.firstIndex(where: { $0.getController() == visibleViewController }){
                currentItemIndex = index
            }
        }
}
