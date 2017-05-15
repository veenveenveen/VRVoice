//
//  MasterViewController.swift
//  VRClient
//
//  Created by 黄启明 on 2017/4/28.
//  Copyright © 2017年 黄启明. All rights reserved.
//

import UIKit

extension AuthorityViewController {
    var masterParent: MasterViewController? {
        return parent as? MasterViewController
    }
}

extension DashboardViewController {
    var masterParent: MasterViewController? {
        return parent as? MasterViewController
    }
}

extension RecordListViewController {
    var masterParent: MasterViewController? {
        return parent as? MasterViewController
    }
}

class MasterViewController: UIViewController {
    
    //背景图片
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var recordListContainer: UIView!
    @IBOutlet weak var dashboardContainer: UIView!
    @IBOutlet weak var authorityContainer: UIView!
   
    @IBOutlet weak var topAuthorityConstraint: NSLayoutConstraint!
    @IBOutlet weak var topDashboardConstraint: NSLayoutConstraint!
    
    var sandClockContainerView: UIView!
    var sandClockView: SandClockView!
    
    var audioOperator: AudioOperator!
    
    var filename: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topDashboardConstraint.constant = Constants.show_dashboard_button
        
        setupClockView()
        
        updateBackgroundImage()
        
        audioOperator = AudioOperator()
        
        recordList?.reloadDataSource(items: CoreDataManager.default.loadLocalData())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //设置按钮点击
    @IBAction func didTapSettingButton(_ sender: Any) {
        showAuthority()
    }
    
    ///加载动画
    fileprivate func setupClockView() {
        sandClockContainerView = UIView(frame: view.bounds)
        sandClockContainerView.backgroundColor = UIColor.clear
        
        sandClockView = SandClockView(frame: CGRect(x: 0, y: 0, width: 160, height: 160))
        
        sandClockContainerView.center = view.center
        sandClockView.center = sandClockContainerView.center
        
        sandClockContainerView.addSubview(sandClockView)
        view.addSubview(sandClockContainerView)
        
        sandClockContainerView.isHidden = true
    }
    
    func showSandClockWith(text: String?) {
        sandClockView.showAnimationWith(text: "正在识别...")
        sandClockContainerView.isHidden = false
    }
    
    func removeLoadingAnimation() {
        sandClockView.removeAnimation()
        sandClockContainerView.isHidden = true
    }
    
}

extension MasterViewController {
    //修改背景图片
    func updateBackgroundImage() {
        backgroundImageView.isHidden = AudioDefaultValue.default.isHiddenBackgroundImage
    }
    //显示录音按钮
    func showRecordButton() {
        topDashboardConstraint.constant = Constants.show_dashboard_button
        view.layoutIfNeeded()
    }
    
    ///dashboard 面板
    //点击录音按钮后的操作
    func startRecordingAndShowDashboard() {
        
        let filename = "\(Date.currentFilename)"//不加后缀名
        let storageURL = FileManager.dataURL(with: filename)
        
        self.filename = filename
        
        print(storageURL)
        
        audioOperator.startRecording(filename: filename, storageURL: storageURL)
        showDashboardFully()
    }
    ///录音完成后的操作
    func didFinishedRecording(with duration: TimeInterval) {
        audioOperator.stopRecording()
        
        let item = AudioData(filename: filename!, duration: duration, recordDate: Date())
        
        recordList?.insertAudioItem(item)
        CoreDataManager.default.insert(item: item)//core data
        recordList?.recordCollectionView.reloadData()
        
        //识别
        recognizeVoice(with: nil)/////
    }
    
    //识别
    func recognizeVoice(with data: Data?) {
        showSandClockWith(text: "正在识别")
        perform(#selector(test), with: nil, afterDelay: 5)
        
    }
    
    @objc fileprivate func test() {
        sandClockView.completeAnimation()
        
        UIView.animate(withDuration: 0.5, delay: 1, options: [UIViewAnimationOptions.curveEaseInOut], animations: {
            self.sandClockContainerView.alpha = 0
        }) { (finished) in
            self.removeLoadingAnimation()
            self.sandClockContainerView.alpha = 1
        }
    }

    
    ///取消录音
    func cancelRecording() {
        audioOperator.cancelRecording()
    }
    
    func hideDashboard() {
        hideDashboardFully()
    }
    
    ////recordListViewController 面板
    func playItem(with data: AudioData) {
        audioOperator.startPlaying(url: data.localURL)
    }
    func stopItem() {
        audioOperator.stopPlaying()
    }
    
    //隐藏设置界面
    func attemptToCancelSetting() {
        hideAuthority()
    }
}

extension MasterViewController {
    struct Constants {
        static let show_authority: CGFloat = 0
        static let hide_authority: CGFloat = UIScreen.main.bounds.size.height
        
        static let show_dashboard_button: CGFloat = -120
        static let show_dashboard_fully: CGFloat = -280
        static let hide_dashboard_fully: CGFloat = 0
    }
    ///
    fileprivate func showAuthority() {
        UIView.animate(withDuration: 0.25) {
            self.topAuthorityConstraint.constant = Constants.show_authority
            self.view.layoutIfNeeded()
        }
    }
    fileprivate func hideAuthority() {
        UIView.animate(withDuration: 0.25) {
            self.topAuthorityConstraint.constant = Constants.hide_authority
            self.view.layoutIfNeeded()
        }
    }
    ///
    fileprivate func showDashboardFully() {
        UIView.animate(withDuration: 0.25) { 
            self.topDashboardConstraint.constant = Constants.show_dashboard_fully
            self.view.layoutIfNeeded()
        }
    }
    fileprivate func hideDashboardFully() {
        UIView.animate(withDuration: 0.25) { 
            self.topDashboardConstraint.constant = Constants.show_dashboard_button
            self.view.layoutIfNeeded()
        }
    }
    
}

extension MasterViewController {
    var recordList: RecordListViewController? {
        return childViewControllers.filter{ $0 is RecordListViewController }.first as? RecordListViewController
    }
}
