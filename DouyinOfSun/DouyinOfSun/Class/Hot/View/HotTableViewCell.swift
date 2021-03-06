//
//  HotTableViewCell.swift
//  DouyinOfSun
//
//  Created by WorkSpace_Sun on 2019/3/12.
//  Copyright © 2019 WorkSpace_Sun. All rights reserved.
//

import UIKit
import SnapKit
import PLPlayerKit

private let kMyCellContainTag: Int = 0x01001
private let kMyCellCommentIconTag: Int = 0x01002
private let kMyCellShareIconTag: Int = 0x01003

private let kAvatarImageViewLength: CGFloat = 50
private let kFocusIconLength: CGFloat = 24

class HotTableViewCell: UITableViewCell {
    
    var isPlaying: Bool = false
    var isManualPaused: Bool = false
    var isCommentHidden: Bool = false {
        didSet {
            self.commentTextView.isHidden = isCommentHidden
        }
    }
    var aweme: aweme_list? {
        didSet {
            nickNameLabel.text = "@" + (aweme?.author?.nickname)!
            descLabel.text = aweme?.desc
            musicName.text = (aweme?.music?.title)! + " - " + (aweme?.music?.author)!
            favoriteNumber.text = String.formatCount(count: (aweme?.statistics?.digg_count)!)
            commentNumber.text = String.formatCount(count: (aweme?.statistics?.comment_count)!)
            shareNumber.text = String.formatCount(count: (aweme?.statistics?.share_count)!)
            backgroundImageView.setImageWithURL(imageUrl: URL(string: (aweme?.video?.origin_cover?.url_list?.first)!)!) {[weak self] (image, error) in
                self?.backgroundImageView.image = image
            }
            musicAlbum.albumImageView.setImageWithURL(imageUrl: URL(string: (aweme?.music?.cover_thumb?.url_list?.first)!)!) {[weak self] (image, error) in
                if error == nil {
                    self?.musicAlbum.albumImageView.image = image?.drawCircleImage()
                }
            }
            avatarImageView.setImageWithURL(imageUrl: URL(string: (aweme?.author?.avatar_thumb?.url_list?.first)!)!) {[weak self] (image, error) in
                if error == nil {
                    self?.avatarImageView.image = image?.drawCircleImage()
                }
            }
        }
    }
    
    private enum CellAnimationStatus {
        case uninit
        case animating
        case paused
    }
    private var lastTapTime: CFTimeInterval = 0
    private var animationStatus: CellAnimationStatus = .uninit
    
    private lazy var playerView: PLPlayerView = {
        let playerView = PLPlayerView(frame: CGRect.zero)
        playerView.delegate = self
        return playerView
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView(frame: CGRect.zero)
        backgroundImageView.image = UIImage(named: "img_video_loading")
        backgroundImageView.backgroundColor = UIColor.black
        backgroundImageView.contentMode = .scaleAspectFit
        return backgroundImageView
    }()
    
