//
//  Account.swift
//  kthulu-ios-sdk
//
//  Created by Dev ABC on 2023/06/28.
//

import Foundation
import BigInt
import web3swift
import Web3Core
import SwiftyJSON


// Create accounts asynchronously
public func createAccountsAsync(network: [String]) async throws -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    var result: JSON = JSON()
    resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
    
    let allowedStrings: Set<String> = ["ethereum", "cypress", "polygon", "bnb"]

        for net in network {
            if !allowedStrings.contains(net) {
                let returnData = ["error" :  "Error: \(net) is not allowed."]
                resultArray.arrayObject?.append(changeJsonObject(useData: returnData))
                resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
                return resultData
            }
        }
    
    let bitsOfEntropy: Int = 128
    let mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!
    let keystore = try! BIP32Keystore(
        mnemonics: mnemonics,
        password: "",
        mnemonicsPassword: "",
        language: .english)!
    let user_account = keystore.addresses!.first!.address
    let privateKey = try! keystore.UNSAFE_getPrivateKeyData(password: "", account: keystore.addresses!.first!)
    let account = user_account.lowercased()
    // private, mnemonic encrypt
    var encrytPrivateKey = "0x\(privateKey.toHexString())"
    var encrytMnemonics = mnemonics
    do {
        encrytPrivateKey = try encrypt(input: "0x\(privateKey.toHexString())")!
        encrytMnemonics = try encrypt(input: mnemonics)!
    } catch {
        result["error"] = JSON(error.localizedDescription)
        resultArray.arrayObject?.append(result)
        resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
        return resultData
    }
    
    do{
        // return data
        for net in network {
            let returnData = [
                "network": net,
                "account": user_account
            ]
            resultArray.arrayObject?.append(changeJsonObject(useData: returnData))
        }
        
        // account data
        var saveDataList: JSON = JSON([])
        let saveData = [
            "account": account,
            "private": encrytPrivateKey,
            "mnemonic": encrytMnemonics
        ]
        // storage save
        saveJsonData(jsonObject: changeJsonObject(useData: saveData), key: account)
        
        // return data result "OK", add array
        resultData = changeJsonObject(useData: ["result": "OK", "value": resultArray])
    } catch {
        print("create error: \(error)")
    }
    return resultData
}

// getAccountAsync asynchronously
public func restoreAccountAsync(network: [String]? = nil, privateKey: String? = nil, mnemonic: String? = nil)  async throws -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
    
    var networkArray: Array<String> = []
    if(network == nil){
        networkArray = ["ethereum", "cypress", "polygon", "bnb"]
    } else {
        networkArray = network!
    }
    
    if let privateKey = privateKey {
        // Generate address from private key
        do {
            let privateKeyData = Data(hex: privateKey)
            let publicKey = Utilities.privateToPublic(privateKeyData)
            let user_account = Utilities.publicToAddressString(publicKey!)
            var encrytPrivateKey = ""
            do {
                encrytPrivateKey = try encrypt(input:privateKey)!
            } catch {
                print("Encrypt error: \(error)")
            }
            let account = user_account!.lowercased()
            
            for net in networkArray{
                let result = [
                    "network": net,
                    "account": user_account
                ]
                resultArray.arrayObject?.append(changeJsonObject(useData: result))
            }
            var saveDataList: JSON = JSON([])
            let saveData = [
                "account": account,
                "private": encrytPrivateKey,
                "mnemonic": ""
            ]
            
            // storage save
            saveJsonData(jsonObject: changeJsonObject(useData: saveData), key: account)
            resultData = changeJsonObject(useData: ["result": "OK", "value": resultArray])
        }
    } else if let mnemonic = mnemonic {
        // Generate address from mnemonic
        do {
            guard let keystore = try? BIP32Keystore(
                mnemonics: mnemonic,
                password: "",
                mnemonicsPassword: "",
                language: .english),
                  let user_account = keystore.addresses?.first,
                  let privateKeyData = try? keystore.UNSAFE_getPrivateKeyData(password: "", account: user_account)
            else {
                let nilObject: JSON = JSON()
                return nilObject
            }
            let account = user_account.address.lowercased()
            let privateKey = try! keystore.UNSAFE_getPrivateKeyData(password: "", account: keystore.addresses!.first!)
            var encrytPrivateKey = "0x\(privateKey.toHexString())"
            var encrytMnemonics = mnemonic
            
            do {
                encrytPrivateKey = try encrypt(input: "0x\(privateKey.toHexString())")!
                encrytMnemonics = try encrypt(input: mnemonic)!
                
            } catch {
                print("Encrypt error: \(error)")
            }
            
            for net in networkArray{
                let result = [
                    "network": net,
                    "account": user_account.address
                ]
                resultArray.arrayObject?.append(changeJsonObject(useData: result))
            }
            
            var saveDataList: JSON = JSON([])
            let saveData = [
                "account": account,
                "private": encrytPrivateKey,
                "mnemonic": encrytMnemonics
            ]
            
            saveJsonData(jsonObject: changeJsonObject(useData: saveData), key: account)
            resultData = changeJsonObject(useData: ["result": "OK", "value": resultArray])
        }
    } else {
        print("Either privateKey or mnemonic must be provided.")
    }
    return resultData
}

