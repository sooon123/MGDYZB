//
//  HomeViewController.swift
//  MGDYZB
//
//  Created by ming on 16/10/25.
//  Copyright © 2016年 ming. All rights reserved.

//  简书：http://www.jianshu.com/users/57b58a39b70e/latest_articles
//  github:  https://github.com/LYM-mg
//


import UIKit

private let kTitlesViewH : CGFloat = 40

class HomeViewController: UIViewController {
    
    var isFirst: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        automaticallyAdjustsScrollViewInsets = false

        // 1.创建UI
        setUpMainView()
        
        
        // 2.监听点击状态栏回到顶部通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: ("scrollToTop"), name: KScrollTopWindowNotification, object: nil)
    }
    
    @objc func scrollToTop() {
//        HomeContentViewDidScroll(self.homeContentView, progress: 0, sourceIndex: 2, targetIndex: 0)
//        HomeTitlesViewDidSetlected(self.homeTitlesView, selectedIndex: 0)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // 第一次启动
        if (isFirst == false) {
             self.navigationController!.navigationBar.hidden = true
            let window = UIApplication.sharedApplication().keyWindow
            // 添加启动页的图片
            let welcomeImage = UIImageView(frame: window!.bounds)
            welcomeImage.image = getWelcomeImage()
            window!.addSubview(welcomeImage)
            window!.bringSubviewToFront(welcomeImage) // 把背景图放在最上层
            welcomeImage.alpha = 0.99 //这里alpha的值和下面alpha的值不能设置为相同的，否则动画相当于瞬间执行完，启动页之后动画瞬间消失。这里alpha设为0.99，动画就不会有一闪而过的效果，而是一种类似于静态背景的效果。设为0，动画就相当于是淡入的效果了。
            
            // UIViewAnimationOptionCurveEaseOut
            UIView.animateKeyframesWithDuration(2.5, delay: 0 , options: .CalculationModeCubic, animations: { () -> Void in
                welcomeImage.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
                //        welcomeImage.transform = CGAffineTransformMakeScale(1.3, 1.3)
                welcomeImage.alpha = 0.01
            }, completion: { (finished) -> Void in
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    self.navigationController!.navigationBar.hidden = false
                    welcomeImage.removeFromSuperview()
                })
            })
            isFirst = true
        }
    }
    /**
    *  获取启动页的图片
    */
    func getWelcomeImage() -> UIImage {
        let viewSize = UIApplication.sharedApplication().keyWindow!.bounds.size
        // 竖屏 UIInterfaceOrientationPortrait
        let viewOrientation = "Portrait"
        var launchImageName = ""
        
//        print(NSBundle.mainBundle().infoDictionary)
        let info = NSBundle.mainBundle().infoDictionary
        let imagesDict = info!["UILaunchImages"] as! [[String: AnyObject]]
        for dict in imagesDict {
            let imageSize = CGSizeFromString(dict["UILaunchImageSize"] as! String)
            if CGSizeEqualToSize(imageSize, viewSize) && viewOrientation == dict["UILaunchImageOrientation"] as! String {
                launchImageName = dict["UILaunchImageName"] as! String
            }
        }
        return UIImage(named: launchImageName)!
    }
    
    // MARK: - lazy
    private lazy var homeTitlesView: HomeTitlesView = { [weak self] in
        let titleFrame = CGRect(x: 0, y: kStatusBarH + kNavigationBarH, width: kScreenW, height: kTitlesViewH)
        let titles = ["推荐", "游戏", "娱乐", "趣玩"]
        let tsView = HomeTitlesView(frame: titleFrame, titles: titles)
        tsView.deledate = self
        return tsView
    }()
    private lazy var homeContentView: HomeContentView = { [weak self] in
        // 1.确定内容的frame
        let contentH = kScreenH - kStatusBarH - kNavigationBarH - kTitlesViewH - kTabbarH
        let contentFrame = CGRect(x: 0, y: kStatusBarH + kNavigationBarH+kTitlesViewH, width: kScreenW, height: contentH)
        
        // 2.确定所有的子控制器
        var childVcs = [UIViewController]()
        childVcs.append(RecommendViewController())
        childVcs.append(GameViewController())
        childVcs.append(AmuseViewController())
        childVcs.append(FunnyViewController())
        let contentView = HomeContentView(frame: contentFrame, childVcs: childVcs, parentViewController: self)
        contentView.delegate = self
        return contentView
    }()
}

// MARK: - 初始化UI
extension HomeViewController {
    private func setUpMainView() {
        setUpNavgationBar()
        view.addSubview(homeTitlesView)
        view.addSubview(homeContentView)
    }
    private func setUpNavgationBar() {
        // 1.设置左侧的Item
        navigationItem.leftBarButtonItem = UIBarButtonItem(imageName: "logo")
        
        // 2.设置右侧的Item
        let size = CGSize(width: 40, height: 40)
        let historyItem = UIBarButtonItem(imageName: "image_my_history", highImageName: "Image_my_history_click", size: size)
        let searchItem = UIBarButtonItem(imageName: "btn_search", highImageName: "btn_search_clicked", size: size)
        let qrcodeItem = UIBarButtonItem(imageName: "Image_scan", highImageName: "Image_scan_click", size: size)
        navigationItem.rightBarButtonItems = [historyItem, searchItem, qrcodeItem]
    }
}

// MARK:- 遵守 HomeTitlesViewDelegate 协议
extension HomeViewController : HomeTitlesViewDelegate {
    func HomeTitlesViewDidSetlected(homeTitlesView: HomeTitlesView, selectedIndex: Int) {
        homeContentView.setCurrentIndex(selectedIndex)
    }
}


// MARK:- 遵守 HomeContentViewDelegate 协议
extension HomeViewController : HomeContentViewDelegate {
    func HomeContentViewDidScroll(contentView: HomeContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        homeTitlesView.setTitleWithProgress(progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
}

