//
//  XZRefreshControl.swift
//  XZSwfitWB
//
//  Created by admin on 2018/1/2.
//  Copyright © 2018年 XZ. All rights reserved.
//  刷新控件 - 负责 刷新 相关的'逻辑'处理

import UIKit

/// 刷新状态切换的临界点 -- 箭头和图片
//private let XZRefreshOffset: CGFloat = 60
/// 刷新状态切换的临界点 -- 袋鼠的
private let XZRefreshOffset: CGFloat = 126

/// 刷新状态
///
/// - Normal:      普通状态，什么都不做
/// - Pulling:     超过临界点，如果放手，开始刷新
/// - WillRefresh: 用户超过临界点，并且放手
enum XZRefreshState {
    case Normal
    case Pulling
    case WillRefresh
}

class XZRefreshControl: UIControl {
    
    /// MARK: - 属性
    /// 刷新控件额父视图，下拉刷新控件应该适用于 UITableView / UICollectionView
    private weak var scrollView: UIScrollView?
    
    /// 刷新视图
    private lazy var refreshView: XZRefreshView = XZRefreshView.refreshView()
    
    /// MARK: - 构造函数
    init() {
        super.init(frame: CGRect())
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    /**
     willMove addSubview 方法会调用
     - 当添加到父视图的时候，newSuperview 是父视图
     - 当父视图被移除，newSuperview 是nil
     */
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        print(newSuperview)
        
        // 判断父视图的类型
        guard let sv = newSuperview as? UIScrollView else {
            return
        }
        
        // 记录父视图
        scrollView = sv
        
        // KVO监听父视图的 contentOffset
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
    }
    
    // 本视图从父视图上移除
    // 提示：所有的下拉刷新框架都是监听父视图的 contentOffset
    // 所有的框架的 KVO 监听实现思路
    override func removeFromSuperview() {
        // superView 还存在
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        
        super.removeFromSuperview()
        
        // superView 不存在
    }
    
    // 所有 KVO 方法会统一调用此方法
    // 在程序中，通常只监听某一个对象的某几个属性，如果属性太多，方法会很乱！
    // 观察者模式，在不需要的时候，都需要释放
    // - 通知中心：如果不释放，什么也不会发生，但是会有内存泄露，会有多次注册的可能！
    // - KVO：如果不释放，会崩溃！
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // Optional((0.0, -88.0))
        // contentOffset 的 y 值跟 contentInset 的 top 有关
        print(scrollView?.contentOffset)
        
        guard let sv = scrollView else {
            return
        }
        
        // 初始高度就应该是 0
        let height = -(sv.contentInset.top + sv.contentOffset.y)
        
        print("top: \(sv.contentInset.top) y: \(sv.contentOffset.y) 高度:  \(height)")
        
        if height < 0 {
            return
        }
        
        print(height)
        
        // 可以根据高度设置刷新控件的 frame
        self.frame = CGRect(x: 0,
                            y: -height,
                            width: sv.bounds.width,
                            height: height)
        
        // --- 传递父视图高度 88 导航栏的高度
        refreshView.parentViewHeight = height - 88
        
        // 判断临界点 - 只需要判断一次
        if sv.isDragging {
            if height > XZRefreshOffset && (refreshView.refreshState == .Normal){
                print("放手刷新 \(height)")
                refreshView.refreshState = .Pulling
            }else if height <= XZRefreshOffset && (refreshView.refreshState == .Pulling) {
                print("在拖拽... \(height)")
                refreshView.refreshState = .Normal
            }
        }else {
            // 放手刷新 - 判断是否超过临界点
            if refreshView.refreshState == .Pulling {
                print("开始准备刷新 \(height)")
                
                beginRefreshing()
                
                // 发送刷新数据事件
                sendActions(for: .valueChanged)
            }
        }
    }
    
    /// 开始刷新
    func beginRefreshing() {
        print("开始刷新")
        
        // 判断父视图
        guard let sv = scrollView else {
            return
        }
        
        // 判断是否正在刷新，如果正在刷新，直接返回
        if refreshView.refreshState == .WillRefresh {
            return
        }
        
        // 刷新结束之后，将 状态 修改为 .Normal 才能够继续响应刷新
        // 设置刷新视图的状态
        refreshView.refreshState = .WillRefresh
        
        // 调整表格的间距 - 让整个刷新视图能够显示出来
        // 解决方法：修改表格的 contentInset
        var inset = sv.contentInset
        inset.top += XZRefreshOffset
        
        sv.contentInset = inset
        
        // 设置刷新视图的父视图高度
        refreshView.parentViewHeight = XZRefreshOffset
    }
    
    /// 结束刷新
    func endRefreshing() {
        print("结束刷新")
        
        guard let sv = scrollView else {
            return
        }
        
        // 判断状态，是否正在刷新，如果不是，直接返回
        if refreshView.refreshState != .WillRefresh {
            return
        }
        
        // 恢复刷新视图的状态
        refreshView.refreshState = .Normal
        
        // 恢复表格视图的 contentInset
        var inset = sv.contentInset
        inset.top -= XZRefreshOffset
        
        sv.contentInset = inset
    }

}

extension XZRefreshControl {
    
    private func setupUI() {
        backgroundColor = superview?.backgroundColor
        
//        // 设置超出边界不显示
//        clipsToBounds = true
        
        // 添加刷新视图 - 从 xib 加载出来，默认是 xib 中指定的宽高
        addSubview(refreshView)
        
        // 自动布局 - 设置 xib 控件的自动布局，需要指定宽高约束
        // 一定要会原生的写法，因为：如果自己开发框架，不能用任何的自动布局框架！
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.width))
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.height))
    }
    
}
