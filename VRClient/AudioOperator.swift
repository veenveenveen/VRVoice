//
//  AudioOperator.swift
//  VRClient
//
//  Created by 黄启明 on 2017/5/4.
//  Copyright © 2017年 黄启明. All rights reserved.
//

//音频录制和播放

import UIKit
import AVFoundation

class AudioOperator: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    fileprivate var audioRecorder: AVAudioRecorder?
    fileprivate var audioPalyer: AVAudioPlayer?
    
    let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    var playCompleted:( () -> Void )?
    
    //录音文件设置
    fileprivate let audioSetting: [String: AnyObject] = [
        //设置录音格式
        AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
        //设置录音采样率，8000是电话采样率，对于一般录音已经够了
        AVSampleRateKey: NSNumber(value: 8000),
        //设置通道,这里采用单声道
        AVNumberOfChannelsKey: NSNumber(value: 1),
        //每个采样点位数,分为8、16、24、32
        AVLinearPCMBitDepthKey: NSNumber(value: 8),
        //是否使用浮点数采样
        AVLinearPCMIsFloatKey: NSNumber(value: true)
        //....其他设置等
    ]
    
    override init() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            print("setCategory fail")
        }
        
    }
    
    //recorder record, stop, cancel
    @discardableResult func startRecording(filename: String, storageURL: URL) -> Bool {
        
        stopRecording()
        
        do {
            try audioRecorder = AVAudioRecorder(url: storageURL, settings: audioSetting)
        } catch  {
            print(self, #function, error.localizedDescription)
            return false
        }
        
        audioRecorder!.delegate = self
        audioRecorder!.isMeteringEnabled = true//如果要监控声波则必须设置为YES
        
        if !audioRecorder!.record() {
            print("didn't record")
            return false
        }
        
        return true
    }
    
    func stopRecording() {
        guard let r = audioRecorder, r.isRecording else { return }
        r.stop()
    }
    
    func cancelRecording() {
        guard let r = audioRecorder, r.isRecording else { return }
        r.delegate = nil
        r.stop()
        r.deleteRecording()
    }
    
    //player play, stop
    @discardableResult func startPlaying(url: URL) -> Bool {
        do {
            try audioPalyer = AVAudioPlayer(contentsOf: url)
        } catch  {
            print(self, #function, error.localizedDescription)
            return false
        }
        
        audioPalyer!.delegate = self
        
        if !audioPalyer!.play() {
            print("didn't play")
            return false
        }
        
        return true
    }
    
    func stopPlaying() {
        guard let p = audioPalyer, p.isPlaying else { return }
        p.stop()
    }
}

//代理方法实现
extension AudioOperator {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playCompleted!()
    }
}
