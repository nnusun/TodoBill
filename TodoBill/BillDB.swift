//
//  BillDB.swift
//  TodoBill
//
//  Created by sun on 4/6/15.
//  Copyright (c) 2015 sun. All rights reserved.
//

import Foundation

class BillDB: NSObject {
    
    var databasePath: String = ""
    // 创建相关的数据库表
    // 账户类型表（现金账户，信用卡账户……）
    let accountTypeTable_Create_SQL: String = "CREATE TABLE IF NOT EXISTS ACCOUNT_TYPE (ID INTERGER PRIMARY KEY AUTOINCREMENT, UUID VARCHAR(30), NAME TEXT)"
    // 账户详细信息（招行xxx信用卡，人民币现金……）
    let accountDetailTable_Create_SQL: String = "CREATE TABLE IF NOT EXISTS ACCOUNT_DETAIL (ID INTERGER PRIMARY KEY AUTOINCREMENT, UUID VARCHAR(30), ACCOUNT_TYPE VARCHAR(30), NAME VARCHAR(30), BANKNAME VARCHAR(100), CURRENCY VARCHAR(10), BALANCE DOUBLE, LASTFOURNUMBER VARCHAR(4), CARDNUMBER VARCHAR(30), ISVISIBLE BOOLEAN, MARK TEXT)"
    // 支出一级分类
    let expenditureTypeFirstClass_Create_SQL: String = "CREATE TABLE IF NOT EXISTS EXPENDITURE_TYPE_FIRSTCLASS (UUID VARCHAR(30) PRIMARY KEY, NAME VARCHAR(30), PICTURE VARCHAR(30))"
    // 支出二级分类
    let expenditureTypeSecondClass_Create_SQL: String = "CREATE TABLE IF NOT EXISTS EXPENDITURE_TYPE_SECONDCLASS (UUID VARCHAR(30) PRIMARY KEY, FIRSTCLASS_UUID VARCHAR(30), NAME VARCHAR(30), PICTURE VARCHAR(30))"
    
    // 收入一级分类
    let incomeTypeFirstClass_Create_SQL: String = "CREATE TABLE IF NOT EXISTS INCOMDE_TYPE_FIRSTCLASS (UUID VARCHAR(30) PRIMARY KEY, NAME VARCHAR(30), PICTURE VARCHAR(30))"
    // 收入二级分类
    let incomeTypeSecondClass_Create_SQL: String = "CREATE TABLE IF NOT EXISTS INCOME_YPE_SECONDCLASS (UUID VARCHAR(30) PRIMARY KEY, FIRSTCLASS_UUID VARCHAR(30), NAME VARCHAR(30), PICTURE VARCHAR(30))"
    
    // 支出
    let expenditure_Create_SQL: String = "CREATE TABLE IF NOT EXISTS EXPENDITURE (ID INTERGER PRIMARY KEY AUTOINCREMENT, MONEY DOUBLE, PICTURE VARCHAR(100), TYPE_FIRST_UUID VARCHAR(30), TYPE_SECOND_UUID VARCHAR(30), ACCOUNT_FIRST_UUID VARCHAR(30), ACCOUNT_SECOND_UUID VARCHAR(30), DATE DATETIME, MEMBER TEXT, PROJECT VARCHAR(30), LOCATION VARCHAR(200), MARK TEXT)"
    
    // 收入
    let income_Create_SQL: String = "CREATE TABLE IF NOT EXISTS INCOME (ID INTERGER PRIMARY KEY AUTOINCREMENT, MONEY DOUBLE, PICTURE VARCHAR(100), TYPE_FIRST_UUID VARCHAR(30), TYPE_SECOND_UUID VARCHAR(30), ACCOUNT_FIRST_UUID VARCHAR(30), ACCOUNT_SECOND_UUID VARCHAR(30), DATE DATETIME, MEMBER TEXT, PROJECT VARCHAR(30), LOCATION VARCHAR(200), MARK TEXT)"
    
