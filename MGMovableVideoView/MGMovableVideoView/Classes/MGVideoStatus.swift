//
//  MGVideoStatus.swift
//  MGMovableVideoView
//
//  Created by Magical Water on 2018/5/17.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

//影片狀態
public enum MGVideoStatus {
    case idle     //閒置中(包含尚未載入video, url)
    case loading  //載入影片url中
    case ready    //載入url成功, 可以準備播放
    case failed   //播放錯誤
    case playing  //播放中
    case stop     //停止播放(直撥沒有暫停)
    case complete //播放完成
}
