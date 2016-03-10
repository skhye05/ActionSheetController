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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let controller = ActionSheetController(cancelTitleColor: UIColor.blueColor())
                
        let titles = ["发送给胖友", "收藏", "保存图片", "定位到聊天位置", "分享到微博", "复制链接", "复制图片"]
        titles.forEach { (title) -> () in
            let action = SheetAction(title: title, handler: { (sender: SheetAction) -> Void in
                debugPrint("Taped: \(sender.title)")
            })
            controller.addAction(action)
        }
        
        let action = SheetAction(title: "Plus", titleColor: UIColor.redColor())
        controller.addAction(action)
        
        presentViewController(controller, animated: true, completion: nil)
        
    }

}