    // 转账
    let transfer_Create_SQL: String = "CREATE TABLE IF NOT EXISTS TRANSFER (ID INTERGER PRIMARY KEY AUTOINCREMENT, MONEY DOUBLE, PICTURE VARCHAR(100), FROME_ACCOUNT VARCHAR(30), TO_ACCOUNT VARCHAR(30), DATE DATETIME, MEMBER TEXT, PROJECT VARCHAR(30), LOCATION VARCHAR(200), MARK TEXT)"
    
    init(dataBaseName: String){
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as String
        var databasePath = docsDir.stringByAppendingPathComponent(dataBaseName)
    }
    
    // 创建数据库
    func createDB(dbName: String) -> Bool{
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as String
        var databasePath = docsDir.stringByAppendingPathComponent(dbName)
        
        if !filemgr.fileExistsAtPath(databasePath) {
            
            let db = FMDatabase(path: databasePath)
            
            if db == nil {
                println("Error: \(db.lastErrorMessage())")
                return false
            }
            
            // 创建所有的数据库表
            let createTable_SQL:[String] = [accountTypeTable_Create_SQL, accountDetailTable_Create_SQL, expenditureTypeFirstClass_Create_SQL, expenditureTypeSecondClass_Create_SQL, incomeTypeFirstClass_Create_SQL, incomeTypeSecondClass_Create_SQL, expenditure_Create_SQL, income_Create_SQL, transfer_Create_SQL]
            
            for sql_statement in createTable_SQL{
                if !createTable(db, sqlStatement: sql_statement){
                    return false
                }
            }
        }
        return true
    }
    
    // 执行SQL语句
    func executeStatement(db: FMDatabase, sqlStatement: String) -> (Int, String){
        if db.open() {
            if !db.executeStatements(sqlStatement){
                return (1, ("Error: \(db.lastErrorMessage())"))
            }
            db.close()
            return (0, "SqlStatement executed successfully.")
        }else{
            return (2, "Database open failed.")
        }
    }
    
    func createTable(db: FMDatabase, sqlStatement: String) -> Bool{
        let (return_code, return_string) = executeStatement(db, sqlStatement: sqlStatement)
        switch return_code{
        case 0:
            println("Cash table created successfully.")
            return true
        case 1:
            println("Case table created failed.")
            return false
        case 2:
            println("Database: \(databasePath) open failed.")
            return false
        default:
            println("Unexpected error happend.")
            return false
        }
    }
    
    // 获取支出一级和二级分类
    func getExpenditureType(income: Bool) -> [InOutTypeModel]{
        var expenditureTypeFirstClasses: [InOutTypeModel] = []  // 初始值为空数组
        var queryFirstClassSQL = "SELECT * FROM EXPENDITURE_TYPE_FIRSTCLASS"  // 获取支出一级分类
        if income{
            queryFirstClassSQL = "SELECT * FROM INCOMDE_TYPE_FIRSTCLASS"
        }
        
        let billDB = FMDatabase(path: databasePath)
        
        if billDB.open() {
            let firstClassResults:FMResultSet? = billDB.executeQuery(queryFirstClassSQL, withArgumentsInArray: nil)
            while firstClassResults?.next() == true {
                var firstClassUUID:String = (firstClassResults?.stringForColumn("UUID"))!
                var firstClassName:String = (firstClassResults?.stringForColumn("NAME"))!
                var firstClassPicture:String = (firstClassResults?.stringForColumn("PICTURE"))!
                var secondClasses: [InOutTypeSecondClassModel] = getExpenditureTypeSecondClass(billDB, firstClassUUID: firstClassUUID, income: income)
                var expenditureTypeFirstClass: InOutTypeModel = InOutTypeModel(uuid: firstClassUUID, name: firstClassName, picutre:firstClassPicture, secondClass: secondClasses, income: income)
            
                let secondClassSQL = "SELECT * FROM EXPENDITURE_TYPE_SECONDCLASS WHERE FIRSTCLASS_UUID = \(firstClassUUID)"
                let secondClassResults:FMResultSet? = billDB.executeQuery(secondClassSQL, withArgumentsInArray: nil)
            }
        }
        
        return expenditureTypeFirstClasses
    }
    
