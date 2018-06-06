//
//  MGMovableVideoViewDelegate.swift
//  MGMovableVideoView
//
//  Created by Magical Water on 2018/5/17.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

protocol MGMovableVideoViewDelegate : class {

    weak var controlDelegate: MGMovableVideoControlDelegate? { get set }

    //大小改變, 需要重新配置各個元件的位置以及大小
    func boundsChange()

    //影片狀態改變
    func videoStatusChange(_ status: MGVideoStatus)
}