    private lazy var container: UIView = {
        let container = UIView(frame: CGRect.zero)
        container.backgroundColor = UIColor.clear
        container.tag = kMyCellContainTag
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture(sender:)))
        container.addGestureRecognizer(singleTapGesture)
        
        container.layer.addSublayer(gradientLayer)
        return container
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor]
        gradientLayer.locations = [0.3, 0.6, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        return gradientLayer
    }()
    
    private lazy var pauseIcon: UIImageView = {
        let pauseIcon = UIImageView(frame: CGRect.zero)
        pauseIcon.image = UIImage(named: "icon_play_pause")
        pauseIcon.contentMode = .center
        pauseIcon.layer.zPosition = 3
        pauseIcon.isHidden = true
        return pauseIcon
    }()
    
    private lazy var playerStatusBar: PlayerStatusBarView = {
        let playerStatusBar = PlayerStatusBarView(frame: CGRect.zero)
        return playerStatusBar
    }()
    
    private lazy var musicIcon: UIImageView = {
        let musicIcon = UIImageView(frame: CGRect.zero)
        musicIcon.image = UIImage(named: "icon_home_musicnote3")
        musicIcon.contentMode = .center
        return musicIcon
    }()
    
    private lazy var musicName: CircleTextView = {
        let musicName = CircleTextView(frame: CGRect.zero)
        musicName.font = UIFont.systemFont(ofSize: 14)
        musicName.textColor = UIColor.white
        return musicName
    }()
    
    private lazy var descLabel: UILabel = {
        let descLabel = UILabel(frame: CGRect.zero)
        descLabel.numberOfLines = 0
        descLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        descLabel.font = UIFont.systemFont(ofSize: 14)
        return descLabel
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let nickNameLabel = UILabel(frame: CGRect.zero)
        nickNameLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        nickNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        return nickNameLabel
    }()
    
    private lazy var musicAlbum: MusicAlbumView = {
        let musicAlbum = MusicAlbumView(frame: CGRect.zero)
        return musicAlbum
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView(frame: CGRect.zero)
        avatarImageView.image = UIImage(named: "img_find_default")
        avatarImageView.layer.cornerRadius = kAvatarImageViewLength / 2.0
        avatarImageView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8).cgColor
        avatarImageView.layer.borderWidth = 1
        return avatarImageView
    }()
    
    private lazy var focusIcon: FocusView = {
        let focusIcon = FocusView(frame: CGRect.zero)
        return focusIcon
    }()
    
    private lazy var favoriteView: FavoriteView = {
        let favoriteView = FavoriteView(frame: CGRect.zero)
        return favoriteView
    }()
    
    private lazy var commentIcon: UIImageView = {
        let commentIcon = UIImageView(frame: CGRect.zero)
        commentIcon.image = UIImage(named: "icon_home_comment")
        commentIcon.isUserInteractionEnabled = true
        commentIcon.tag = kMyCellCommentIconTag
        commentIcon.contentMode = .center
        commentIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGesture(sender:))))
        return commentIcon
    }()
    
    private lazy var shareIcon: UIImageView = {
        let shareIcon = UIImageView(frame: CGRect.zero)
        shareIcon.image = UIImage(named: "icon_home_share")
        shareIcon.isUserInteractionEnabled = true
        shareIcon.tag = kMyCellShareIconTag
        shareIcon.contentMode = .center
        shareIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGesture(sender:))))
        return shareIcon
    }()
    
    private lazy var favoriteNumber: UILabel = {
        let favoriteNumber = UILabel(frame: CGRect.zero)
        favoriteNumber.text = "0"
        favoriteNumber.textColor = UIColor.white
        favoriteNumber.font = UIFont.boldSystemFont(ofSize: 12)
        return favoriteNumber
    }()
    
    private lazy var commentNumber: UILabel = {
        let commentNumber = UILabel(frame: CGRect.zero)
        commentNumber.text = "0"
        commentNumber.textColor = UIColor.white
        commentNumber.font = UIFont.boldSystemFont(ofSize: 12)
        return commentNumber
    }()
    
    private lazy var shareNumber: UILabel = {
        let shareNumber = UILabel(frame: CGRect.zero)
        shareNumber.text = "0"
        shareNumber.textColor = UIColor.white
        shareNumber.font = UIFont.boldSystemFont(ofSize: 12)
        return shareNumber
    }()
    
    private lazy var commentTextView: CommentTextView = {
        let commentTextView = CommentTextView(frame: UIScreen.main.bounds)
        commentTextView.delegate = self
        return commentTextView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.black
        selectionStyle = .none
        initSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = CGRect(x: 0, y: frame.size.height - 500, width: frame.size.width, height: 500)
        CATransaction.commit()
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        playerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        pauseIcon.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }
        playerStatusBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(kTabbarH))
            make.height.equalTo(1.0)
        }
        commentTextView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        musicIcon.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview().offset(-60)
            make.width.equalTo(30)
            make.height.equalTo(25)
        }
        musicName.snp.makeConstraints { (make) in
            make.left.equalTo(musicIcon.snp.right)
            make.centerY.equalTo(musicIcon)
            make.width.equalTo(180)
            make.height.equalTo(24)
        }
        descLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalTo(musicIcon.snp.top)
            make.width.lessThanOrEqualTo(kScreenWidth / 5.0 * 3)
        }
        nickNameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalTo(descLabel.snp.top).offset(-5)
            make.width.lessThanOrEqualTo(kScreenWidth / 4.0 * 3 + 30)
        }
        musicAlbum.snp.makeConstraints { (make) in
            make.bottom.equalTo(musicName)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(50)
        }
        shareIcon.snp.makeConstraints { (make) in
            make.bottom.equalTo(musicAlbum.snp.top).offset(-50)
            make.right.equalTo(musicAlbum)
            make.width.equalTo(50)
            make.height.equalTo(45)
        }
        shareNumber.snp.makeConstraints { (make) in
            make.top.equalTo(shareIcon.snp.bottom)
            make.centerX.equalTo(shareIcon)
        }
        commentIcon.snp.makeConstraints { (make) in
            make.bottom.equalTo(shareIcon.snp.top).offset(-25)
            make.right.width.height.equalTo(shareIcon)
        }
        commentNumber.snp.makeConstraints { (make) in
            make.top.equalTo(commentIcon.snp.bottom)
            make.centerX.equalTo(commentIcon)
        }
        favoriteView.snp.makeConstraints { (make) in
            make.bottom.equalTo(commentIcon.snp.top).offset(-25)
            make.right.width.height.equalTo(shareIcon)
        }
        favoriteNumber.snp.makeConstraints { (make) in
            make.top.equalTo(favoriteView.snp.bottom)
            make.centerX.equalTo(favoriteView)
        }
        avatarImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(favoriteView.snp.top).offset(-35)
            make.right.equalTo(shareIcon)
            make.width.height.equalTo(kAvatarImageViewLength)
        }
        focusIcon.snp.makeConstraints { (make) in
            make.centerX.equalTo(avatarImageView)
            make.centerY.equalTo(avatarImageView.snp.bottom)
            make.width.height.equalTo(24)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        resetAll()
    }
    
    @objc private func handleGesture(sender: UITapGestureRecognizer) {
        switch sender.view?.tag {
        case kMyCellContainTag:
            let point = sender.location(in: container)
            let time = CACurrentMediaTime()
            if (time - lastTapTime) > 0.3 {
                // 延迟执行singleTap
                self.perform(#selector(singleTapToPausePlayer), with: nil, afterDelay: 0.3)
            } else {
                // 取消执行单击方法
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(singleTapToPausePlayer), object: nil)
                favoriteView.startLikeAnimation(true)
                showLikeAnimation(touchPoint: point)
            }
            lastTapTime = time

        case kMyCellCommentIconTag:
            print("kMyCellCommentIconTag")
        case kMyCellShareIconTag:
            SharePopView(frame: self.bounds).show()
        default:
            break
        }
    }
    
    @objc func showLikeAnimation(touchPoint: CGPoint) {
        let likeImageView = UIImageView(image: UIImage(named: "heart_82x75_"))
        let doubleRandom: Double = Double(arc4random() % 20) - 10
        let scale = CGFloat(doubleRandom / 10.0)
        let angle = CGFloat(.pi/4 * scale)
        likeImageView.frame = CGRect(x: touchPoint.x - 50, y: touchPoint.y - 48, width: 100, height: 92)
        likeImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.4).concatenating(CGAffineTransform.init(rotationAngle: angle))
        container.addSubview(likeImageView)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            likeImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0).concatenating(CGAffineTransform(rotationAngle: angle))
        }) { finished in
            UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseOut, animations: {
                likeImageView.transform = CGAffineTransform(scaleX: 3.0, y: 3.0).concatenating(CGAffineTransform(rotationAngle: angle))
                likeImageView.alpha = 0.0
            }, completion: { finished in
                likeImageView.removeFromSuperview()
            })
        }
    }
    
    @objc private func singleTapToPausePlayer() {
        if isPlaying == false {
            playerView.resume()
            isManualPaused = false
            UIView.animate(withDuration: 0.1, animations: {
                self.pauseIcon.alpha = 0.0
            }) { _ in
                self.pauseIcon.isHidden = true
            }
        } else {
            pauseIcon.isHidden = false
            pauseIcon.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            pauseIcon.alpha = 1.0
            playerView.pause()
            isManualPaused = true
            UIView.animate(withDuration: 0.24) {
                self.pauseIcon.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    func play() {
        guard let videoUrlList = aweme?.video?.play_addr?.url_list else {return}
        var playUrl: String?
        for urlStr in videoUrlList {
            if urlStr.contains("snssdk.com/aweme/v1/play/") {
                playUrl = urlStr
                break
            }
        }
        playerView.playWithUrl(urlStr: playUrl ?? "")
        if pauseIcon.isHidden == false {
            pauseIcon.isHidden = true
        }
    }
    
    func pause(isPauseIconHidden: Bool) {
        playerView.pause()
        if pauseIcon.isHidden == !isPauseIconHidden {
            pauseIcon.isHidden = isPauseIconHidden
        }
    }
    
    func resume() {
        playerView.resume()
        if pauseIcon.isHidden == false {
            pauseIcon.isHidden = true
        }
    }
    
    func stop() {
        playerView.stop()
        resetAnimations()
        playerStatusBar.reset()
        sendSubviewToBack(playerView)
        if pauseIcon.isHidden == false {
            pauseIcon.isHidden = true
            isManualPaused = false
        }
    }
    
    func updateVolume(newValue: CGFloat, oldValue: CGFloat) {
        playerStatusBar.updateVolume(newValue: newValue, oldValue: oldValue)
    }
}

extension HotTableViewCell {
    private func initSubviews() {
        addSubview(playerView)
        addSubview(backgroundImageView)
        addSubview(container)
        addSubview(commentTextView)
        container.addSubview(pauseIcon)
        container.addSubview(playerStatusBar)
        container.addSubview(musicIcon)
        container.addSubview(musicName)
        container.addSubview(descLabel)
        container.addSubview(nickNameLabel)
        container.addSubview(musicAlbum)
        container.addSubview(shareIcon)
        container.addSubview(shareNumber)
        container.addSubview(commentIcon)
        container.addSubview(commentNumber)
        container.addSubview(favoriteView)
        container.addSubview(favoriteNumber)
        container.addSubview(avatarImageView)
        container.addSubview(focusIcon)
    }
    
    private func startAnimations() {
        musicName.startAnimation()
        musicAlbum.startAnimation()
        animationStatus = .animating
    }
    
    private func pauseAnimation() {
        musicName.pauseAnimation()
        musicAlbum.pauseAnimation()
        animationStatus = .paused
    }
    
    private func resumeAnimation() {
        musicName.resumeAnimation()
        musicAlbum.resumeAnimation()
        animationStatus = .animating
    }
    
    private func resetAll() {
        pauseIcon.isHidden = true
        descLabel.text = ""
        isPlaying = false
        isManualPaused = false
        avatarImageView.image = UIImage(named: "img_find_default")
        backgroundImageView.image = UIImage(named: "img_video_loading")
        focusIcon.reset()
        favoriteView.reset()
        resetAnimations()
        playerStatusBar.reset()
        playerView.stop()
    }
    
    func resetAnimations() {
        musicName.reset()
        musicAlbum.reset()
        animationStatus = .uninit
    }
}

extension HotTableViewCell: CommentTextViewDelegate {
    func commentTextView(textView: CommentTextView, willShowOnScreen willShow: Bool) {
        container.alpha = willShow ? 0.0 : 1.0
    }
    
    func commentTextView(textView: CommentTextView, willSendMessage message: String) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            UIWindow.showTips(text: "评论成功-。-")
        }
    }
}

