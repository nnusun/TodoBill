//
//  InOutType.swift
//  TodoBill
//
//  Created by sun on 4/7/15.
//  Copyright (c) 2015 sun. All rights reserved.
//

import Foundation

// 支出一级分类
class InOutTypeModel: NSObject {
    var uuid: String
    var name: String
    var picutre: String
    var income: Bool
    var secondClass: [InOutTypeSecondClassModel]
    
    init(uuid: String, name: String, picture: String, secondClass: [InOutTypeSecondClassModel], income: Bool){
        self.uuid = uuid
        self.name = name
        self.picutre = picutre
        self.income = income
        self.secondClass = secondClass
    }
}

// 支出二级分类

class InOutTypeSecondClassModel: NSObject {
    var uuid: String
    var firstClassUuid: String
    var name: String
    var picture: String
    var income: Bool
    
    init(uuid: String, firstClassUuid: String, name: String, picture: String, income: Bool){
        self.uuid = uuid
        self.firstClassUuid = firstClassUuid
        self.name = name
        self.picture = picture
        self.income = income
    }
}
