//
//  IHTCLearnViewController.swift
//  iWuBi
//
//  Created by HTC on 2019/4/14.
//  Copyright © 2019 HTC. All rights reserved.
//

import UIKit
import JXPhotoBrowser

class IHTCLearnViewController: UIViewController {
    
    // MARK:- Lify Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- 懒加载
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
        tableView.estimatedRowHeight = 55
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var dataArray: Array<Dictionary<String, Array<Any>>> = {
        if let path = Bundle.main.path(forResource: "iWuBi_learning", ofType: "plist") {
            var data = NSArray.init(contentsOfFile: path)
            if let array = data as? Array<Dictionary<String, Array<Any>>> {
                return array
            }
            return Array()
        }
        return Array()
    }()
    
}


extension IHTCLearnViewController
{
    func setupUI() {
        view.addSubview(tableView)
        let constraintViews = [
            "tableView": tableView
        ]
        let vFormat = "V:|-0-[tableView]-0-|"
        let hFormat = "H:|-0-[tableView]-0-|"
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: vFormat, options: [], metrics: [:], views: constraintViews)
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: hFormat, options: [], metrics: [:], views: constraintViews)
        view.addConstraints(vConstraints)
        view.addConstraints(hConstraints)
        view.layoutIfNeeded()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

// MARK: Tableview Delegate
extension IHTCLearnViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dict = self.dataArray[section]
        let array = dict[Array(dict.keys).first!]
        return array!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dict = self.dataArray[section]
        return Array(dict.keys).first!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "IHTCLeaningVCViewCell")
        if (cell  == nil) {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "IHTCLeaningVCViewCell")
            cell!.accessoryType = .disclosureIndicator
            cell!.selectedBackgroundView = UIView.init(frame: cell!.frame)
            cell!.selectedBackgroundView?.backgroundColor = kColorAppOrange.withAlphaComponent(0.7)
            cell?.textLabel?.font = UIFont.systemFont(ofSize: DeviceType.IS_IPAD ? 20:16.5)
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: DeviceType.IS_IPAD ? 16:12.5)
            cell?.detailTextLabel?.sizeToFit()
        }
        
        let dict = self.dataArray[indexPath.section]
        let array = dict[Array(dict.keys).first!]
        let data = array![indexPath.row] as! Dictionary<String, String>
    
        cell!.textLabel?.text = data["title"]
        cell?.detailTextLabel?.text = (DeviceType.IS_IPAD ? data["content"]?.prefix(20) : data["content"]?.prefix(8))! + "..."
        #if targetEnvironment(macCatalyst)
        cell?.detailTextLabel?.text = String(data["content"]!.prefix(20))
        #endif
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dict = self.dataArray[indexPath.section]
        let array = dict[Array(dict.keys).first!]
        let data = array![indexPath.row] as! Dictionary<String, String>
        let type = data["type"]
        if type == "image" {
            let browser = JXPhotoBrowser()
            // 数据源
            browser.numberOfItems = {
                array!.count // 共有多少项
            }
            browser.reloadCellAtIndex = { context in
                let browserCell = context.cell as? JXPhotoBrowserImageCell
                // 每一项的图片对象
                let data = array![context.index] as! Dictionary<String, String>
                let imageName = data["content"]
                browserCell?.imageView.image = UIImage(named: imageName!)
            }
            // 指定打开图片浏览器时定位到哪一页
            browser.pageIndex = indexPath.row
            // 数字样式的页码指示器
            browser.pageIndicator = JXPhotoBrowserNumberPageIndicator()
            // 打开浏览器
            browser.show()
        } else {
            let vc = IHTCLearnDetailViewController()
            vc.title = data["title"]
            vc.dataDict = data
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
