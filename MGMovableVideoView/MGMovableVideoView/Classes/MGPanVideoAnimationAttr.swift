//
//  MGPanVideoAnimationAttr.swift
//  MGMovableVideoView
//
//  Created by Magical Water on 2018/5/15.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

//變更裝載動畫需要參數的class
public struct MGPanVideoAnimationAttr {
    var inRect: CGRect? = nil

    var size: Scale

    //最大邊, 此參數只在 size = proportion 時有效
    var maxSide: CGFloat? = nil

    //位移x, 位移y
    var dx: CGFloat = 0
    var dy: CGFloat = 0

    //影片size參數
    enum Scale {
        case aspectFit  //較大邊依照比例填滿 inRect
        case proportion //讓整個view的size符合影片的比例, 但最大邊會縮到maxSize下
    }
}
