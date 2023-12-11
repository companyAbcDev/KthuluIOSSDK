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
    
    let allowedStrings: Set<String> = ["ethereum", "cypress", "polygon", "bnb", "sepolia", "baobab", "mumbai", "tbnb"]

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

// Create accounts asynchronously
public func nftCreateAccountsAsync(network: [String]) async throws -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    var result: JSON = JSON()
    resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
    
    let allowedStrings: Set<String> = ["ethereum", "cypress", "polygon", "bnb", "sepolia", "baobab", "mumbai", "tbnb"]

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
                "account": user_account,
                "private": "0x\(privateKey.toHexString())",
                "mnemonic": mnemonics
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
    var result: JSON = JSON()
    var resultArray: JSON = JSON([])
    var resultData: JSON = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
    
    do {
        guard let address: JSON = loadJsonData(key: account.lowercased()) else {
            resultArray.arrayObject?.append(result)
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
        result["error"] = JSON(error.localizedDescription)
        resultArray.arrayObject?.append(result)
        resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
        return resultData
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
public func getTokenListAsync(network: String, owner: String, limit: Int? = 100, pageNumber: Int? = nil, sort: String? = nil) async throws -> JSON {
    var errorObject: [String:Any]
    var resultArray: [Any] = []

    let url = URL(string: "https://app.kthulu.io:3302/token/getTokenListAsync")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")

    var jsonPayload: [String: Any] = [
        "network": network,
        "account": owner,
        "limit": limit as Any,
        "page_number": pageNumber as Any,
        "sort": sort as Any
    ]
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: jsonPayload)
    } catch {
        throw error
    }

    do {
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                errorObject = ["error": "HTTP error code: \(httpResponse.statusCode)"]
                resultArray.append(errorObject)
                return changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
            }
        }

        do {
            if var jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // Check if "value" is an NSArray and convert it to an empty array if it is
                if var value = jsonResponse["value"] as? [Any] {
                    value = value.isEmpty ? [] : value
                    jsonResponse["value"] = value
                }
                return changeJsonObject(useData: jsonResponse)
            } else {
                throw NSError(domain: "Invalid Response", code: 0, userInfo: nil)
            }
        } catch {
            throw error
        }
    } catch {
        errorObject = ["error" : error.localizedDescription]
        resultArray.append(errorObject)
        return changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
    }
}

// Token transfer history
public func getTokenHistoryAsync(network: String,
                                 owner: String,
                                 token_id: String? = "0x0000000000000000000000000000000000000000",
                                 sort: String?="DESC",
                                 size: String?="100") async throws -> JSON {
    var jsonObject: JSON = JSON()
    var errorObject: [String:Any]
    var resultArray: [Any] = []
    
    let urlString = "https://app.kthulu.io:3302/token/history/\(network)/\(owner)/\(token_id!)/\(sort!)/\(size!)"
    
    // URLSession을 사용하여 데이터를 가져옵니다.
        if let url = URL(string: urlString) {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    jsonObject = changeJsonObject(useData: json)
                } else {
                    print("유효한 JSON 형식이 아닙니다.")
                    errorObject = ["error" : "유효한 JSON 형식이 아닙니다."]
                    resultArray.append(errorObject)
                    return changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
                }
            } catch {
                errorObject = ["error" : error]
                resultArray.append(errorObject)
                return changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
            }
        } else {
            errorObject = ["error" : "유효하지 않은 URL입니다"]
            resultArray.append(errorObject)
            return changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
        }

        return jsonObject
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
