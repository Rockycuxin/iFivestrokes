//
//  IHTC98WordViewController.swift
//  iWuBi
//
//  Created by HTC on 2017/4/8.
//  Copyright © 2017年 iHTCboy. All rights reserved.
//

import UIKit

class IHTC98WordViewController: ITBasePushTransitionVC
{
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置 UI 界面
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK:- 懒加载
    fileprivate var titles = IHTCModel.shared.tagsArray
    
    fileprivate lazy var pageTitleView: ITPageTitleView = {
        var titleFrame = CGRect(x: 0, y: kStatusBarH + kNavBarH, width: kScreenW, height: kTitleViewH)
        #if targetEnvironment(macCatalyst)
            titleFrame.origin.y = titleFrame.origin.y + 20
        #endif
        let titleView = ITPageTitleView(frame: titleFrame, titles: self.titles)
        titleView.delegate = self
        return titleView
    }()
    
    fileprivate lazy var pageContentView: ITPageContentView = {[weak self] in
        // 1. 确定内容 frame
        let contentH = kScreenH - kStatusBarH - kNavBarH - kHomeIndcator
        var contentFrame = CGRect(x: 0, y: kStatusBarH + kNavBarH + kTitleViewH, width: kScreenW, height: contentH)
        #if targetEnvironment(macCatalyst)
            contentFrame.origin.y = contentFrame.origin.y + 20
            contentFrame.size.height = contentFrame.size.height + 1024
        #endif
        // 2. 确定所有控制器
        let counts = 0
        var childVcs = [UIViewController]()
        if let counts = self?.titles.count {
            for i in 0..<counts {
                let vc = IHTCWordListViewController()
                vc.title = self?.titles[i]
                childVcs.append(vc)
            }
        }
        
        let contentView = ITPageContentView(frame: contentFrame, childVcs: childVcs, parentVc: self)
        contentView.delegate = self
        return contentView
        }()
    
    @IBAction func clickedSearchItem(_ sender: Any) {
        let vc = IHTCSearchViewController()
        vc.is86Word = false
        let navi = UINavigationController.init(rootViewController: vc)
        navi.navigationBar.isHidden = true
        self.present(navi, animated: true, completion: nil)
    }
}


// MARK:- 设置 UI
extension IHTC98WordViewController {
    fileprivate func setUpUI() {
        #if !targetEnvironment(macCatalyst)
        // 0. 不允许系统调整 scrollview 内边距
        automaticallyAdjustsScrollViewInsets = false
        #endif
        
        // 1. 添加 titleview
        view.addSubview(pageTitleView)
        
        // 2. 添加 contentview
        view.addSubview(pageContentView)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

// MARK:- pageTitleViewDelegate
extension IHTC98WordViewController: ITPageTitleViewDelegate {
    func pageTitleView(pageTitleView: ITPageTitleView, didSelectedIndex index: Int) {
        pageContentView.scrollToIndex(index: index)
        self.selectTitleIndex = index
    }
}

// MARK:- pageContentViewDelegate
extension IHTC98WordViewController: ITPageContentViewDelegate {
    func pageContentView(pageContentView: ITPageContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        pageTitleView.setTitleWithProgerss(sourceIndex: sourceIndex, targetIndex: targetIndex, progress: progress)
        self.selectTitleIndex = targetIndex
    }
}

