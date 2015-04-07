//
//  AccountTypeModel.swift
//  TodoBill
//
//  Created by sun on 4/7/15.
//  Copyright (c) 2015 sun. All rights reserved.
//

import UIKit

class AccountTypeModel: NSObject {
    var uuid: String
    var name: String
    
    init(uuid: String, name: String) {
        self.uuid = uuid
        self.name = name
    }
}

class AccountDetailModel: NSObject {
    var uuid: String
    var account_type: String
    var name: String
    var bankName: String
    var currency: String
    var balance: Double
    var lastFourNumber: String
    var cardNumber: String
    var isVisible: Bool
    var mark: String
    
    init(uuid: String, account_type: String, name: String, bankName: String, currency: String, balance: Double, lastFourNumber: String, cardNumber: String, isVisible: Bool, mark: String){
        self.uuid = uuid
        self.account_type = account_type
        self.name = name
        self.bankName = bankName
        self.currency = currency
        self.balance = balance
        self.lastFourNumber = lastFourNumber
        self.cardNumber = cardNumber
        self.isVisible = isVisible
        self.mark = mark
    }
    
    // 计算余额
    /*
    func calculateBalance(){
    }
    */
    
}
