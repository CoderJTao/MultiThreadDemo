//
//  GCDController.swift
//  MultiThreadingDemo
//
//  Created by 江涛 on 2019/4/12.
//  Copyright © 2019 江涛. All rights reserved.
//

import UIKit

class GCDController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    private let IMAGE_TAG = 2001
    
    private let imageArr = ["https://ws1.sinaimg.cn/large/0065oQSqly1g0ajj4h6ndj30sg11xdmj.jpg",
                            "https://ws1.sinaimg.cn/large/0065oQSqly1g04lsmmadlj31221vowz7.jpg",
                            "https://ws1.sinaimg.cn/large/0065oQSqgy1fze94uew3jj30qo10cdka.jpg",
                            "https://ws1.sinaimg.cn/large/0065oQSqly1fytdr77urlj30sg10najf.jpg",
                            "https://ws1.sinaimg.cn/large/0065oQSqly1fymj13tnjmj30r60zf79k.jpg",
                            "https://ws1.sinaimg.cn/large/0065oQSqgy1fy58bi1wlgj30sg10hguu.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "GCD"
    }

    
    @IBAction func concurrentClick(_ sender: Any) {
        clearImage()
        
        let queue = DispatchQueue.global()
        
        for index in 0..<imageArr.count {
            
            queue.async {
                let url = URL(string: self.imageArr[index])!
                let image = try? UIImage(data: Data(contentsOf: url))
                
                print("\(index) + \(Thread.current)")
                
                // 回到主线程设置图片
                DispatchQueue.main.async {
                    if let loadImage = image {
                        let imageV = self.view.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
                        imageV.image = loadImage
                    }
                }
            }
        }
    }
    
    // 栅栏方法。会在后续的任务执行完成之后，再执行barrier里面的操作
    @IBAction func barrierCLick(_ sender: Any) {
        clearImage()
        
        let queue = DispatchQueue.global()
        
        let item = DispatchWorkItem(qos: .default, flags: .barrier) {
            print("barrier + \(Thread.current)")
            
            for index in 0..<3 {
                queue.async {
                    let url = URL(string: self.imageArr[index])!
                    let image = try? UIImage(data: Data(contentsOf: url))
                    
                    print("\(index) + \(Thread.current)")
                    
                    // 回到主线程设置图片
                    DispatchQueue.main.async {
                        if let loadImage = image {
                            let imageV = self.view.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
                            imageV.image = loadImage
                        }
                    }
                }
            }
        }
        
        queue.async(execute: item)
        
        for index in 3..<imageArr.count {
            queue.async {
                let url = URL(string: self.imageArr[index])!
                let image = try? UIImage(data: Data(contentsOf: url))
                
                print("\(index) + \(Thread.current)")
                
                // 回到主线程设置图片
                DispatchQueue.main.async {
                    if let loadImage = image {
                        let imageV = self.view.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
                        imageV.image = loadImage
                    }
                }
            }
        }
    }
    
    // 在前五张图加载完成之后，延时2s后加载第6张图片
    @IBAction func notifyClick(_ sender: Any) {
        clearImage()
        
        let queue = DispatchQueue.global()
        
        let workItem = DispatchWorkItem {
            // do async task
            for index in 0..<self.imageArr.count-1 {
                queue.async {
                    let url = URL(string: self.imageArr[index])!
                    let image = try? UIImage(data: Data(contentsOf: url))
                    
                    print("\(index) + \(Thread.current)")
                    
                    // 回到主线程设置图片
                    DispatchQueue.main.async {
                        if let loadImage = image {
                            let imageV = self.view.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
                            imageV.image = loadImage
                        }
                    }
                }
            }
        }
        
        queue.async(execute: workItem)
        
        workItem.notify(queue: queue) {
            
            sleep(2)
            
            let url = URL(string: self.imageArr[self.imageArr.count-1])!
            let image = try? UIImage(data: Data(contentsOf: url))
            
            print("\(self.imageArr.count-1) + \(Thread.current)")
            
            // 回到主线程设置图片
            DispatchQueue.main.async {
                if let loadImage = image {
                    let imageV = self.view.viewWithTag(self.IMAGE_TAG+5) as! UIImageView
                    imageV.image = loadImage
                }
            }
        }
    }
    
    // 在前五张图加载完成之后，最后加载第6张图片
    @IBAction func waitClick(_ sender: Any) {
        clearImage()
        
        let queue = DispatchQueue.global()
        
        let workItem = DispatchWorkItem {
            
            sleep(2)
            
            // do async task
            for index in 0..<self.imageArr.count {
                let url = URL(string: self.imageArr[index])!
                let image = try? UIImage(data: Data(contentsOf: url))
                
                print("\(index) + \(Thread.current)")
                
                // 回到主线程设置图片
                DispatchQueue.main.async {
                    if let loadImage = image {
                        let imageV = self.view.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
                        imageV.image = loadImage
                    }
                }
            }
        }
        
        queue.async(execute: workItem)
        print("before waiting")
        workItem.wait()
        print("after waiting")
    }
    
    // 延迟5s后开始记载图片
    @IBAction func afterClick(_ sender: Any) {
        clearImage()
        
        let queue = DispatchQueue.global()
        
        queue.asyncAfter(deadline: DispatchTime.now() + 5) {
            for index in 0..<self.imageArr.count {
                let url = URL(string: self.imageArr[index])!
                let image = try? UIImage(data: Data(contentsOf: url))
                
                print("\(index) + \(Thread.current)")
                
                // 回到主线程设置图片
                DispatchQueue.main.async {
                    if let loadImage = image {
                        let imageV = self.view.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
                        imageV.image = loadImage
                    }
                }
            }
        }
    }
    
    // 全部加载完成之后才会执行全部加载完成。
    @IBAction func groupClick(_ sender: Any) {
        clearImage()
        
        let queue = DispatchQueue.global()
        
        let group = DispatchGroup()
        
        group.enter()
        queue.async {
            // 模拟耗时
            sleep(2)
            
            for index in 0..<2 {
                let url = URL(string: self.imageArr[index])!
                let image = try? UIImage(data: Data(contentsOf: url))
                
                print("\(index) + \(Thread.current)")
                
                // 回到主线程设置图片
                DispatchQueue.main.async {
                    if let loadImage = image {
                        let imageV = self.view.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
                        imageV.image = loadImage
                    }
                }
            }
            group.leave()
        }
        
        group.enter()
        queue.async {
            // 模拟耗时
            sleep(2)
            
            for index in 2..<4 {
                let url = URL(string: self.imageArr[index])!
                let image = try? UIImage(data: Data(contentsOf: url))
                
                print("\(index) + \(Thread.current)")
                
                // 回到主线程设置图片
                DispatchQueue.main.async {
                    if let loadImage = image {
                        let imageV = self.view.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
                        imageV.image = loadImage
                    }
                }
            }
            group.leave()
        }
        
        group.enter()
        queue.async {
            // 模拟耗时
            sleep(2)
            
            for index in 4..<self.imageArr.count {
                let url = URL(string: self.imageArr[index])!
                let image = try? UIImage(data: Data(contentsOf: url))
                
                print("\(index) + \(Thread.current)")
                
                // 回到主线程设置图片
                DispatchQueue.main.async {
                    if let loadImage = image {
                        let imageV = self.view.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
                        imageV.image = loadImage
                    }
                }
            }
            group.leave()
        }
        
        group.notify(queue: queue) {
            print("All images has loaded")
        }
    }
    
    private func clearImage() {
        for index in 0..<imageArr.count {
            let imageV = self.view.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
            imageV.image = nil
        }
    }
}
