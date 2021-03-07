//
//  MyPageViewController.swift
//  DDD.Attendance
//
//  Created by apple on 2021/03/06.
//  Copyright © 2021 DDD. All rights reserved.
//

import UIKit

class MyPageViewController: BaseViewController {
    @IBOutlet weak var popButton: UIButton!
    
    @IBOutlet weak var albumButton: UIButton!
    
    override func bindStyle() {
        popButton.layer.cornerRadius = 10
    }
    
    override func bindData() {
        
    }
    
    override func bindViewModel() {
        
    }
    
    static func instantiateViewController() -> MyPageViewController {
        return Storyboard.mypage.viewController(MyPageViewController.self)
    }
}