    // 获取支出二级分类
    // income == true时， 从INCOME_YPE_SECONDCLASS数据表取数据
    // income == false时，从EXPENDITURE_TYPE_SECONDCLASS数据表取数据
    func getExpenditureTypeSecondClass(billDB: FMDatabase, firstClassUUID: String, income: Bool) -> [InOutTypeSecondClassModel]{
        var querySecondClassSQL = "SELECT * FROM EXPENDITURE_TYPE_SECONDCLASS WHERE FIRSTCLASS_UUID = \(firstClassUUID)"
        if income {
            querySecondClassSQL = "SELECT * FROM INCOME_YPE_SECONDCLASS WHERE FIRSTCLASS_UUID = \(firstClassUUID)"
        }
        var secondClasses: [InOutTypeSecondClassModel] = []
        let secondClassResults:FMResultSet? = billDB.executeQuery(querySecondClassSQL, withArgumentsInArray: nil)
        while secondClassResults?.next() == true {
            var secondClassUUID:String = (secondClassResults?.stringForColumn("UUID"))!
            var secondClassName:String = (secondClassResults?.stringForColumn("NAME"))!
            var secondClassPicture:String = (secondClassResults?.stringForColumn("PICTURE"))!
            secondClasses.append(InOutTypeSecondClassModel(uuid: secondClassUUID, firstClassUuid: firstClassUUID, name: secondClassName, picture: secondClassPicture, income: income))
        }
        return secondClasses
    }
    
    // 增加一级分类
    func addFirstClass(name: String, picture: String, income: Bool) -> Bool{
        let billDB = FMDatabase(path: databasePath)
        let uuid = NSUUID().UUIDString
        
        var addFirstClassSQL = "INSERT INTO EXPENDITURE_TYPE_FIRSTCLASS (UUID, NAME, PICTURE) VALUES ('\(uuid)', '\(name)', '\(picture)')"
        if income {
            addFirstClassSQL = "INSERT INTO INCOMDE_TYPE_FIRSTCLASS (UUID, NAME, PICTURE) VALUES ('\(uuid)', '\(name)', '\(picture)')"
        }
        
        if billDB.open() {
            let result = billDB.executeUpdate(addFirstClassSQL, withArgumentsInArray: nil)
            billDB.close()
            if !result {
                return false
            }
        }
        return true
    }
    