// Get account info
public func getAccountInfoAsync(account: String) async throws -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
    
    do {
        guard let address: JSON = loadJsonData(key: account.lowercased()) else {
            resultData = changeJsonObject(useData: ["result": "OK", "value": resultArray])
            return resultData
        }
        
        if account.lowercased() == address["account"].string?.lowercased() {
            var equalAddress = address
            
            // Decrypt the values of private and mnemonic
            equalAddress["private"].string = try decrypt(input: equalAddress["private"].string ?? "")
            
            if let mnemonic = equalAddress["mnemonic"].string, !mnemonic.isEmpty {
                equalAddress["mnemonic"].string = try decrypt(input: mnemonic)
            }
            
            resultArray.arrayObject?.append(equalAddress)
            resultData = changeJsonObject(useData: ["result": "OK", "value": resultArray])
        }
    } catch let error {
        var errorResult: JSON = JSON()
        errorResult["error"] = JSON(error.localizedDescription)
        resultArray.arrayObject?.append(errorResult)
        resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
    }
    
    return resultData
}


// Validation account
public func isValidAddressAsync(account: String) async throws -> Bool {
    let frontText = account.prefix(2)
    if(account.count == 42 && frontText == "0x"){
        return true
    }
    return false
}

// Validation function for private key
public func isValidPrivateKey(key: String) async throws -> Bool {
    let frontText = key.prefix(2)
    if(key.count == 66 && frontText == "0x"){
        return true
    }
    return false
}

// Validation function for mnemonic phrase
public func isValidMnemonic(phrase: String) async throws -> Bool {
    let mnemonicArray = phrase.components(separatedBy: " ")
    if(mnemonicArray.count == 12) {
        return true
    }
    return false
}

// Get token info asynchronously
public func getBalanceAsync(network: String, owner: String, token_id: String? = "0x0000000000000000000000000000000000000000") async throws  -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    var jsonData: JSON = JSON()
    var result: JSON = JSON()
    resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])

    do{
        networkSettings(network: network)
        let url = try await URL(string: rpcUrl)
        let web3 = try await Web3.new(url!)
        let userAddress = EthereumAddress(owner)!
        
        // Check for Ethereum address
        if token_id == "0x0000000000000000000000000000000000000000" {
            let ethBalance = try await web3.eth.getBalance(for: EthereumAddress(owner)!)
            let balanceDecimal = Decimal(string: String(ethBalance)) ?? 0
            let tenToThePowerofDecimals = Decimal(pow(10, 18))
            let newBalance = balanceDecimal / tenToThePowerofDecimals
            jsonData["balance"] = JSON(newBalance)
            resultArray.arrayObject?.append(jsonData)
            resultData["result"] = "OK"
            resultData["value"] = JSON(resultArray)
        } else {
            let contract = web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress(token_id!)!, abiVersion: 2)!
            let parameters: [Any] = [userAddress]
            let readOp = contract.createReadOperation("balanceOf", parameters: parameters)!
            readOp.transaction.from = EthereumAddress(owner)
            
            let getBalanceResponse = try await readOp.callContractMethod()
            
            let tokenBalance = getBalanceResponse["0"] as? BigUInt
            
            // Fetch Token Decimals
            let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
            guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
                throw Web3Error.inputError(desc: "Contract may not be ERC20 compatible, cannot get decimals")
            }
            let decimals = decTyped
            let balanceInTokens = Double(tokenBalance!) / pow(10.0, Double(decimals))
            
            jsonData["balance"] = JSON(balanceInTokens)
            resultArray.arrayObject?.append(jsonData)
            resultData["result"] = "OK"
            resultData["value"] = JSON(resultArray)
        }
    }
    return resultData
    
}

