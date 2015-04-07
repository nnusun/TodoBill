//
//  InOutModel.swift
//  TodoBill
//
//  Created by sun on 4/7/15.
//  Copyright (c) 2015 sun. All rights reserved.
//

import Foundation

class Expenditure: NSObject{
    var money: Double
    var picture: String
    var type_uuid: String
    var account_uuid: String
    var date: NSDate
    var member: String
    var project: String
    var location: String
    var mark: String
    
    init(money: Double, picture: String, type_uuid: String, account_uuid: String, date: NSDate, member: String, project: String, location: String, mark: String){
        self.money = money
        self.picture = picture
        self.type_uuid = type_uuid
        self.account_uuid = account_uuid
        self.date = date
        self.member = member
        self.project = project
        self.location = location
        self.mark = mark
    }
}

class Income: NSObject{
    var money: Double
    var picture: String
    var type_uuid: String
    var account_uuid: String
    var date: NSDate
    var member: String
    var project: String
    var location: String
    var mark: String
    
    init(money: Double, picture: String, type_uuid: String, account_uuid: String, date: NSDate, member: String, project: String, location: String, mark: String){
        self.money = money
        self.picture = picture
        self.type_uuid = type_uuid
        self.account_uuid = account_uuid
        self.date = date
        self.member = member
        self.project = project
        self.location = location
        self.mark = mark
    }
}

class Transfer: NSObject{
    var money: Double
    var picture: String
    var from_account: String
    var to_account: String
    var date: NSDate
    var member: String
    var project: String
    var location: String
    var mark: String
    
    init(money: Double, picture: String, from_account: String, to_account: String, date: NSDate, member: String, project: String, location: String, mark: String){
        self.money = money
        self.picture = picture
        self.from_account = from_account
        self.to_account = to_account
        self.date = date
        self.member = member
        self.project = project
        self.location = location
        self.mark = mark
    }
}

