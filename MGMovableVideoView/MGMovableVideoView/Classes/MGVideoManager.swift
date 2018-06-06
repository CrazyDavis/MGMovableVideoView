//
//  MGVideoManager.swift
//  MGMovableVideoView
//
//  Created by Magical Water on 2018/5/15.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import AVKit

//播放影片相關管理
class MGVideoManager: NSObject {

    //播放器相關
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var playerItem: AVPlayerItem!

    //player要 attach在哪個 view
    private var attachView: UIView

    //現在的影片狀態
    private var status: MGVideoStatus = .idle {
        didSet { videoManagerDelegate?.statusChange(status) }
    }

    //影片 url
    private var videoURL: URL?

    //播放狀態回調
    weak var videoManagerDelegate: VideoManagerDelegate?

    init(_ attach: UIView) {
        self.attachView = attach
        super.init()
    }

    //設定影片串流url
    //設定前需要假如影片正在播放, 需要先行停止
    func setVideoURL(url: URL) {
        stopVideo()
        playerLayer?.opacity = 0.01
        videoURL = url
    }

    //得到影片串流url
    //設定前需要假如影片正在播放, 需要先行停止
    func getVideoURL() -> URL? {
        return videoURL
    }

    //讓影片符合 attach View
    func videoFillAttach() {
        if playerItem == nil {
            return
        }
        print("影片size = \(playerItem.presentationSize)")
        videoManagerDelegate?.videoSize(playerItem.presentationSize)
//        let screenWidth = UIScreen.main.bounds.width
//        let scaleMultiple = screenWidth / playerItem.presentationSize.width
//        print("影片寬度倍數 = \(scaleMultiple)")
//        let videoHeight = playerItem.presentationSize.height * scaleMultiple
//        print("影片最終設定高度 = \(videoHeight)")

        self.playerLayer.frame = attachView.bounds
    }

    //播放任何影片之前, 須先呼叫此方法讓影片ready之後才能呼叫 playVideo 開始播放
    func preparePlay() {
        //先檢查 video url 是否已設定
        guard let videoURL = videoURL else {
            print("video 網址尚未設定, 無法準備")
            return
        }

        //狀態更改為載入url讀取中
        status = .loading

        //先取消註冊所有的監聽
        unregisterListener()
        self.playerItem = AVPlayerItem(url: videoURL)

        //在player 初始化之後開始加入
        registerListener()

        if player != nil {
            player.replaceCurrentItem(with: playerItem)
        } else {
            self.player = AVPlayer(playerItem: playerItem)

            //添加到界面上, 並且寬高符合 attach View
            self.playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = attachView.bounds
            self.attachView.layer.insertSublayer(playerLayer, at: 0)
            playerLayer.backgroundColor = UIColor.black.cgColor
        }
    }

    //當前影片是否全螢幕
    func isVideoRotated() -> Bool {
        guard let playerLayer = playerLayer else {
            return false
        }
        return !playerLayer.affineTransform().isIdentity
    }

    //開始播放影片, 只有在狀態是 ready 時才可以播放
    func playVideo() {
        playerLayer?.opacity = 1
        status = .playing
        player.play()
    }

    //停止影片
    func stopVideo() {
        status = .stop
        player?.pause()
    }

    //影片進行旋轉, 並且重新設置寬高符合attach view
    //通常用在全螢幕
    func rotateVideo() {
        guard let playerLayer = playerLayer else {
            return
        }
        print("播放器旋轉")
        //先旋轉 播放器
        playerLayer.setAffineTransform(CGAffineTransform(rotationAngle: .pi / 2))
        playerLayer.frame = attachView.bounds
    }

    //回復原來方向, 並且重新設置寬高符合 attach view
    func normalVideo() {
        guard let playerLayer = playerLayer else {
            return
        }
        print("播放器轉回")
        playerLayer.setAffineTransform(.identity)
        playerLayer.frame = attachView.bounds
    }

    //將影片清除
    func cleanVideo() {
        if let p = player {
            p.replaceCurrentItem(with: nil)
        }
        if let pl = playerLayer {
            pl.removeFromSuperlayer()
        }
        player = nil
        playerLayer = nil
    }

    func isVideoPlaying() -> Bool {
        return status == .playing
    }

