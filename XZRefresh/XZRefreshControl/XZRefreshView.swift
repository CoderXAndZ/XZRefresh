//
//  XZRefreshView.swift
//  XZRefresh
//
//  Created by admin on 2018/1/3.
//  Copyright © 2018年 XZ. All rights reserved.
//  刷新视图 - 负责 刷新 相关的 UI 显示和动画

import UIKit

class XZRefreshView: UIView {
    /// 刷新状态
    /**
     iOS 系统中 UIView 封装的旋转动画
     - 默认是顺时针旋转
     - 就近原则
     - 要想实现同方向旋转，需要调整一个 非常小的数字(近)
     - 如果想实现 360 旋转，需要核心动画 CABaseAnimation
     */
    var refreshState: XZRefreshState = .Normal {
        didSet {
            switch refreshState {
            case .Normal:
                // 恢复状态
                imgIcon?.isHidden = false
                indicator?.stopAnimating()
                
                labelTip?.text = "继续拖拽..."
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.imgIcon?.transform = CGAffineTransform.identity
                })
            case .Pulling:
                labelTip?.text = "再向下拖拽..."
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.imgIcon?.transform = CGAffineTransform(rotationAngle: (.pi - 0.001))
                })
            case .WillRefresh:
                labelTip?.text = "正在刷新中..."
                
                // 隐藏提示图标
                imgIcon?.isHidden = true
                // 显示菊花
                indicator?.startAnimating()
            }
        }
    }
    
    /// 父视图高度 - 刷新控件不需要关心当前具体的刷新视图是谁！
    var parentViewHeight: CGFloat = 0
    
    /// 指示器
    @IBOutlet weak var imgIcon: UIImageView?
    /// 提示图标
    @IBOutlet weak var labelTip: UILabel?
    /// 提示标签
    @IBOutlet weak var indicator: UIActivityIndicatorView?
    
    class func refreshView() -> XZRefreshView {
        // XZRefreshView XZPictureRefreshView
        let nib = UINib(nibName: "XZMTRefreshView", bundle: nil)
        
        return nib.instantiate(withOwner: nil, options: nil)[0] as! XZRefreshView
    }
    
}
