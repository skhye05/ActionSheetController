//
//  ViewController.swift
//  Sample
//
//  Created by Moch Xiao on 3/10/16.
//  Copyright © 2016 Moch. All rights reserved.
//

import UIKit
import ActionSheetController

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let controller = ActionSheetController(title: "请选择以下其中一项", cancelTitleColor: UIColor.blue)
//        let controller = ActionSheetController(cancelTitleColor: UIColor.blue)
        let titles = ["发送给胖友", "收藏", "保存图片", "定位到聊天位置", "分享到微博", "复制链接", "复制图片"]
        titles.forEach { (title) -> () in
            let action = SheetAction(title: title) { (sender: SheetAction) in
                debugPrint("Taped: \(sender.title)")
            }
            controller.addAction(action)
        }
        
        let action = SheetAction(title: "Plus", titleColor: UIColor.red)
        controller.addAction(action)
        
        present(controller, animated: true, completion: nil)
    }

}

