//
//  FollowNavigationBarView.swift
//  DouyinOfSun
//
//  Created by WorkSpace_Sun on 2019/2/25.
//  Copyright © 2019 WorkSpace_Sun. All rights reserved.
//

import UIKit
import SnapKit

class FollowNavigationBarView: UIView {
    
    private lazy var cameraButton: UIButton = {
        let cameraButton = UIButton(type: UIButton.ButtonType.custom)
        cameraButton.setImage(UIImage(named: "iconProfileAddsuipai_24x24_"), for: .normal)
        cameraButton.backgroundColor = UIColor.clear
        return cameraButton
    }()
    
    private lazy var cameraLabel: UILabel = {
        let cameraLabel = UILabel(frame: CGRect.zero)
        cameraLabel.text = "随拍"
        cameraLabel.textColor = UIColor(r: 210, g: 210, b: 210)
        cameraLabel.font = UIFont.boldSystemFont(ofSize: 15)
        cameraLabel.backgroundColor = UIColor.clear
        return cameraLabel
    }()
    
    private lazy var titleView: HomeNaviTitleView = {
        let titleView = HomeNaviTitleView(frame: CGRect.zero, titles: ["关注", "好友"])
        return titleView
    }()
    
    private lazy var lineView: UIView = {
        let lineView = UIView(frame: CGRect.zero)
        lineView.backgroundColor = UIColor(r: 210, g: 210, b: 210)
        return lineView
    }()

    override init(frame: CGRect) {
        super.init(frame:frame)
        
        backgroundColor = UIColor(r: 22, g: 24, b: 35)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FollowNavigationBarView {
    private func setupUI() {
        addSubview(cameraButton)
        addSubview(cameraLabel)
        addSubview(titleView)
        addSubview(lineView)
        
        cameraButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalTo(42)
            make.height.equalTo(36)
        }
        cameraLabel.snp.makeConstraints { (make) in
            make.left.equalTo(cameraButton.snp.right).offset(10)
            make.centerY.equalTo(42)
            make.height.equalTo(36)
        }
        titleView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(42)
            make.width.equalTo(120)
        }
        lineView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(kScreenWidth)
            make.height.equalTo(0.1)
        }
    }
}
