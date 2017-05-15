//
//  AudioDefaultValue.swift
//  VRClient
//
//  Created by 黄启明 on 2017/5/4.
//  Copyright © 2017年 黄启明. All rights reserved.
//

import UIKit

class AudioDefaultValue {
    static let `default`: AudioDefaultValue = AudioDefaultValue()
    private init() {}
    
    fileprivate let hiddenBackgroundImageKey: String = "isHiddenBackgroundImage"
    
    var isHiddenBackgroundImage: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: hiddenBackgroundImageKey)
        }
        
        get {
            if let val = UserDefaults.standard.value(forKey: hiddenBackgroundImageKey), let hidden = val as? Bool {
                return hidden
            }
            return true
        }
    }
    
}