    //影片播放結束了
    @objc private func playEnd() {
        status = .complete
    }


    //監聽的回傳
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem, let keyPath = keyPath else { return }

        switch keyPath {
        case PayerItemKeyPath.bufferEmpty: // 緩衝區快不夠了
            print("緩衝區快不夠了")
            //            nowStatus = playerItem.isPlaybackBufferEmpty ? .bufferEmpty : .bufferFull
            break

        case PayerItemKeyPath.bufferFull: // 缓冲區已經滿了, 可以正常播放
            print("緩衝區快充足")
            //            nowStatus = playerItem.isPlaybackBufferFull ? .bufferFull : .bufferEmpty
            break

        case PayerItemKeyPath.loadedTimeRanges: // 監聽緩衝進度
            //                        print("設定狀態: buffer")
            break

        case PayerItemKeyPath.status: // 監聽影片狀態改變, 在影片攝製了url需要在此等待回調
            print("設定狀態: 狀態改變 = \(playerItem.status)")
            switch playerItem.status {
            case .readyToPlay: //可以準備好播放了
                // 只有在这个状态下才能播放
                status = .ready
            case .failed: //加載異常, 無法播放
                status = .failed
                if let ex = playerItem.error {
                    print("播放異常: \(ex)")
                } else {
                    print("播放異常")
                }

            case .unknown:
                print("未知原因無法播放")
                status = .failed

            }
            break

        case PayerItemKeyPath.presentationSize: // 監聽影片size

            //如果得到的 size 皆為 0, 不做任何動作
            //如果當前的狀態處於全螢幕, 只要設定 compressView 的 bound即可
            if playerItem.presentationSize == CGSize.zero {
                return
            }
            videoFillAttach()
            break

        default:
            break
        }

    }

}

extension MGVideoManager {

    //使用KVO觀察播放器的相關數值
    struct PayerItemKeyPath {
        static let bufferEmpty     : String = "isPlaybackBufferEmpty"  // 监听缓冲是否快播放完畢了
        static let bufferFull      : String = "isPlaybackBufferFull"   // 监听缓冲是否已經完全載好了
        static let loadedTimeRanges: String = "loadedTimeRanges"       // 监听缓冲进度改变
        static let status          : String = "status"                 // 监听状态改变
        static let presentationSize: String = "presentationSize"       // 監聽影片size
    }

}

extension MGVideoManager {
    //註冊播放相關監聽器
    private func registerListener() {
        // 监听缓冲是否快播放完畢了
        playerItem.addObserver(self, forKeyPath: PayerItemKeyPath.bufferEmpty, options: NSKeyValueObservingOptions.new, context: nil)
        // 监听缓冲是否已經完全載好了
        playerItem.addObserver(self, forKeyPath: PayerItemKeyPath.bufferFull, options: NSKeyValueObservingOptions.new, context: nil)
        // 监听缓冲进度改变
        playerItem.addObserver(self, forKeyPath: PayerItemKeyPath.loadedTimeRanges, options: NSKeyValueObservingOptions.new, context: nil)
        // 监听状态改变
        playerItem.addObserver(self, forKeyPath: PayerItemKeyPath.status, options: NSKeyValueObservingOptions.new, context: nil)
        // 監聽影片size
        playerItem.addObserver(self, forKeyPath: PayerItemKeyPath.presentationSize, options: [.initial, .new], context: nil)

        //播放結束回傳監聽
        NotificationCenter.default.addObserver(self, selector: #selector(playEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    //取消註冊播放相關監聽器
    private func unregisterListener() {
        if let p = playerItem {
            p.removeObserver(self, forKeyPath: PayerItemKeyPath.bufferEmpty)
            p.removeObserver(self, forKeyPath: PayerItemKeyPath.bufferFull)
            p.removeObserver(self, forKeyPath: PayerItemKeyPath.loadedTimeRanges)
            p.removeObserver(self, forKeyPath: PayerItemKeyPath.status)
            p.removeObserver(self, forKeyPath: PayerItemKeyPath.presentationSize)
        }
        playerItem = nil
    }
}


//播放回掉
protocol VideoManagerDelegate: class {
    //狀態變更
    func statusChange(_ status: MGVideoStatus)

    //影片寬高回傳
    func videoSize(_ size: CGSize)
}