public func getTokenInfoAsync(network: String, token_id: String) async throws -> JSON {
    var jsonData: JSON = JSON()
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()

    networkSettings(network: network)
    let url = try await URL(string: rpcUrl)
    let web3 = try await Web3.new(url!)
    
    let contract = web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress(token_id)!, abiVersion: 2)!
    
    var intDecimals = 0;

    do {
        let nameResponse = try await contract.createReadOperation("name")!.callContractMethod()
        if let name = nameResponse["0"] as? String {
            jsonData["name"] = JSON(name)
        }
    } catch {
        // handle error, if you wish to log it
    }

    do {
        let symbolResponse = try await contract.createReadOperation("symbol")!.callContractMethod()
        if let symbol = symbolResponse["0"] as? String {
            jsonData["symbol"] = JSON(symbol)
        }
    } catch {
        // handle error
    }

    do {
        let callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
        if let dec = callResult["0"], let decTyped = dec as? BigUInt {
            intDecimals = Int(decTyped)
            jsonData["decimals"] = JSON(intDecimals)
        }
    } catch {
        // handle error
    }

    do {
        let totalResponse = try await contract.createReadOperation("totalSupply")!.callContractMethod()
        if let totalSupply = totalResponse["0"] as? BigUInt {
            let totalSupplyString = String(totalSupply)
            let totalSupplyInTokens = Double(totalSupplyString)! / pow(10.0, Double(intDecimals))
            jsonData["total_supply"] = JSON(totalSupplyInTokens)
        }
    } catch {
        // handle error
    }

    resultArray.arrayObject?.append(jsonData)
    resultData["result"] = "OK"
    resultData["value"] = JSON(resultArray)

    return resultData
}

// Get token info list async
public func getTokenListAsync(network: String, owner: String, sort: String? = "DESC", limit: Int? = 0, page_number: Int? = 1) async throws -> JSON {
    
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
    
    do{
        var offset: Int = (page_number! - 1) * limit!
        
        var tokenList =
            " SELECT" +
                " idx AS idx," +
                " network AS network," +
                " token_address AS token_id," +
                " owner_account AS owner," +
                " balance AS balance," +
                " (SELECT decimals FROM token_table WHERE network = t.network AND token_address = t.token_address LIMIT 1) AS decimals," +
                " (SELECT token_symbol FROM token_table WHERE network = t.network AND  token_address = t.token_address LIMIT 1) AS symbol," +
                " (SELECT token_name FROM token_table WHERE network = t.network AND  token_address = t.token_address LIMIT 1) AS name," +
                " (SELECT COUNT(*) FROM token_owner_table WHERE network = '\(network)' AND owner_account = '\(owner)') AS sum " +
            " FROM" +
                " token_owner_table t" +
            " WHERE" +
                " network = '\(network)'" +
            " AND" +
                " owner_account = '\(owner)'" +
            " ORDER BY" +
                " idx " + sort!
   
        if(offset != 0){
            tokenList += " LIMIT \(limit) OFFSET \(offset)"
        }
        
        var jsonArray: JSON = JSON([])
        var sumResult: JSON = JSON([])
        
        do {
            var cnt: Int = 0
            let sql = try dbConnect().prepare(tokenList)
            let res = try sql.query([])
            while let row = try res.readRow() {
                // Change Date to String before converting to JSON
                var rowWithFormattedDate = row
                if(cnt == 0){
                    let sumString = changeJsonString(useData: rowWithFormattedDate)
                    if let sumData = sumString.data(using: .utf8) {
                        let sumObject = try JSON(data: sumData)
                        sumResult.arrayObject?.append(sumObject.object)
                    }
                    cnt+=1
                }
                rowWithFormattedDate.removeValue(forKey: "sum")
                rowWithFormattedDate.removeValue(forKey: "idx")
                let jsonString = changeJsonString(useData: rowWithFormattedDate)
                if let jsonData = jsonString.data(using: .utf8) {
                    let jsonObject = try JSON(data: jsonData)
                    jsonArray.arrayObject?.append(jsonObject.object)
                }
            }

            try dbConnect().close()
        } catch {
            let jsonData = ["error" : "db connect error"]
            resultArray.arrayObject?.append(jsonData)
            resultData["result"] = "FAIL"
            resultData["value"] = JSON(resultArray)
        }
        
        var sum: Int? = 0
        if let sumValue = sumResult.array?.first?["sum"].int {
            sum = sumValue
        }
        
        var page_count: Int? = 0
        if(sum != 0 && limit != 0){
            page_count = sum!/limit!
        }
        
        resultData = changeJsonObject(useData: ["result": "OK", "sum": sum, "sort": sort, "page_count": page_count, "value": jsonArray])
    }
    return resultData
}

