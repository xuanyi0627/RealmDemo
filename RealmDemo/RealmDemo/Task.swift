//
//  Task.swift
//  RealmDemo
//
//  Created by Xuanyi Liu on 2017/2/6.
//  Copyright © 2017年 Xuanyi Liu. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    
    dynamic var name = ""
    dynamic var createAt = Date()
    dynamic var notes = ""
    dynamic var isCompleted = false
}
