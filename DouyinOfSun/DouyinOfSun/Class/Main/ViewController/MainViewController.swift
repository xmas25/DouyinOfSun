//
//  MainViewController.swift
//  DouyinOfSun
//
//  Created by WorkSpace_Sun on 2019/1/2.
//  Copyright © 2019 WorkSpace_Sun. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    fileprivate var homeTabBarSelectedType: HomeTabBarViewControllerSelectedType?
    
    fileprivate lazy var scrollView: HomeScrollView = {
        let scrollView = HomeScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: 2 * kScreenWidth, height: 0)
        scrollView.contentOffset = CGPoint(x: kScreenWidth, y: 0)
        scrollView.backgroundColor = UIColor.purple
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
        
        setupUI()
        addChildViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isLeftPushGestureEnabled = true
        statusBarHidden = homeTabBarSelectedType == .hot ? true : false
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension MainViewController {
    private func setupUI() {
        view.addSubview(scrollView)
    }
    
    private func addChildViewController() {
        let recommendVC = RecommendViewController()
        let homeTabVC = HomeTabBarViewController()
        homeTabVC.homeTabBarViewControllerDelegate = self
        homeTabVC.selectedIndex = 0
        homeTabBarSelectedType = .hot
        
        addChild(recommendVC)
        addChild(homeTabVC)
        
        scrollView.addSubview(recommendVC.view)
        scrollView.addSubview(homeTabVC.view)
        recommendVC.view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        homeTabVC.view.frame = CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight)
    }
}

extension MainViewController: HomeTabBarViewControllerDelegate {
    func homeTabBarViewController(tabBarViewController: HomeTabBarViewController, didSelected type: HomeTabBarViewControllerSelectedType) {
        statusBarHidden = type == .hot ? true : false
        homeTabBarSelectedType = type
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        statusBarHidden = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == kScreenWidth {
            statusBarHidden = true
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