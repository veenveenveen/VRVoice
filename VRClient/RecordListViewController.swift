//
//  RecordListViewController.swift
//  VRClient
//
//  Created by 黄启明 on 2017/4/28.
//  Copyright © 2017年 黄启明. All rights reserved.
//

import UIKit

class RecordListCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: CornerRectView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var translateLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.clear
    }
    
    func addTarget(_ target: Any?, deleteAction: Selector, playAction: Selector, sendAction: Selector, event: UIControlEvents) {
        deleteButton.addTarget(target, action: deleteAction, for: event)
        playButton.addTarget(target, action: playAction, for: event)
        sendButton.addTarget(target, action: sendAction, for: event)
    }
    
    
    func updatePlayButtonImage(with name: String) {
        playButton.setImage(UIImage(named: name), for: .normal)
    }

}

class RecordListHeader: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
}

class RecordListFooter: UICollectionReusableView {
    
    @IBOutlet weak var detailLabel: UILabel!

}

class RecordListViewController: UIViewController {

    @IBOutlet weak var recordCollectionView: UICollectionView!
    
    fileprivate var dataSource: [AudioData] = []
    fileprivate var playingIndexPath: IndexPath? = nil
    
    
    var currentPlayingCell: RecordListCell? = nil
    
    fileprivate var flowLayout: UICollectionViewFlowLayout {
        return recordCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        let w = recordCollectionView.bounds.size.width * 0.8////
        let h = recordCollectionView.bounds.size.height * 0.4
        flowLayout.itemSize = CGSize(width: w, height: h)
        
        setupCollectionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupCollectionView() {
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
    }
    
    //通过cell上的按钮点击获取当前的cell的 indexPath
    func indexPath(of event: UIEvent?) -> IndexPath? {
        guard let touch = event?.allTouches?.first else { return nil }
        let touchPoint = touch.location(in: recordCollectionView)
        let index = recordCollectionView.indexPathForItem(at: touchPoint)
//        print(index!)
        return index
    }
    
    //插入数据
    func insertAudioItem(_ item: AudioData) {
        dataSource.insert(item, at: 0)//列表
//        recordCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        recordCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
    
    //每次启动重新从本地加载数据
    func reloadDataSource(items: [AudioData]?) {
        dataSource.removeAll()
        guard let items = items else { return }
        items.forEach { insertAudioItem($0) }
        recordCollectionView.reloadData()
    }
    
}

extension RecordListViewController {
    fileprivate struct ActionSelectors {
        static var deletion: Selector { return #selector(deleteRecord(sender:with:)) }
        static var playing: Selector { return #selector(playRecord(sender:with:)) }
        static var sending: Selector { return #selector(sendRecord(sender:with:)) }
    }
    
    @objc fileprivate func deleteRecord(sender: Any, with event: UIEvent?) {
        
        //获取到按钮所在的cell
        guard let indexPath = indexPath(of: event) else { return }
        
        let alertController = UIAlertController(title: "提示", message: "是否删除这段录音", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "删除", style: .default) { (action) in
            CoreDataManager.default.remove(data: self.dataSource[indexPath.item])
            self.dataSource.remove(at: indexPath.item)
            self.recordCollectionView.reloadData()
            print("delete...")
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
         
    }
    
    @objc fileprivate func playRecord(sender: Any, with event: UIEvent?) {
        
        //获取到按钮所在的cell
        guard let master = masterParent, let indexPath = indexPath(of: event), let cell = recordCollectionView.cellForItem(at: indexPath) as? RecordListCell else { return }
        
        if let playingCell = currentPlayingCell, cell != playingCell {
            //暂停播放
            playingIndexPath = nil
            playingCell.updatePlayButtonImage(with: "play")
            master.stopItem()
        }
        
        currentPlayingCell = cell
        
        if let _ = playingIndexPath, playingIndexPath == indexPath {
            //暂停播放
            playingIndexPath = nil
            cell.updatePlayButtonImage(with: "play")
            master.stopItem()
        }
        else {
            //开始播放
            playingIndexPath = indexPath
            cell.updatePlayButtonImage(with: "stop")
            
            print(dataSource[indexPath.item].localURL)
            
            master.playItem(with: dataSource[indexPath.item])
            master.audioOperator.playCompleted = {
                self.playingIndexPath = nil
                cell.updatePlayButtonImage(with: "play")
            }
        }
        
        print("play...")
    }
    
    @objc fileprivate func sendRecord(sender: Any, with event: UIEvent?) {
        
        //获取到按钮所在的cell
        guard let master = masterParent, let indexPath = indexPath(of: event) else { return }
        let item = dataSource[indexPath.item]
        let data = item.data
        print(data)
        
        master.recognizeVoice(with: data)
        
        print("send...")
    }
}

extension RecordListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
}

extension RecordListViewController: UICollectionViewDataSource {
    
    struct ID {
        static let cell = "collection_cell"
        static let header = "collection_header"
        static let footer = "collection_footer"
    }
    
    //MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ID.cell, for: indexPath) as! RecordListCell
        
        let dataItem = dataSource[indexPath.item]
        
        cell.dateLabel.text = dataItem.filename
        cell.durationLabel.text = "时长： " + dataItem.duration.timeDescription
        cell.translateLabel.text = "识别结果"
        cell.translationLabel.text = "  未能识别"
        
        cell.addTarget(self, deleteAction: ActionSelectors.deletion, playAction: ActionSelectors.playing, sendAction: ActionSelectors.sending, event: .touchUpInside)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ID.header, for: indexPath) as! RecordListHeader
            header.titleLabel.text = "已录制"
            return header
        }
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: ID.footer, for: indexPath) as! RecordListFooter
        footer.detailLabel.text = "没有更多"
        return footer
    }
    
}
