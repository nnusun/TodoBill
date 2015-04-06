//
//  BillDB.swift
//  TodoBill
//
//  Created by sun on 4/6/15.
//  Copyright (c) 2015 sun. All rights reserved.
//

import Foundation

class BillDB: NSObject {
    
    
    // 创建相关的数据库表
    // 账户类型表（现金账户，信用卡账户……）
    let accountTypeTable_Create: String = "CREATE TABLE IF NOT EXISTS ACCOUNT_TYPE (ID INTERGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, )"
    // 账户详细信息（招行xxx信用卡，人民币现金……）
    let accountDetailTable_Create: String = "CREATE TABLE IF NOT EXISTS ACCOUNT_DETAIL (ID INTERGER PRIMARY KEY AUTOINCREMENT, ACCOUNT_TYPE VARCHAR(100), NAME VARCHAR(30), BANKNAME VARCHAR(100), CURRENCY VARCHAR(10), BALANCE DOUBLE, LASTFOURNUMBER VARCHAR(4), CARDNUMBER VARCHAR(30), ISVISIBLE BOOLEAN, MARK TEXT)"
    // 支出一级分类
    let expenditureTypeFirstClass: String = "CREATE TABLE IF NOT EXISTS EXPENDITURE_TYPE_FIRSTCLASS (UUID VARCHAR(30) PRIMARY KEY, NAME VARCHAR(30))"
    // 支出二级分类
    let expenditureTypeSecondClass: String = "CREATE TABLE IF NOT EXISTS EXPENDITURE_TYPE_SECONDCLASS (UUID VARCHAR(30) PRIMARY KEY, FIRSTCLASS_UUID VARCHAR(30), NAME VARCHAR(30))"
    
    // 收入一级分类
    let incomeTypeFirstClass: String = "CREATE TABLE IF NOT EXISTS INCOMDE_TYPE_FIRSTCLASS (UUID VARCHAR(30) PRIMARY KEY, NAME VARCHAR(30))"
    // 收入二级分类
    let incomeTypeSecondClass: String = "CREATE TABLE IF NOT EXISTS INCOME_YPE_SECONDCLASS (UUID VARCHAR(30) PRIMARY KEY, FIRSTCLASS_UUID VARCHAR(30), NAME VARCHAR(30))"
    
    // 支出
    let expenditure: String = "CREATE TABLE IF NOT EXISTS EXPENDITURE (ID INTERGER PRIMARY KEY AUTOINCREMENT, MONEY DOUBLE, PICTURE VARCHAR(100), TYPE_UUID VARCHAR(30), ACCOUNT_UUID VARCHAR(30), DATE DATETIME, MEMBER TEXT, PROJECT VARCHAR(30), LOCATION VARCHAR(200), MARK TEXT)"
    
    // 收入
    let income: String = "CREATE TABLE IF NOT EXISTS INCOME (ID INTERGER PRIMARY KEY AUTOINCREMENT, MONEY DOUBLE, PICTURE VARCHAR(100), TYPE_UUID VARCHAR(30), ACCOUNT_UUID VARCHAR(30), DATE DATETIME, MEMBER TEXT, PROJECT VARCHAR(30), LOCATION VARCHAR(200), MARK TEXT)"
    
    // 转账
    let transfer: String = "CREATE TABLE IF NOT EXISTS TRANSFER (ID INTERGER PRIMARY KEY AUTOINCREMENT, MONEY DOUBLE, PICTURE VARCHAR(100), FROME_ACCOUNT VARCHAR(30), TO_ACCOUNT VARCHAR(30), DATE DATETIME, MEMBER TEXT, PROJECT VARCHAR(30), LOCATION VARCHAR(200), MARK TEXT)"
    
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
            let createTable_SQL:[String] = [accountTypeTable_Create, accountDetailTable_Create, expenditureTypeFirstClass, expenditureTypeSecondClass, incomeTypeFirstClass, incomeTypeSecondClass, expenditure, income, transfer]
            
            for sql_statement in createTable_SQL{
                if ！createTable(db, sql_statement){
                    return false
                }
            }
        }
    }
    
    // 执行SQL语句
    func executeStatement(db: FMDatabase, sqlStatement: String) -> (int, String){
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
        (return_code, return_string) = executeStatement(db, sqlStatement)
        switch return_code{
        case 0:
            println("Cash table created successfully.")
            return true
        case 1:
            println("Case table created failed.")
            return false
        case 2:
            println("Database: \(dbName) open failed.")
            return false
        default:
            println("Unexpected error happend.")
            return false
        }
    }
    
    
}