extension HotTableViewCell: PLPlayerViewDelegate {
    func playerView(_ playerView: PLPlayerView, _ player: PLPlayer, statusDidChange state: PLPlayerStatus) {
        if state == .statusPlaying {
            isPlaying = true
            if animationStatus == .uninit {
                startAnimations()
            } else if animationStatus == .paused {
                resumeAnimation()
            }
        } else if state == .statusPaused {
            if animationStatus == .animating {
                pauseAnimation()
            }
            isPlaying = false
        } else if state == .statusStopped {
            isPlaying = false
        }
        if state == .statusCaching || state == .statusPreparing || state == .statusReady {
            playerStatusBar.showCachingAnimation()
        } else {
            playerStatusBar.removeCachingAnimation()
        }
    }
    
    func playerView(_ playerView: PLPlayerView, _ player: PLPlayer, stoppedWithError error: Error?) {
        UIWindow.showTips(text: (error?.localizedDescription)!)
    }
    
    func playerView(_ playerView: PLPlayerView, _ player: PLPlayer, firstRender firstRenderType: PLPlayerFirstRenderType) {
        if firstRenderType == .video {
            sendSubviewToBack(backgroundImageView)
        }
    }
    
    func playerView(_ playerView: PLPlayerView, _ player: PLPlayer, playingProgressValue playingProgress: CGFloat) {
        playerStatusBar.updateProgress(progress: playingProgress)
    }
}
