//
//  DbConnect.swift
//  ios-SDK-test
//
//  Created by Dev ABC on 2023/06/27.
//

import Foundation
import SwiftyJSON

// DB connection
public func dbConnect() -> MySQL.Connection {
    //create the connection object
    let con = MySQL.Connection()
//    _ = "kthulu"
    
    do{
        // open a new connection
        // Local db connet
        try con.open(_: dbServer!, user: dbUser!, passwd: dbPasswd!, dbname: dbName!)
//        try con.open(_: "210.207.161.10", user: "abcuser", passwd: "abcuserpw", dbname: "blockchain_db")
        // print("DB 연결 : ", con.isConnected)
        // select the database
        try con.use(dbName!)
    } catch(let e) {
        print(e)
    }
    return con
}

// Sql return type JsonArray
public func sqlJsonArray(sqlQuery: String) -> JSON {
    var jsonArray: JSON = JSON([])

    do {
        let sql = try dbConnect().prepare(sqlQuery)
        let res = try sql.query([])

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        while let row = try res.readRow() {
            // Change Date to String before converting to JSON
            var rowWithFormattedDate = row
            if let updated_date = rowWithFormattedDate["updated_date"] as? Date {
                rowWithFormattedDate["updated_date"] = dateFormatter.string(from: updated_date)
            }
        
            let jsonString = changeJsonString(useData: rowWithFormattedDate)
            if let jsonData = jsonString.data(using: .utf8) {
                let jsonObject = try JSON(data: jsonData)
                jsonArray.arrayObject?.append(jsonObject.object)
            }
        }

        try dbConnect().close()
    } catch (let e) {
        print(e)
    }
    return jsonArray
}

// Sql return type JsonObject
public func sqlJsonObject(sqlQuery : String) -> JSON {
    var jsonObject: JSON = JSON()
    
    do{
        let sql = try dbConnect().prepare(sqlQuery)
        let res = try sql.query([])
        
        if let row = try res.readRow(){
            let jsonString = changeJsonString(useData: row)
            if let jsonData = jsonString.data(using: .utf8) {
                jsonObject = try JSON(data: jsonData)
            }
        }
        try dbConnect().close()
    } catch (let e) {
        print(e)
    }
    return jsonObject
}