    // 删除一级分类
    // 删除一级分类的同时，要删除该一级分类下得所有二级分类
    // 如果该二级分类正在被某个记录使用，则提示不能删除
    //
    // 返回值: 1: 存在账单使用了该分类
    //        2: 数据库打开失败
    //        3: 删除失败
    //        0: 成功
    func deleteFirstClass(uuid: String,  income: Bool) -> Int{
        let billDB = FMDatabase(path: databasePath)
        var resultRecord: FMResultSet? = nil
        var deleteSecondClassSQL = ""
        var deleteFirstClassSQL = ""
        var getRecordSQL = ""
        
        if income{
            deleteSecondClassSQL = "DELETE FROM INCOME_YPE_SECONDCLASS WHERE FIRSTCLASS_UUID = '\(uuid)'"
            deleteFirstClassSQL = "DELETE FROM INCOMDE_TYPE_FIRSTCLASS WHERE UUID = '\(uuid)'"
            resultRecord = findSpecialClassInfo(uuid, firstOrSecond: "first", income: true)
        }else{
            deleteSecondClassSQL = "DELETE FROM EXPENDITURE_TYPE_SECONDCLASS WHERE FIRSTCLASS_UUID = '\(uuid)'"
            deleteFirstClassSQL = "DELETE FROM EXPENDITURE_TYPE_FIRSTCLASS WHERE UUID = '\(uuid)'"
            resultRecord = findSpecialClassInfo(uuid, firstOrSecond: "first", income: false)
        }
        
        // 查看该一级分类是否被使用
        // 如果一级分类已经被使用，则二级分类不用再查，可以直接返回1
        if let used = resultRecord{
            if used.next() == true{
                return 1 // 该分类正在被使用
            }
        }else{
            return 2  // 说明是直接返回的nil， 数据库打开失败
        }
        
        if billDB.open() {
            // 删除二级分类
            let secondDeleteResult = billDB.executeUpdate(deleteSecondClassSQL, withArgumentsInArray: nil)
            if !secondDeleteResult{
                billDB.close()
                return 3
            }
            // 删除一级分类
            let firstDeleteResult = billDB.executeUpdate(deleteFirstClassSQL, withArgumentsInArray: nil)
            if !secondDeleteResult{
                billDB.close()
                return 3
            }
        }else {
            return 2
        }
        
        return 0
    }
    
    // 增加二级分类
    func addSecondClass(name: String, picture: String, income: Bool) -> Bool{
        let billDB = FMDatabase(path: databasePath)
        let uuid = NSUUID().UUIDString
        
        var addSecondClassSQL = "INSERT INTO EXPENDITURE_TYPE_SECONDCLASS (UUID, NAME, PICTURE) VALUES ('\(uuid)', '\(name)', '\(picture)')"
        if income {
            addSecondClassSQL = "INSERT INTO INCOME_TYPE_SECONDCLASS (UUID, NAME, PICTURE) VALUES ('\(uuid)', '\(name)', '\(picture)')"
        }
        
        if billDB.open() {
            let result = billDB.executeUpdate(addSecondClassSQL, withArgumentsInArray: nil)
            billDB.close()
            if !result {
                return false
            }
        }
        return true
    }
    
    // 删除二级分类
    func deleteSecondClass(uuid: String,  income: Bool) -> Int{
        let billDB = FMDatabase(path: databasePath)
        var deleteSecondClassSQL = ""
        var resultRecord: FMResultSet? = nil
        
        if income{
            deleteSecondClassSQL = "DELETE FROM INCOME_YPE_SECONDCLASS WHERE FIRSTCLASS_UUID = '\(uuid)'"
            resultRecord = findSpecialClassInfo(uuid, firstOrSecond: "second", income: true)
        }else{
            deleteSecondClassSQL = "DELETE FROM EXPENDITURE_TYPE_SECONDCLASS WHERE FIRSTCLASS_UUID = '\(uuid)'"
            resultRecord = findSpecialClassInfo(uuid, firstOrSecond: "second", income: false)
        }
        // 查看该二级分类是否被使用
        if let used = resultRecord{
            if used.next() == true{
                return 1 // 该分类正在被使用
            }
        }else{
            return 2  // 说明是直接返回的nil， 数据库打开失败
        }
        
        
        if billDB.open() {
            // 删除二级分类
            let secondDeleteResult = billDB.executeUpdate(deleteSecondClassSQL, withArgumentsInArray: nil)
            if !secondDeleteResult{
                billDB.close()
                return 3  // 删除失败
            }
        }else {
            // 数据库打开失败
            return 2
        }
        
        return 0
    }
    
