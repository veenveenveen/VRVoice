//
//  AuthorityViewController.swift
//  VRClient
//
//  Created by 黄启明 on 2017/5/2.
//  Copyright © 2017年 黄启明. All rights reserved.
//

import UIKit

class AuthorityViewController: UIViewController {

    @IBOutlet weak var isHiddenBackgroundImageSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isHiddenBackgroundImageSwitch.isOn = AudioDefaultValue.default.isHiddenBackgroundImage

        view.backgroundColor = UIColor(white: 0.93, alpha: 0.5)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //取消按钮点击
    @IBAction func didTapCancelButton(_ sender: Any) {
        guard let master = masterParent else { return }
        master.attemptToCancelSetting()
    }
    //隐藏背景图片开关点击
    @IBAction func tapHideBackgroundImageSwitch(_ sender: Any) {
        guard let master = masterParent, let switcher = sender as? UISwitch else {
            return
        }
        AudioDefaultValue.default.isHiddenBackgroundImage = switcher.isOn
        master.updateBackgroundImage()
    }
}
