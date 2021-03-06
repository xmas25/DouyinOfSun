//
//  MainViewController.swift
//  DouyinOfSun
//
//  Created by WorkSpace_Sun on 2019/1/2.
//  Copyright © 2019 WorkSpace_Sun. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {
    
    fileprivate var homeTabBarSelectedType: HomeTabBarViewControllerSelectedType?
    fileprivate var recommendVC: RecommendViewController?
    fileprivate var homeTabVC: HomeTabBarViewController?
    fileprivate lazy var scrollView: HomeScrollView = {
        let scrollView = HomeScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: 2 * kScreenWidth, height: 0)
        scrollView.contentOffset = CGPoint(x: kScreenWidth, y: 0)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            // scrollView内间距问题
            scrollView.contentInsetAdjustmentBehavior = .never;
        }
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        setupUI()
        addChildViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        interactiveGestureDelegate = self
        if scrollView.contentOffset.x == kScreenWidth && homeTabBarSelectedType == .hot {
            statusBarHidden = true
        } else {
            statusBarHidden = false
        }
        statusBarStyle = .lightContent
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationTransitionType = .leftPush
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension MainViewController {
    private func setupUI() {
        view.addSubview(scrollView)
    }
    
    private func addChildViewController() {
        recommendVC = RecommendViewController()
        recommendVC?.recommendViewControllerDelegate = self
        homeTabVC = HomeTabBarViewController()
        homeTabVC?.homeTabBarViewControllerDelegate = self
        homeTabVC?.selectedIndex = 0
        homeTabBarSelectedType = .hot
        
        addChild(recommendVC!)
        addChild(homeTabVC!)
        
        scrollView.addSubview(recommendVC!.view)
        scrollView.addSubview(homeTabVC!.view)
        recommendVC!.view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        homeTabVC!.view.frame = CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight)
    }
}

extension MainViewController: HomeTabBarViewControllerDelegate {
    func homeTabBarViewController(tabBarViewController: HomeTabBarViewController, didSelected type: HomeTabBarViewControllerSelectedType) {
        statusBarHidden = type == .hot ? true : false
        homeTabBarSelectedType = type
        navigationController!.navigationTransitionType = type == .hot ? .leftPush : .none
        scrollView.isScrollEnabled = type == .hot ? true : false
        if type == .follow {
            tabBarViewController.followVC?.loadData()
        }
    }
    func homeTabBarViewControllerRecorderButtonDidSelected() {
        let recorderVC = RecordViewController()
        present(recorderVC, animated: true, completion: nil)
    }
}

extension MainViewController: RecommendViewControllerDelegate {
    func recommendViewControllerBackItemDidSelected() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.scrollView.setContentOffset(CGPoint(x: kScreenWidth, y: 0), animated: false)
        }) { (_) in
            self.homeTabVC?.hotVC?.hotVCTransformOperation(isActive: true, needUpdateBackgroundNotification: true)
            self.homeTabVC?.isTabbarVCShowing = true
        }
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == kScreenWidth {
            statusBarHidden = false
            homeTabVC?.hotVC?.hotVCTransformOperation(isActive: false, needUpdateBackgroundNotification: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == kScreenWidth {
            statusBarHidden = true
            homeTabVC?.hotVC?.hotVCTransformOperation(isActive: true, needUpdateBackgroundNotification: true)
            homeTabVC?.isTabbarVCShowing = true
        } else {
            homeTabVC?.isTabbarVCShowing = false
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.x == kScreenWidth {
            statusBarHidden = true
            homeTabVC?.hotVC?.hotVCTransformOperation(isActive: true, needUpdateBackgroundNotification: true)
            homeTabVC?.isTabbarVCShowing = true
        } else {
            homeTabVC?.isTabbarVCShowing = false
        }
    }
}

extension MainViewController: UIViewControllerInteractivePushGestureDelegate {
    func destinationViewControllerFrom(fromViewController: UIViewController) -> UIViewController {
        let myVC = MyViewController()
        myVC.hidesBottomBarWhenPushed = true
        return myVC
    }
}
