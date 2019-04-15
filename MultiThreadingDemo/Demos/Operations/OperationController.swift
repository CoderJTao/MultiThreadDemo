//
//  OperationController.swift
//  MultiThreadingDemo
//
//  Created by 江涛 on 2019/4/12.
//  Copyright © 2019 江涛. All rights reserved.
//

import UIKit

class OperationController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    private let IMAGE_TAG = 1001
    
    private let imageArr = ["https://ws1.sinaimg.cn/large/0065oQSqly1g0ajj4h6ndj30sg11xdmj.jpg",
                            "https://ws1.sinaimg.cn/large/0065oQSqly1g04lsmmadlj31221vowz7.jpg",
                            "https://ws1.sinaimg.cn/large/0065oQSqgy1fze94uew3jj30qo10cdka.jpg",
                            "https://ws1.sinaimg.cn/large/0065oQSqly1fytdr77urlj30sg10najf.jpg",
                            "https://ws1.sinaimg.cn/large/0065oQSqly1fymj13tnjmj30r60zf79k.jpg",
                            "https://ws1.sinaimg.cn/large/0065oQSqgy1fy58bi1wlgj30sg10hguu.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Operation OperationQueue"
        
    }
    

    // 并发加载
    @IBAction func concurrentClick(_ sender: Any) {
        clearImage()
        
        let queue = OperationQueue()
        
        for index in 0..<imageArr.count {
            let op = BlockOperation {
                let url = URL(string: self.imageArr[index])!
                let image = try? UIImage(data: Data(contentsOf: url))
                
                print("\(index) + \(Thread.current)")
                
                // 回到主线程设置图片
                OperationQueue.main.addOperation {
                    if let loadImage = image {
                        let imageV = self.containerView.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
                        imageV.image = loadImage
                    }
                }
            }
            
            queue.addOperation(op)
        }
    }
    
    // 串行加载
    @IBAction func serialClick(_ sender: Any) {
        clearImage()
        
        let queue = OperationQueue()
        
        queue.maxConcurrentOperationCount = 1
        
        for index in 0..<imageArr.count {

            let op = BlockOperation {
                let url = URL(string: self.imageArr[index])!
                let image = try? UIImage(data: Data(contentsOf: url))

                print("\(index) + \(Thread.current)")
                
                // 回到主线程设置图片
                OperationQueue.main.addOperation {
                    if let loadImage = image {
                        let imageV = self.containerView.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
                        imageV.image = loadImage
                    }
                }
            }
            
            queue.addOperation(op)
        }
    }
    
    // 按依赖加载
    @IBAction func dependClick(_ sender: Any) {
        clearImage()
        
        let queue = OperationQueue()
        
        var opArr: [BlockOperation] = []
        
        for index in 0..<imageArr.count {
            
            let op = BlockOperation {
                let url = URL(string: self.imageArr[index])!
                let image = try? UIImage(data: Data(contentsOf: url))
                
                print("\(index) + \(Thread.current)")
                
                // 回到主线程设置图片
                OperationQueue.main.addOperation {
                    if let loadImage = image {
                        let imageV = self.containerView.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
                        imageV.image = loadImage
                    }
                }
            }
            
            opArr.append(op)
        }
        
        // 添加依赖   前面的操作总是依赖后续操作
        var i = opArr.count - 1
        for _ in 0..<opArr.count {
            if (i-1) < 0 { break }
            
            let op_after = opArr[i]
            let op_before = opArr[i-1]
            
            op_before.addDependency(op_after)
            
            i -= 1
        }
        
        queue.addOperations(opArr, waitUntilFinished: true)
    }
    
    // 自定义Operation类
    @IBAction func customOPClick(_ sender: Any) {
        // TODO
    }
    
    
    
    
    private func clearImage() {
        for index in 0..<imageArr.count {
            let imageV = self.containerView.viewWithTag(self.IMAGE_TAG+index) as! UIImageView
            imageV.image = nil
        }
    }
    
}
