//
//  XZMTRefreshView.swift
//  XZRefresh
//
//  Created by admin on 2018/1/4.
//  Copyright © 2018年 XZ. All rights reserved.
//

import UIKit

/// 袋鼠的图片 center 的 Y 减少的值
private let kangarooCenterYOffset: CGFloat = 35

class XZMTRefreshView: XZRefreshView {
    
    /// 父视图高度
    override var parentViewHeight: CGFloat {
        didSet {
            print("父视图高度 \(parentViewHeight)")

            if parentViewHeight < kangarooCenterYOffset {
                return
            }
            
            // 高度:   35  -> 126
            // scale: 0.2 -> 1
            // 高度差 / 最大高度差
            // 35 == 1 -> 0.2
            // 126 == 0 -> 1
            var scale: CGFloat
            if parentViewHeight > 126 {
                scale = 1
            }else {
                scale = 1 - (126 - parentViewHeight) / (126 - 35)
            }
            
            imgKangarooView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    override func awakeFromNib() {
        // 1.房子
        let bImage1 = #imageLiteral(resourceName: "icon_building_loading_1")
        let bImage2 = #imageLiteral(resourceName: "icon_building_loading_2")
        // 房子gif
        imgBuildingView.image = UIImage.animatedImage(with: [bImage1,bImage2], duration: 0.5)
        
        // 2.地球
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        // 2 * Double.pi 顺时针转 -2 * Double.pi 逆时针转
        anim.toValue = -2 * Double.pi
        anim.repeatCount = MAXFLOAT
        anim.duration = 3
        anim.isRemovedOnCompletion = false
        
        imgEarthIconView.layer.add(anim, forKey: nil)
        
        // 3.袋鼠:先设置锚点，然后设置 frame 或 center
        // 0> 设置袋鼠动画
        let kImage1 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_1")
        let kImage2 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_2")
        imgKangarooView.image = UIImage.animatedImage(with: [kImage1, kImage2], duration: 0.5)
        
        // 1>设置锚点
        imgKangarooView.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        // 2>设置center
        let x = self.bounds.width * 0.5
        let y = self.bounds.height - kangarooCenterYOffset
        imgKangarooView.center = CGPoint(x: x, y: y)
        
        imgKangarooView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
    }
    
    /// 房子图片
    @IBOutlet weak var imgBuildingView: UIImageView!
    /// 地球图片
    @IBOutlet weak var imgEarthIconView: UIImageView!
    /// 袋鼠
    @IBOutlet weak var imgKangarooView: UIImageView!
    
}
