//
//  ViewController.swift
//  XZRefresh
//
//  Created by admin on 2018/1/2.
//  Copyright © 2018年 XZ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshCotrol:XZRefreshControl = XZRefreshControl()
    /**
     系统刷新控件存在的问题
     1.如果用户不放手，下拉到一定程度都会自动进入刷新状态，浪费流量
     2.如果程序主动调用 beginRefeshing，不显示菊花！Xcode 8 出现的！
     
     自定义刷新控件，最重要解决的，就是用户放手，再刷新！
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置 contentInset 88 64
//        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
//        tableView.contentInset = UIEdgeInsets(top: -88, left: 0, bottom: 0, right: 0)
        
        // 添加刷新控件
        tableView.addSubview(refreshCotrol)
//        tableView.delegate = self
        // 监听方法
        refreshCotrol.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        // 主动调用刷新控件
        loadData()
    }
    
    @objc func loadData() {
        print("开始刷新")
        refreshCotrol.beginRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            print("结束刷新")
            
            self.refreshCotrol.endRefreshing()
        }
    }
}

//extension ViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 20
//    }
//
//    private func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        var cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath)
//
//        if cell == nil {
//            cell = UITableViewCell.init(style: .default, reuseIdentifier: "id")
//        }
//
//        cell.textLabel?.text = "第 \(indexPath.row) 行"
//
//        return cell
//    }
//
//
//}

