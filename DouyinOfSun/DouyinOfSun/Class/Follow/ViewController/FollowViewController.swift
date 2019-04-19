//
//  FollowViewController.swift
//  DouyinOfSun
//
//  Created by WorkSpace_Sun on 2019/1/17.
//  Copyright © 2019 WorkSpace_Sun. All rights reserved.
//

import UIKit
import SnapKit
import HandyJSON

private let followCellIdentifier = "followCellIdentifier"
class FollowViewController: UIViewController {
    
    @objc dynamic var playingCellIndex: Int = 0
    private var isFirstLoaded: Bool = false
    private var awemeList = [aweme_list]()
    private var isScrollingToTop: Bool = false
    private weak var fullScreenController: PlayerVerticalFullScreenViewController?
    private var cellHeightArray = [CGFloat]()
    var currentCell: FollowTableViewCell?
    
    private lazy var navigationBarView: FollowNavigationBarView = {
        let navigationBarView = FollowNavigationBarView(frame: CGRect.zero)
        return navigationBarView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: UITableView.Style.plain)
        tableView.backgroundColor = UIColor(r: 22, g: 24, b: 35)
        tableView.estimatedRowHeight = 0 // 禁止tableView在reloadData时估算cell高度
        tableView.showsVerticalScrollIndicator = false
        tableView.scrollsToTop = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.register(FollowTableViewCell.self, forCellReuseIdentifier: followCellIdentifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 22, g: 24, b: 35)
        setupUI()
        addBackgroundNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentCell?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentCell?.pause()
    }
}

extension FollowViewController {
    private func setupUI() {
        view.addSubview(navigationBarView)
        view.insertSubview(tableView, belowSubview: navigationBarView)
        navigationBarView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(64)
        }
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navigationBarView.snp.bottom)
        }
    }
    
    private func addBackgroundNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func applicationWillResignActiveNotification() {
        currentCell?.pause()
    }
    
    @objc private func applicationDidBecomeActiveNotification() {
        currentCell?.play()
    }
    
    func loadData() {
        if isFirstLoaded == true { return }
        isFirstLoaded = true
        DispatchQueue.global().async {
            let bundleName = ["production1",
                              "favorite1", "favorite2", "favorite3", "favorite4", "favorite5", "favorite6", "favorite7", "favorite8"]
            var tempAwemeList = [aweme_list]()
            for i in 0 ..< bundleName.count {
                let awemeDataJson: String = try! NSString(contentsOfFile: Bundle.main.path(forResource: bundleName[i], ofType: "json")!, encoding: String.Encoding.utf8.rawValue) as String
                let awemeModel = JSONDeserializer<AwemeModel>.deserializeFrom(json: awemeDataJson)
                var validAwemeModel = [aweme_list]()
                for aweme in (awemeModel?.aweme_list)! {
                    if aweme.video != nil {
                        validAwemeModel.append(aweme)
                    }
                }
                tempAwemeList += validAwemeModel
            }
            self.awemeList = tempAwemeList.sorted(by: { (obj1, obj2) -> Bool in
                return Int(arc4random() % 3) - 1 > 0
            })
            
            // 计算cell高度
            self.calculateCellHeight()
            
            DispatchQueue.main.async {
                self.tableView.isScrollEnabled = true
                self.tableView.reloadData()
                self.addObserver(self, forKeyPath: "playingCellIndex", options: [.initial, .new, .old], context: nil)
            }
        }
    }
    
    private func calculateCellHeight() {
        let topMargin: CGFloat = 20.0
        let portraitHeight: CGFloat = 36.0
        let descTopMargin: CGFloat = 15.0
        let playerViewTopMargin: CGFloat = 15.0
        let bottomButtonTopMargin: CGFloat = 20.0
        let bottomButtonHeight: CGFloat = 25.0
        let bottomMargin: CGFloat = 20.0
        
        for aweme in awemeList {
            var descHeight: CGFloat = 0
            if aweme.desc != nil && aweme.desc != "" {
                let descString = aweme.desc! as NSString
                let descRect = descString.boundingRect(with: CGSize(width: kScreenWidth - 2 * 15, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)], context: nil)
                descHeight = descRect.size.height
            }
            
            var playerViewHeight: CGFloat = 415
            
            guard let width = aweme.video?.width else { return }
            guard let height = aweme.video?.height else { return }
            if width > height {
                playerViewHeight = (kScreenWidth - 2 * 15) / 16.0 * 9.0
            }
            
            let cellHeight = topMargin + portraitHeight + descTopMargin + descHeight + playerViewTopMargin + playerViewHeight + bottomButtonTopMargin + bottomButtonHeight + bottomMargin
            self.cellHeightArray.append(cellHeight)
        }
    }
}

extension FollowViewController: UITableViewDelegate {
    
}

extension FollowViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeightArray[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return awemeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: followCellIdentifier, for: indexPath) as! FollowTableViewCell
        cell.aweme = awemeList[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension FollowViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isScrollingToTop == true { return }
        let rectInTableView = tableView.rectForRow(at: IndexPath(row: playingCellIndex, section: 0))
        let rectInController = tableView.convert(rectInTableView, to: self.view)
        let centerY = rectInController.origin.y + rectInController.size.height / 2.0
        if centerY < 64.0 {
            playingCellIndex += 1
        } else if centerY > kScreenHeight - kTabbarH {
            playingCellIndex -= 1
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "playingCellIndex" {
            guard let nonnilChange = change else { return }
            let old = nonnilChange[NSKeyValueChangeKey.oldKey]
            let new = nonnilChange[NSKeyValueChangeKey.newKey]
            if new != nil && old != nil {
                if old as! Int == new as! Int {
                    return
                } else {
                    let nextCell = tableView.cellForRow(at: IndexPath(row: new as! Int, section: 0)) as! FollowTableViewCell
                    self.currentCell?.pause()
                    nextCell.play()
                    self.currentCell?.setEnable(false)
                    self.currentCell = nextCell
                    self.currentCell?.setEnable(true)
                }
            } else {
                let firstCell = tableView.cellForRow(at: IndexPath(row: playingCellIndex, section: 0)) as! FollowTableViewCell
                firstCell.play()
                self.currentCell = firstCell
                self.currentCell?.setEnable(true)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

extension FollowViewController: FollowTableViewCellDelegate {
    func followTableViewCell(cell: FollowTableViewCell, playerViewWillEnterFullScreenWithIsVertical isVertical: Bool) {
        let fullScreenVC = PlayerVerticalFullScreenViewController()
        fullScreenVC.modalPresentationStyle = .overFullScreen
        fullScreenVC.transitioningDelegate = self
        fullScreenVC.modalPresentationCapturesStatusBarAppearance = true
        present(fullScreenVC, animated: true) {
            self.currentCell?.playerView.playViewState = .fullScreen
        }
        fullScreenController = fullScreenVC
    }
    func followTableViewCell(cell: FollowTableViewCell, playerViewWillExitFullScreenWithIsVertical isVertical: Bool) {
        fullScreenController?.dismiss(animated: true, completion: {[weak self] in
            self?.currentCell?.playerView.playViewState = .small
            self?.fullScreenController = nil
        })
    }
}

extension FollowViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FollowScalePresentTransition(cell: currentCell!)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FollowScaleDismissTransition(cell: currentCell!)
    }
}