// Token transfer history
public func getTokenHistoryAsync(network: String, owner: String, token_id: String? = "0x0000000000000000000000000000000000000000", sort: String? = "DESC", limit: Int? = 0, page_number: Int? = 1) async throws -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
    do{
        var offset: Int = (page_number! - 1) * limit!
        
        var historyQuery =
            " SELECT" +
                " network AS network," +
                " token_address AS token_id," +
                " block_number AS block_number," +
                " timestamp AS timestamp," +
                " transaction_hash AS transaction_hash," +
                " `from` AS `from`," +
                " `to` AS `to`," +
                " amount AS amount," +
                " gas_used AS gas_used," +
                " (SELECT decimals FROM token_table WHERE network = '\(network)' AND token_address = '\(token_id!)') AS decimals," +
                " (SELECT token_symbol FROM token_table WHERE network = '\(network)' AND token_address = '\(token_id!)') AS symbol," +
                " (SELECT count(*) FROM token_transfer_table WHERE network = '\(network)' AND token_address = '\(token_id!)' AND (`from` ='\(owner)' OR `to` ='\(owner)')) AS sum" +
            " FROM" +
                " token_transfer_table" +
            " WHERE" +
                " network = '\(network)'" +
            " AND" +
                " token_address = '\(token_id!)'" +
            " AND" +
                " (`from` ='\(owner)' OR `to` ='\(owner)')" +
            " ORDER BY" +
                " block_number " + sort!

        if(offset != 0){
            historyQuery += " LIMIT \(limit) OFFSET \(offset)"
        }
        
        var jsonArray: JSON = JSON([])
        var sumResult: JSON = JSON([])
        
        do {
            var cnt: Int = 0
            let sql = try dbConnect().prepare(historyQuery)
            let res = try sql.query([])
            while let row = try res.readRow() {
                // Change Date to String before converting to JSON
                var rowWithFormattedDate = row
                if(cnt == 0){
                    let sumString = changeJsonString(useData: rowWithFormattedDate)
                    if let sumData = sumString.data(using: .utf8) {
                        let sumObject = try JSON(data: sumData)
                        sumResult.arrayObject?.append(sumObject.object)
                    }
                    cnt+=1
                }
                rowWithFormattedDate.removeValue(forKey: "sum")
                let jsonString = changeJsonString(useData: rowWithFormattedDate)
                if let jsonData = jsonString.data(using: .utf8) {
                    let jsonObject = try JSON(data: jsonData)
                    jsonArray.arrayObject?.append(jsonObject.object)
                }
            }

            try dbConnect().close()
        }
        
        var sum: Int? = 0
        if let sumValue = sumResult.array?.first?["sum"].int {
            sum = sumValue
        }
        
        var page_count: Int? = 0
        if(sum != 0 && limit != 0){
            page_count = sum!/limit!
        }
        resultData = changeJsonObject(useData: ["result": "OK", "sum": sum, "sort": sort, "page_count": page_count, "value": jsonArray])
    }
    return resultData
}