    // 查找特定分类的收入、支出
    // classType: 只可以是 first/second
    // income: 为false时，表示查找支出信息
    func findSpecialClassInfo(uuid: String, firstOrSecond: String, income: Bool) -> FMResultSet?{
        var findSpecialClassInfoSQL = ""
        let type = (firstOrSecond, income)
        switch type{
        case ("first", false): findSpecialClassInfoSQL = "SELECT * FROM EXPENDITURE WHERE TYPE_FIRST_UUID = '\(uuid)'"
        case ("first", true):  findSpecialClassInfoSQL = "SELECT * FROM INCOME WHERE TYPE_FIRST_UUID = '\(uuid)'"
        case ("second", false):  findSpecialClassInfoSQL = "SELECT * FROM EXPENDITURE WHERE TYPE_SECOND_UUID = '\(uuid)'"
        case ("second", true):  findSpecialClassInfoSQL = "SELECT * FROM INCOME WHERE TYPE_SECOND_UUID = '\(uuid)'"
        default: findSpecialClassInfoSQL = ""
        }
        
        let billDB = FMDatabase(path: databasePath)
        if billDB.open() {
            let result:FMResultSet? = billDB.executeQuery(findSpecialClassInfoSQL, withArgumentsInArray: nil)
            billDB.close()
            return result
        } else {
            return nil
        }
    }
    // 增加收入
    func addIncome(income: Income) -> Bool{
        var intDate = income.date.timeIntervalSince1970
        var addIncomeSQL = "INSERT INTO INCOME (MONEY, PICTURE, TYPE_FIRST_UUID, TYPE_SECOND_UUID, ACCOUNT_FIRST_UUID, ACCOUNT_SECOND_UUID, DATE, MEMBER, PROJECT, LOCATION, MARK) VALUES ('\(income.money)', '\(income.picture)', '\(income.type_first_uuid)', '\(income.type_second_uuid)', '\(income.account_first_uuid)', '\(income.account_second_uuid)', '\(intDate)', '\(income.member)', '\(income.project)', '\(income.location)', '\(income.mark)')"
        
        let billDB = FMDatabase(path: databasePath)
        if billDB.open() {
            let result = billDB.executeUpdate(addIncomeSQL, withArgumentsInArray: nil)
            billDB.close()
            if !result{
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    // 删除收入
    func deleteIncome(id: Int) -> Bool{
        var deleteIncomeSQL = "DELETE FROME INCOME WHERE ID = \(id)"
        
        let billDB = FMDatabase(path: databasePath)
        if billDB.open() {
            let result = billDB.executeUpdate(deleteIncomeSQL, withArgumentsInArray: nil)
            billDB.close()
            if !result{
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    // 增加支出  -> 可以考虑与增加收入合并，只有数据库表不同而已
    func addExpenditure(expenditure: Expenditure) -> Bool{
        var intDate = expenditure.date.timeIntervalSince1970
        var addExpenditureSQL = "INSERT INTO EXPENDITURE (MONEY, PICTURE, TYPE_FIRST_UUID, TYPE_SECOND_UUID, ACCOUNT_FIRST_UUID, ACCOUNT_SECOND_UUID, DATE, MEMBER, PROJECT, LOCATION, MARK) VALUES ('\(expenditure.money)', '\(expenditure.picture)', '\(expenditure.type_first_uuid)', '\(expenditure.type_second_uuid)', '\(expenditure.account_first_uuid)', '\(expenditure.account_second_uuid)', '\(intDate)', '\(expenditure.member)', '\(expenditure.project)', '\(expenditure.location)', '\(expenditure.mark)')"
        
        let billDB = FMDatabase(path: databasePath)
        if billDB.open() {
            let result = billDB.executeUpdate(addExpenditureSQL, withArgumentsInArray: nil)
            billDB.close()
            if !result{
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    // 删除支出 （同上）
    func deleteExpenditure(id: Int) -> Bool{
        var deleteExpenditureSQL = "DELETE FROME EXPENDITURE WHERE ID = \(id)"
        
        let billDB = FMDatabase(path: databasePath)
        if billDB.open() {
            let result = billDB.executeUpdate(deleteExpenditureSQL, withArgumentsInArray: nil)
            billDB.close()
            if !result{
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    // 增加转账
    
    
    // 删除转账
    
    
}
