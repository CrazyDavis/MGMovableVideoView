//
//  MGMovableVideoView.swift
//  MGMovableVideoView
//
//  Created by Magical Water on 2018/5/14.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit
import MGViewsSwift
import MGUtilsSwift

/*
 此view有兩個主要的子view
 1. video attach view: 播放的影像主要顯示在此attach view上
 2. control attach view: 播放器的操控元件view加入此view

 同時全螢幕需要委託給外部幫忙隱藏狀態欄

 注意: 外部實作Control View設定之後, 不可使用約束, control view需要實作當 bounds 改變時各個元件的位置
 */
public class MGMovableVideoView: MGPanMoveView {

    public typealias ControlView = UIView & MGMovableVideoViewDelegate

    private var videoAttachView: UIView!
    private var controlAttachView: UIView!

    private weak var controlViewDelegate: MGMovableVideoViewDelegate?

    private var videoManager: MGVideoManager!

    //默認影片比例, 當取不到videoSize時, 先以預設size作收
    public var videoSizeDefault: CGSize = CGSize.init(width: 16, height: 9)

    //現在播放中的影片size
    public var videoSize: CGSize?

    //現在view的 attr
    public var panVideoAttr: MGPanVideoAnimationAttr?

    //在bounds改變時也改變attach view的大小
    public override var bounds: CGRect {
        didSet {
            resizeContainerView()
        }
    }

    //初始化attach view, 並且將attach view符合super view
    public override func setupView() {
        videoAttachView = UIView.init(frame: self.bounds)
        controlAttachView = UIView.init(frame: self.bounds)

        videoManager = MGVideoManager.init(videoAttachView)
        videoManager.videoManagerDelegate = self
    }

    //bounds改變, 兩個container都需要重新配置
    private func resizeContainerView() {
        videoAttachView?.frame = self.bounds
        controlAttachView?.frame = self.bounds

        controlViewDelegate?.boundsChange()
    }

    //設定控制的相關view
    public func setControlView(_ view: ControlView) {
        removeControlView()
        controlViewDelegate = view
        controlAttachView.addSubview(view)
    }

    public func removeControlView() {
        controlAttachView.subviews.forEach {
            $0.removeFromSuperview()
        }
        controlViewDelegate = nil
    }

    public func setSizeAttr(_ attr: MGPanVideoAnimationAttr, animate: Bool = true) {
        panVideoAttr = nil

        //假如目前有動畫正在修改影片屬性, 停止, 以新的為主
        self.layer.removeAllAnimations()

        switch attr.size {
        case .aspectFit: //影片依照比例, 最大邊 符合 inRect

            //先檢測 inRect 是否有值, 無值則無效
            guard let inRect = attr.inRect else {
                print("設置影片屬性發生錯誤: 當類行為 aspectFit 時, 需要設置 inRect")
                return
            }

            panVideoAttr = attr
            let rect = CGRect.init(origin: CGPoint.zero, size: inRect.size)

            UIView.animate(withDuration: 0.3) {
                self.bounds = rect
                self.frame = rect
                self.center = CGPoint.init(x: inRect.midX + attr.dx, y: inRect.midY + attr.dy)
            }

        case .proportion: //view符合影片比例, 並將最大邊設置到
            guard let maxSide = attr.maxSide else {
                print("設置影片屬性發生錯誤: 當類行為 proportion 時, 需要設置 maxSide")
                return
            }
            if videoSize == nil {
                print("設置影片屬性警告: 當前並無獲取到影片的size比例, 先以預設比例 \(videoSizeDefault.width):\(videoSizeDefault.height) 設置")
            }

            let size = videoSize ?? videoSizeDefault

            panVideoAttr = attr

            var width: CGFloat
            var height: CGFloat

            if size.width > size.height {
                width = maxSide
                height = MGProportionUtils.getHeight(size.width, oriH: size.height, newW: width)
            } else {
                height = maxSide
                width = MGProportionUtils.getWidth(size.width, oriH: size.height, newH: height)
            }

            UIView.animate(withDuration: 0.3) {
                let r = CGRect.init(origin: self.bounds.origin, size: CGSize.init(width: width, height: height))
                let centerX = self.center.x
                let centerY = self.center.y
                self.bounds = r
                self.frame = r
                self.center = CGPoint.init(x: centerX + attr.dx, y: centerY + attr.dy)
            }

        }
    }

    //設置相關動作
    public func setAction(_ action: VideoControlAction) {
        switch action {
        case .play: break
        case .pause: break
        case .stop: break
        case .normal: break
        case .full: break
        }
    }

}

//VideoManager的相關委託
extension MGMovableVideoView: VideoManagerDelegate {
    func statusChange(_ status: MGVideoStatus) {
    }

    func videoSize(_ size: CGSize) {

    }
}

//VideoControlView的控制相關(基本控制)
extension MGMovableVideoView: MGMovableVideoControlDelegate {
    public func controlAction(_ action: VideoControlAction) {
        setAction(action)
    }
}


