//
//  TaskList.swift
//  RealmDemo
//
//  Created by Xuanyi Liu on 2017/2/6.
//  Copyright © 2017年 Xuanyi Liu. All rights reserved.
//

import Foundation
import RealmSwift

class TaskList: Object {
    
    dynamic var name = ""
    dynamic var createAt = Date()
    let tasks = List<Task>()
}