// Get user asynchronously
public func getUsersAsync(owner: String) async throws -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
    
    do {
        let accountQuery =
            " SELECT" +
                " owner_eigenvalue As owner," +
                " network As network," +
                " user_account As account," +
                " user_type As type," +
                " (SELECT count(*) FROM users_table WHERE owner_eigenvalue = '\(owner)') AS sum" +
            " FROM" +
                " users_table" +
            " WHERE" +
                " owner_eigenvalue = '\(owner)'"
        
        var jsonArray: JSON = JSON([])
        var sumResult: JSON = JSON([])
        
        do {
            var cnt: Int = 0
            let sql = try dbConnect().prepare(accountQuery)
            let res = try sql.query([])
            while let row = try res.readRow() {
                // Change Date to String before converting to JSON
                var rowWithFormattedDate = row
                
                if(cnt == 0){
                    let sumString = changeJsonString(useData: rowWithFormattedDate)
                    if let sumData = sumString.data(using: .utf8) {
                        let sumObject = try JSON(data: sumData)
                        sumResult.arrayObject?.append(sumObject.object)
                    }
                    cnt+=1
                }
                rowWithFormattedDate.removeValue(forKey: "sum")
                let jsonString = changeJsonString(useData: rowWithFormattedDate)
                if let jsonData = jsonString.data(using: .utf8) {
                    let jsonObject = try JSON(data: jsonData)
                    jsonArray.arrayObject?.append(jsonObject.object)
                }
            }

            try dbConnect().close()
        }
        var sum: Int? = 0
        if let sumValue = sumResult.array?.first?["sum"].int {
            sum = sumValue
        }
        
        resultData = changeJsonObject(useData: ["result": "OK", "sum": sum, "value": jsonArray])
    }

    return resultData
}

public func signMessage(
    network: String,
    fromAddress: String,
    collection_id: String,
    token_id: String,
    prefix: String) async throws -> String {
    
    let accountInfo = try await getAccountInfoAsync(account: fromAddress)
    var privateKey = ""
    if(accountInfo["value"] != []){
        let value = accountInfo["value"]
        if value[0]["private"].string != nil {
            privateKey = value[0]["private"].string!
        }
    }
    
    networkSettings(network: network)
    var url = try await URL(string:rpcUrl)
    let web3 = try await Web3.new(url!)
    
    let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
    let dataKey = Data.fromHex(formattedKey)!
    let keystore = try await EthereumKeystoreV3(privateKey: dataKey, password: "")
    let keystoreManager = KeystoreManager([keystore!])
    web3.addKeystoreManager(keystoreManager)
    
    let message = prefix+network+fromAddress+collection_id+token_id
    
    let expectedAddress = keystoreManager.addresses![0]
    
    let signature = try await web3.personal.signPersonalMessage(message: message.data(using: .utf8)!, from: expectedAddress, password: "")
    
    return signature.toHexString()
    
}

public func getSignerAddressFromSignature(
    network: String,
    signature:String,
    fromAddress: String,
    collection_id: String,
    token_id: String,
    prefix: String) async throws -> String {
    
    let accountInfo = try await getAccountInfoAsync(account: fromAddress)
    var privateKey = ""
    if(accountInfo["value"] != []){
        let value = accountInfo["value"]
        if value[0]["private"].string != nil {
            privateKey = value[0]["private"].string!
        }
    }
    
    networkSettings(network: network)
    var url = try await URL(string:rpcUrl)
    let web3 = try await Web3.new(url!)
    
    let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
    let dataKey = Data.fromHex(formattedKey)!
    let keystore = try await EthereumKeystoreV3(privateKey: dataKey, password: "")
    let keystoreManager = KeystoreManager([keystore!])
    web3.addKeystoreManager(keystoreManager)
    
    let message = prefix+network+fromAddress+collection_id+token_id

    let expectedAddress = keystoreManager.addresses![0]

    let newSignature = try await web3.personal.signPersonalMessage(message: message.data(using: .utf8)!, from: expectedAddress, password: "")
    if(signature == newSignature.toHexString()) {
        let signer = web3.personal.recoverAddress(message: message.data(using: .utf8)!, signature: newSignature)
        return signer!.address
    } else {
        return "서명이 일치하지 않습니다."
    }
        
}
