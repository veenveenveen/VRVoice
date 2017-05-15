//
//  AudioData.swift
//  VRClient
//
//  Created by 黄启明 on 2017/4/28.
//  Copyright © 2017年 黄启明. All rights reserved.
//

import Foundation

struct AudioData: Equatable {
    let filename: String
    let duration: TimeInterval
    let recordDate: Date
    var translation: String? = nil
    
    init(filename: String, duration: TimeInterval, recordDate: Date, translation: String? = nil) {
        self.filename = filename
        self.duration = duration
        self.recordDate = recordDate
        self.translation = translation
    }
    
   
}

func ==(lhs: AudioData, rhs: AudioData) -> Bool {
    return lhs.filename == rhs.filename && lhs.duration == rhs.duration && lhs.recordDate == rhs.recordDate
}

extension AudioData {
    var localURL: URL {
        return FileManager.dataURL(with: filename)
    }
    
    var data: Data? {
        return try? Data(contentsOf: localURL)
    }
}

extension FileManager {
    //保存录音文件的目录文件名
    static let dataDirectoryName = "audio_record_files"
    
    static var dataStorageDirectory: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(dataDirectoryName)
    }
    
    static func initAudioDataStorageDirectory() {
        if FileManager.default.fileExists(atPath: dataStorageDirectory.path) {
            return
        }
        do {
            //withIntermediateDirectories
            // YES 如果文件夹不存在，则创建， 如果存在表示可以覆盖
            // NO 如果文件夹不存在，则创建， 如果存在不可以覆盖
            try FileManager.default.createDirectory(at: dataStorageDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch  {
            print(self, #function, error.localizedDescription, "文件目录创建失败")
        }
    }
    
    static func dataURL(with filename: String) -> URL {
        return dataStorageDirectory.appendingPathComponent(filename)
    }
}

extension Date {
    //格式化日期作为文件名
    static var currentFilename: String {
        let formatter = DateFormatter()
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.dateFormat = "yyyyMMdd_HHmmssaaa"
        let dateString = formatter.string(from: Date())
        return dateString
    }
}

extension TimeInterval {
    var timeDescription: String {
        if self < 0 {
            return "--:--"
        }
        
        let _s: Int = 1
        let _m: Int = 60
        let _h: Int = 60 * 60
        let _d: Int = 24 * 60 * 60
        
        let timeDuration = Int(self)
        
        if timeDuration > _d {
            return "59:59:59"
        }
        else if timeDuration > _h {
            let time_h = timeDuration / _h
            let time_m = (timeDuration - _h * time_h) / _m
            let time_s = (timeDuration - _h * time_h - _m * time_m) / _s
            return String(format: "%02d", time_h) + ":" + String(format: "%02d", time_m) + ":" + String(format: "%02d", time_s)
        }
        else {
            let time_m = timeDuration / _m
            let time_s = (timeDuration - _m * time_m) / _s
            return String(format: "%02d", time_m) + ":" + String(format: "%02d", time_s)
        }
    }
}
