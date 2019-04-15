//
//  ImageLoadOperation.swift
//  MultiThreadingDemo
//
//  Created by 江涛 on 2019/4/15.
//  Copyright © 2019 江涛. All rights reserved.
//

import UIKit
import Foundation

class ImageLoadOperation: Operation {
    
    var imageUrl: String?
    let complete: (UIImage?) -> Void
    
    init(url: String, execute: @escaping (UIImage?) -> Void) {
        self.imageUrl = url
        complete = execute
        super.init()
    }
    
    // isExecuting: 是否执行中，需要实现KVO通知机制。
    private var _executing = false
    override var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            if newValue != _executing {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    // isFinished: 是否已完成，需要实现KVO通知机制。
    private var _finished = false
    override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    // isAsynchronous: 该方法默认返回 false ，表示非并发执行。并发执行需要自定义并且返回 true。后面会根据这个返回值来决定是否并发。
    override var isAsynchronous: Bool {
        get {
            return true
        }
    }
    
    // 所有并行的 Operations 都必须重写这个方法，然后在你想要执行的线程中手动调用这个方法。注意：任何时候都不能调用父类的start方法。
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        if let url = imageUrl {
            let use = URL(string: url)!
            let imageData = try? Data(contentsOf: use)
            
            if let data = imageData {
                let image = UIImage(data: data)
                complete(image)
                isExecuting = false
                isFinished = true
            } else {
                complete(nil)
                isExecuting = false
                isFinished = true
            }
        } else {
            complete(nil)
            isExecuting = false
            isFinished = true
        }
    }
    
    override func cancel() {
        if isCancelled {
           return
        }
        super.cancel()
        
        isExecuting = false
        isFinished = true
    }
}
