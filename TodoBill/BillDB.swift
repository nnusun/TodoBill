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
    let expenditure_Create_SQL: String = "CREATE TABLE IF NOT EXISTS EXPENDITURE (ID INTERGER PRIMARY KEY AUTOINCREMENT, MONEY DOUBLE, PICTURE VARCHAR(100), TYPE_UUID VARCHAR(30), ACCOUNT_UUID VARCHAR(30), DATE DATETIME, MEMBER TEXT, PROJECT VARCHAR(30), LOCATION VARCHAR(200), MARK TEXT)"
    
    // 收入
    let income_Create_SQL: String = "CREATE TABLE IF NOT EXISTS INCOME (ID INTERGER PRIMARY KEY AUTOINCREMENT, MONEY DOUBLE, PICTURE VARCHAR(100), TYPE_UUID VARCHAR(30), ACCOUNT_UUID VARCHAR(30), DATE DATETIME, MEMBER TEXT, PROJECT VARCHAR(30), LOCATION VARCHAR(200), MARK TEXT)"
    
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
        
        let contactDB = FMDatabase(path: databasePath)
        
        if contactDB.open() {
            let firstClassResults:FMResultSet? = contactDB.executeQuery(queryFirstClassSQL, withArgumentsInArray: nil)
            while firstClassResults?.next() == true {
                var firstClassUUID:String = (firstClassResults?.stringForColumn("UUID"))!
                var firstClassName:String = (firstClassResults?.stringForColumn("NAME"))!
                var firstClassPicture:String = (firstClassResults?.stringForColumn("PICTURE"))!
                var secondClasses: [InOutTypeSecondClassModel] = getExpenditureTypeSecondClass(contactDB, firstClassUUID: firstClassUUID, income: income)
                var expenditureTypeFirstClass: InOutTypeModel = InOutTypeModel(uuid: firstClassUUID, name: firstClassName, picture:firstClassPicture, secondClass: secondClasses, income: income)
            
                let secondClassSQL = "SELECT * FROM EXPENDITURE_TYPE_SECONDCLASS WHERE FIRSTCLASS_UUID = \(firstClassUUID)"
                let secondClassResults:FMResultSet? = contactDB.executeQuery(secondClassSQL, withArgumentsInArray: nil)
            }
        }
        
        return expenditureTypeFirstClasses
    }
    
    // 获取支出二级分类
    // income == true时， 从INCOME_YPE_SECONDCLASS数据表取数据
    // income == false时，从EXPENDITURE_TYPE_SECONDCLASS数据表取数据
    func getExpenditureTypeSecondClass(contactDB: FMDatabase, firstClassUUID: String, income: Bool) -> [InOutTypeSecondClassModel]{
        var querySecondClassSQL = "SELECT * FROM EXPENDITURE_TYPE_SECONDCLASS WHERE FIRSTCLASS_UUID = \(firstClassUUID)"
        if income {
            querySecondClassSQL = "SELECT * FROM INCOME_YPE_SECONDCLASS WHERE FIRSTCLASS_UUID = \(firstClassUUID)"
        }
        var secondClasses: [InOutTypeSecondClassModel] = []
        let secondClassResults:FMResultSet? = contactDB.executeQuery(querySecondClassSQL, withArgumentsInArray: nil)
        while secondClassResults?.next() == true {
            var secondClassUUID:String = (secondClassResults?.stringForColumn("UUID"))!
            var secondClassName:String = (secondClassResults?.stringForColumn("NAME"))!
            var secondClassPicture:String = (secondClassResults?.stringForColumn("PICTURE"))!
            secondClasses.append(InOutTypeSecondClassModel(uuid: secondClassUUID, firstClassUuid: firstClassUUID, name: secondClassName, picture: secondClassPicture, income: income))
        }
        return secondClasses
    }
    
    // 增加一级分类
    
    
    // 删除一级分类
    
    
    // 增加二级分类
    
    
    // 删除二级分类
    
    
    // 增加收入
    
    
    // 删除收入
    
    
    // 增加支出
    
    
    // 删除支出
    
    
    // 增加转账
    
    
    // 删除转账
    
    
}
