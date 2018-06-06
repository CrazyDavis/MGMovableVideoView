//
//  MGMovableVideoControlDelegate.swift
//  MGMovableVideoView
//
//  Created by Magical Water on 2018/5/18.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

public protocol MGMovableVideoControlDelegate: class {
    func controlAction(_ action: VideoControlAction)
}

public enum VideoControlAction {
    case play   //開始播放
    case stop   //停止播放
    case pause  //暫停播放
    case normal //螢幕大小(一般)
    case full   //螢幕大小(全螢幕)
}
