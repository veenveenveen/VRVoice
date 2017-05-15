//
//  DashboardViewController.swift
//  VRClient
//
//  Created by 黄启明 on 2017/5/2.
//  Copyright © 2017年 黄启明. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var topRecordConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConsoleConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var recordContainerView: CornerRectView!
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var conscleContainerView: CornerRectView!///
    @IBOutlet weak var consoleTitleLabel: UILabel!
    @IBOutlet weak var consoleTimeLabel: UILabel!
    
    @IBOutlet weak var buttonContainerView: CornerRectView!///
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    
    var timer: Timer!
    var startTime: TimeInterval?
    var currentTime: TimeInterval?
    var durationTime: TimeInterval?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        initializeConstraint()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //初始化面板约束
    fileprivate func initializeConstraint() {
        topRecordConstraint.constant = Constant.show_recordButton
        topConsoleConstraint.constant = Constant.hide_console
        view.layoutIfNeeded()
    }
    
//MARK: - 面板按钮点击事件
    
    //开始倾听
    @IBAction func startRecording(_ sender: Any) {
        print("start")
        
        guard let master = masterParent else { return }
        master.startRecordingAndShowDashboard()
        animationForShowDashboard()
        
        startTime = Date().timeIntervalSince1970
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    @objc fileprivate func updateTimeLabel() {
        guard let startTime = startTime else {
            print("startTime nil")
            return
        }
        currentTime = Date().timeIntervalSince1970
        durationTime = currentTime! - startTime
        consoleTimeLabel.text = durationTime!.timeDescription
    }
    
    //取消
    @IBAction func didTapCancelButton(_ sender: Any) {
        print("cancel")
        
        timer.invalidate()
        
        guard let master = masterParent else { return }
        master.cancelRecording()
        master.hideDashboard()
        animationForHideDashboard()
    }
    //录音完成
    @IBAction func didTapFinishButton(_ sender: Any) {
        print("finished")
        
        timer.invalidate()
        
        guard let master = masterParent else { return }
        master.hideDashboard()
        
        animationForHideDashboard()
        master.didFinishedRecording(with: durationTime!)
    }
}

///面板动画
extension DashboardViewController {
    
    struct Constant {
        static let show_recordButton: CGFloat = 10
        static let show_console: CGFloat = 10
        static let hide_console: CGFloat = 150
    }

    //面板 显示动画
    fileprivate func animationForShowDashboard() {
        UIView.animate(withDuration: 0.25) {
            self.recordContainerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.topConsoleConstraint.constant = Constant.show_console
            self.view.layoutIfNeeded()
        }
    }
    //面板 隐藏动画
    fileprivate func animationForHideDashboard() {
        UIView.animate(withDuration: 0.25) {
            self.recordContainerView.transform = CGAffineTransform.identity
            self.topConsoleConstraint.constant = Constant.hide_console
            self.view.layoutIfNeeded()
        }
    }

}

