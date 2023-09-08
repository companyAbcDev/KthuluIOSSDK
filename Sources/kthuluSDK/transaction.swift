//
//  transaction.swift
//  BinaryFrameworksTest
//
//  Created by Dev ABC on 2023/05/18.
//

import Foundation
import BigInt
import web3swift
import Web3Core
import SwiftyJSON

public func sendTransactionAsync(network: String, from: String, to: String, amount: String) async throws -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    var result: JSON = JSON()
    resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
    
    do {
        let accountInfo = try await getAccountInfoAsync(account: from)
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
        
        let gasLimitEstimate = try await getEstimateGasAsync(network: network, tx_type: "transferCoin", from: from, to: to, amount: amount)
        let gasPriceEstimate = try await getEstimateGasAsync(network: network, tx_type: "baseFee")
        
        var gasPrice: BigUInt? = nil
        var gasLimit: BigUInt? = nil
        
        if let valueArray = gasPriceEstimate["value"].arrayObject as? [[String: Any]] {
            if let gas = valueArray[0]["gas"] as? String {
                gasPrice = BigUInt(gas)
            }
        }
        if let valueArray = gasLimitEstimate["value"].arrayObject as? [[String: Any]] {
            if let gas = valueArray[0]["gas"] as? String {
                gasLimit = BigUInt(gas)
            }
        }
        
        let fromAddress = EthereumAddress(from)
        let toAddress = EthereumAddress(to)!
        let data = "0x".data(using: .utf8)!
        let nonce = try await web3.eth.getTransactionCount(for: fromAddress!, onBlock: .pending)
        guard let value = Utilities.parseToBigUInt(amount, decimals: 18) else {
            throw Web3Error.inputError(desc: "Cannot parse inputted amount")
        }
        
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:toAddress, nonce:nonce, chainID:chainID, value:value, data:data, gasLimit: gasLimit!, gasPrice: gasPrice)
        } else {
            transaction = CodableTransaction(type:.eip1559, to:toAddress, nonce:nonce, chainID:chainID, value:value, data:data, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 33000000000)
        }
        transaction?.from = fromAddress
        
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try await EthereumKeystoreV3(privateKey: dataKey, password: "")!
        let keystoreManager = KeystoreManager([keystore])
        web3.addKeystoreManager(keystoreManager)
        
        do {
            try Web3Signer.signTX(transaction: &transaction!,
                                  keystore: keystoreManager,
                                  account: transaction!.from ?? transaction!.sender ?? EthereumAddress.contractDeploymentAddress(),
                                  password: "")
        } catch {
            throw Web3Error.inputError(desc: "Failed to locally sign a transaction. \(error.localizedDescription)")
        }
        
        guard let transactionData = transaction!.encode(for: .transaction) else {
            throw Web3Error.dataError
        }
        
        let response = try await web3.eth.send(raw: transactionData)
        if(response.hash != nil){
            result["transaction_hash"] = JSON(response.hash)
            resultArray.arrayObject?.append(result)
            resultData = changeJsonObject(useData:["result": "OK", "value": resultArray])
        } else {
            result["error"] = JSON("insufficient funds")
            resultArray.arrayObject?.append(result)
            resultData = changeJsonObject(useData:["result": "FAIL", "error": resultArray])
        }
        return resultData
    } catch let error{
        result["error"] = JSON(error.localizedDescription)
        resultArray.arrayObject?.append(result)
        resultData = changeJsonObject(useData:["result": "FAIL", "error": resultArray])
        return resultData
    }

}


public func sendTokenTransactionAsync(network: String, from: String, to: String, amount: String, token_id: String) async throws -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    var result: JSON = JSON()
    resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
    
    do {
        let accountInfo = try await getAccountInfoAsync(account: from)
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
        
        let gasLimitEstimate = try await getEstimateGasAsync(network: network, tx_type:"transferERC20", token_address: token_id, from: from, to: to, amount: amount)
        let gasPriceEstimate = try await getEstimateGasAsync(network: network, tx_type: "baseFee")
        
        var gasPrice: BigUInt? = nil
        var gasLimit: BigUInt? = nil
        
        if let valueArray = gasPriceEstimate["value"].arrayObject as? [[String: Any]] {
            if let gas = valueArray[0]["gas"] as? String {
                gasPrice = BigUInt(gas)
            }
        }
        if let valueArray = gasLimitEstimate["value"].arrayObject as? [[String: Any]] {
            if let gas = valueArray[0]["gas"] as? String {
                gasLimit = BigUInt(gas)
            }
        }
        let fromAddress = EthereumAddress(from)
        let toAddress = EthereumAddress(to)
        let token_id = EthereumAddress(token_id)!
        let contract = web3.contract(Web3.Utils.erc20ABI, at: token_id, abiVersion: 2)!
        let callResult = try await contract
            .createReadOperation("decimals")!
            .callContractMethod()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may not be ERC20 compatible, cannot get decimals")
        }
        decimals = decTyped
        let intDecimals = Int(decimals)
        guard let value = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Cannot parse inputted amount")
        }
        let nonce = try await web3.eth.getTransactionCount(for: fromAddress!, onBlock: .pending)
        let contractData = contract.contract.method("transfer", parameters: [toAddress, value], extraData: Data())
        
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:token_id, nonce:nonce, chainID:chainID, gasLimit: gasLimit!, gasPrice: gasPrice)
        } else {
            transaction = CodableTransaction(type:.eip1559, to:token_id, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 33000000000)
        }
        transaction?.from = fromAddress
        transaction?.data = contractData!
        
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try await EthereumKeystoreV3(privateKey: dataKey, password: "")!
        let keystoreManager = KeystoreManager([keystore])
        web3.addKeystoreManager(keystoreManager)
    
        do {
            try Web3Signer.signTX(transaction: &transaction!,
                                      keystore: keystoreManager,
                                      account: transaction!.from ?? transaction!.sender ?? EthereumAddress.contractDeploymentAddress(),
                                      password: "")
        } catch {
            throw Web3Error.inputError(desc: "Failed to locally sign a transaction. \(error.localizedDescription)")
        }
            
        guard let transactionData = transaction!.encode(for: .transaction) else {
            throw Web3Error.dataError
        }
        
        let response = try await web3.eth.send(raw: transactionData)
        if(response.hash != nil){
            result["transaction_hash"] = JSON(response.hash)
            resultArray.arrayObject?.append(result)
            resultData = changeJsonObject(useData:["result": "OK", "value": resultArray])
        } else {
            result["error"] = JSON("insufficient funds")
            resultArray.arrayObject?.append(result)
            resultData = changeJsonObject(useData:["result": "FAIL", "error": resultArray])
        }
        return resultData
    } catch let error{
        result["error"] = JSON(error.localizedDescription)
        resultArray.arrayObject?.append(result)
        resultData = changeJsonObject(useData:["result": "FAIL", "error": resultArray])
        return resultData
    }
}

public func deployErc20Async(network: String, owner: String, name: String!, symbol: String!, totalSupply: String) async throws -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    var result: JSON = JSON()
    resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
    
    do {
        networkSettings(network: network)
        var privateKey = ""
        let accountInfo = try await getAccountInfoAsync(account: owner)
        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        let ca = EthereumAddress(bridgeContractAddress)
        let decimals = 18
        let gasLimitEstimate = try await getEstimateGasAsync(network: network, tx_type: "deployERC20", from: owner, amount: totalSupply ,name: name, symbol: symbol)
        let gasPriceEstimate = try await getEstimateGasAsync(network: network, tx_type: "baseFee")
        
        var gasPrice: BigUInt? = nil
        var gasLimit: BigUInt? = nil
        
        if let valueArray = gasPriceEstimate["value"].arrayObject as? [[String: Any]] {
            if let gas = valueArray[0]["gas"] as? String {
                gasPrice = BigUInt(gas)
            }
        }
        if let valueArray = gasLimitEstimate["value"].arrayObject as? [[String: Any]] {
            if let gas = valueArray[0]["gas"] as? String {
                gasLimit = BigUInt(gas)
            }
        }
        
        let ownerAddress = EthereumAddress(owner)
        let nonce = try await web3.eth.getTransactionCount(for: ownerAddress!, onBlock: .pending)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(abiBridge, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "tbnb") {
            transaction = CodableTransaction(to:ca!, nonce:nonce, chainID:chainID, gasLimit: gasLimit!, gasPrice: gasPrice)
        } else {
            // tip 0.1gwei
            transaction = CodableTransaction(type:.eip1559, to:ca!, nonce:nonce, chainID:chainID, gasLimit: gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: BigUInt(maxPriorityFeePerGas))
        }
        transaction?.from = ownerAddress
        
        let intDecimals = Int(decimals)
        let value = Utilities.parseToBigUInt(totalSupply, decimals: intDecimals)!
        
        let contractData = contract.contract.method("deployWrapped20", parameters: [name,symbol,BigUInt(decimals),value], extraData: Data())
        
        transaction?.data = contractData!
        
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try await EthereumKeystoreV3(privateKey: dataKey, password: "")
        let keystoreManager = KeystoreManager([keystore!])
        web3.addKeystoreManager(keystoreManager)
        
        do {
            try Web3Signer.signTX(transaction: &transaction!,
                                  keystore: keystoreManager,
                                  account: transaction!.from ?? transaction!.sender ?? EthereumAddress.contractDeploymentAddress(),
                                  password: "")
        } catch {
            throw Web3Error.inputError(desc: "Failed to locally sign a transaction. \(error.localizedDescription)")
        }
        
        guard let transactionData = transaction!.encode(for: .transaction) else {
            throw Web3Error.dataError
        }
        
        let response = try await web3.eth.send(raw: transactionData)
        if(response.hash != nil){
            result["transaction_hash"] = JSON(response.hash)
            resultArray.arrayObject?.append(result)
            resultData = changeJsonObject(useData:["result": "OK", "value": resultArray])
        } else {
            result["error"] = JSON("insufficient funds")
            resultArray.arrayObject?.append(result)
            resultData = changeJsonObject(useData:["result": "FAIL", "error": resultArray])
        }
        return resultData
    } catch let error{
        result["error"] = JSON(error.localizedDescription)
        resultArray.arrayObject?.append(result)
        resultData = changeJsonObject(useData:["result": "FAIL", "error": resultArray])
        return resultData
    }
}

public func bridgeCoinAsync(network: String, to_network: String, from : String, amount : String) async throws -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    var result: JSON = JSON()
    resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
    do {
        networkSettings(network: network)
        var privateKey = ""
        let accountInfo = try await getAccountInfoAsync(account: from)
        let bridgeConfigContractAddress = EthereumAddress(bridgeConfigContractAddress)!

        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }
        let from = EthereumAddress(from)
        let bridgeContractAddress = EthereumAddress(bridgeContractAddress)
        networkSettings(network: network)
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPriceEstimate = try await getEstimateGasAsync(network: network, tx_type: "baseFee")
        var gasPrice: BigUInt? = nil
        
        if let valueArray = gasPriceEstimate["value"].arrayObject as? [[String: Any]] {
            if let gas = valueArray[0]["gas"] as? String {
                gasPrice = BigUInt(gas)
            }
        }
        
        let gasLimit = BigUInt(200000)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(abiBridge, at: bridgeContractAddress, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        
        guard let value = Utilities.parseToBigUInt(amount, decimals: 18) else {
            throw Web3Error.inputError(desc: "Cannot parse inputted amount")
        }
        
        var txFee = BigUInt(0)
        var networkHex = BigUInt(0)
        if(to_network == "POLYGON") {
            txFee = BigUInt(2000000000000000)
            networkHex = BigUInt(0x504f4c59474f4e)
        } else {
            txFee = BigUInt(2000000000000000)
            networkHex = BigUInt(0x4b4c4159544e)
        }
        
        if(network == "bnb" || network == "tbnb") {
            transaction = CodableTransaction(to:bridgeContractAddress!, nonce:nonce, chainID:chainID, value:txFee, gasLimit: gasLimit, gasPrice: gasPrice)
        } else {
            transaction = CodableTransaction(type:.eip1559, to:bridgeContractAddress!, nonce:nonce, chainID:chainID, value:txFee, gasLimit:gasLimit, maxFeePerGas: gasPrice, maxPriorityFeePerGas: BigUInt(maxPriorityFeePerGas))
        }
        transaction?.from = from
        let contractData = contract.contract.method("moveFromETHER", parameters: [BigUInt(networkHex)], extraData: Data())
        transaction?.data = contractData!
        
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try await EthereumKeystoreV3(privateKey: dataKey, password: "")
        let keystoreManager = KeystoreManager([keystore!])
        web3.addKeystoreManager(keystoreManager)
        
        do {
            try Web3Signer.signTX(transaction: &transaction!,
                                  keystore: keystoreManager,
                                  account: transaction!.from ?? transaction!.sender ?? EthereumAddress.contractDeploymentAddress(),
                                  password: "")
        } catch {
            throw Web3Error.inputError(desc: "Failed to locally sign a transaction. \(error.localizedDescription)")
        }
        
        guard let transactionData = transaction!.encode(for: .transaction) else {
            throw Web3Error.dataError
        }
        
        let response = try await web3.eth.send(raw: transactionData)
        result["result"] = JSON("OK")
        result["transactionHash"] = JSON(response.hash)
        return result
    } catch let error{
        result["result"] = JSON("FAIL")
        result["transactionHash"] = JSON(error.localizedDescription)
        return result
    }
}

public func bridgeTokenAsync(network: String, to_network: String, from : String,token_id : String, amount : String) async throws -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    var result: JSON = JSON()
    resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
    do {
        networkSettings(network: network)
        var privateKey = ""
        let accountInfo = try await getAccountInfoAsync(account: from)
        let bridgeConfigContractAddress = EthereumAddress(bridgeConfigContractAddress)!

        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }
        let from = EthereumAddress(from)
        let bridgeContractAddress = EthereumAddress(bridgeContractAddress)
        networkSettings(network: network)
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPriceEstimate = try await getEstimateGasAsync(network: network, tx_type: "baseFee")
        var gasPrice: BigUInt? = nil
        
        if let valueArray = gasPriceEstimate["value"].arrayObject as? [[String: Any]] {
            if let gas = valueArray[0]["gas"] as? String {
                gasPrice = BigUInt(gas)
            }
        }
        
        let gasLimit = BigUInt(200000)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(abiBridge, at: bridgeContractAddress, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        
        guard let value = Utilities.parseToBigUInt(amount, decimals: 18) else {
            throw Web3Error.inputError(desc: "Cannot parse inputted amount")
        }
        
        var txFee = BigUInt(0)
        var networkHex = BigUInt(0)
        if(to_network == "POLYGON") {
            txFee = BigUInt(2000000000000000)
            networkHex = BigUInt(0x504f4c59474f4e)
        } else {
            txFee = BigUInt(2000000000000000)
            networkHex = BigUInt(0x4b4c4159544e)
        }
        
        if(network == "bnb" || network == "tbnb") {
            transaction = CodableTransaction(to:bridgeContractAddress!, nonce:nonce, chainID:chainID, value:txFee, gasLimit: gasLimit, gasPrice: gasPrice)
        } else {
            transaction = CodableTransaction(type:.eip1559, to:bridgeContractAddress!, nonce:nonce, chainID:chainID, value:txFee, gasLimit:gasLimit, maxFeePerGas: gasPrice, maxPriorityFeePerGas: BigUInt(maxPriorityFeePerGas))
        }
        transaction?.from = from
        let contractData = contract.contract.method("moveFromERC20", parameters: [BigUInt(networkHex), Address(token_id), BigUInt(value)], extraData: Data())
        transaction?.data = contractData!
        
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try await EthereumKeystoreV3(privateKey: dataKey, password: "")
        let keystoreManager = KeystoreManager([keystore!])
        web3.addKeystoreManager(keystoreManager)
        
        do {
            try Web3Signer.signTX(transaction: &transaction!,
                                  keystore: keystoreManager,
                                  account: transaction!.from ?? transaction!.sender ?? EthereumAddress.contractDeploymentAddress(),
                                  password: "")
        } catch {
            throw Web3Error.inputError(desc: "Failed to locally sign a transaction. \(error.localizedDescription)")
        }
        
        guard let transactionData = transaction!.encode(for: .transaction) else {
            throw Web3Error.dataError
        }
        
        let response = try await web3.eth.send(raw: transactionData)
        result["result"] = JSON("OK")
        result["transactionHash"] = JSON(response.hash)
        return result
    } catch let error{
        result["result"] = JSON("FAIL")
        result["transactionHash"] = JSON(error.localizedDescription)
        return result
    }
}

public func tokenSwapAppoveAsync(
    network: String,
    from: String,
    from_token_id: String,
    to_token_id:String?=nil,
    amount: String) async throws -> JSON {
        var resultArray: JSON = JSON([])
        var resultData: JSON = JSON()
        var result: JSON = JSON()
        resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
        do {
            networkSettings(network: network)
            let accountInfo = try await getAccountInfoAsync(account: from)
            guard let privateKey = accountInfo["value"][0]["private"].string else {
                print("Error while fetching the private key")
                throw Web3Error.dataError
            }
            
            var to_token_id = to_token_id
            if to_token_id == nil {
                switch network {
                case "ethereum":
                    to_token_id = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
                case "cypress":
                    to_token_id = "0"
                case "polygon":
                    to_token_id = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270"
                case "bnb":
                    to_token_id = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c"
                default:
                    throw Web3Error.dataError
                }
            }
            var uniswapV2RouterAddress = EthereumAddress(uniswapV2RouterAddress)
            var uniswapV2FactoryAddress = EthereumAddress(uniswapV2FactoryAddress)
            
            let url = try await URL(string: rpcUrl)
            let web3 = try await Web3.new(url!)
            let credentials = try await EthereumKeystoreV3(privateKey: Data.fromHex(privateKey)!, password: "")
            
            var transactionHash = ""
            
            let token_id = EthereumAddress(from_token_id)!
            var contract = web3.contract(Web3.Utils.erc20ABI, at: token_id, abiVersion: 2)!
            let callResult = try await contract
                .createReadOperation("decimals")!
                .callContractMethod()
            var decimals = BigUInt(0)
            guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
                throw Web3Error.inputError(desc: "Contract may not be ERC20 compatible, cannot get decimals")
            }
            decimals = decTyped
            let intDecimals = Int(decimals)
            guard let amountInWei = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
                throw Web3Error.inputError(desc: "Cannot parse inputted amount")
            }
            
            let deadline = Date().addingTimeInterval(600).timeIntervalSince1970
            contract = web3.contract(abiSwapFactory, at: uniswapV2FactoryAddress, abiVersion: 2)!
            
            // Set up the parameters for the method call
            let parameters: [Any] = [from_token_id, to_token_id]
            
            let readOp = contract.createReadOperation("getPair", parameters: parameters)!
            readOp.transaction.from = EthereumAddress(from)
            
            let getPairResponse = try await readOp.callContractMethod()
            
            
            let ethereumAddress = getPairResponse["0"] as? EthereumAddress
            
            let addressString = ethereumAddress!.address
            let getPair = BigUInt(addressString.dropFirst(2), radix: 16)!
            var from = EthereumAddress(from)
            if getPair != BigUInt.zero {
                
                let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
                let gasPriceEstimate = try await getEstimateGasAsync(network: network, tx_type: "baseFee")
                var gasPrice: BigUInt? = nil
                
                if let valueArray = gasPriceEstimate["value"].arrayObject as? [[String: Any]] {
                    if let gas = valueArray[0]["gas"] as? String {
                        gasPrice = BigUInt(gas)
                    }
                }
                
                let gasLimit = BigUInt(200000)
                
                var transaction: CodableTransaction? = nil
                if(network == "bnb" || network == "tbnb") {
                    transaction = CodableTransaction(to:EthereumAddress(from_token_id)!, nonce:nonce, chainID:chainID, gasLimit: gasLimit, gasPrice: gasPrice)
                } else {
                    // tip 0.1gwei
                    transaction = CodableTransaction(type:.eip1559, to:EthereumAddress(from_token_id)!, nonce:nonce, chainID:chainID, gasLimit: gasLimit, maxFeePerGas: gasPrice, maxPriorityFeePerGas: BigUInt(maxPriorityFeePerGas))
                }
                transaction?.from = from
                
                contract = web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress(from_token_id), abiVersion: 2)!
                
                let deadlineInSeconds = Int(deadline)
                
                let contractData = contract.contract.method("approve", parameters: [uniswapV2RouterAddress, amountInWei], extraData: Data())
                
                transaction?.data = contractData!
                
                let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
                let dataKey = Data.fromHex(formattedKey)!
                let keystore = try await EthereumKeystoreV3(privateKey: dataKey, password: "")
                let keystoreManager = KeystoreManager([keystore!])
                web3.addKeystoreManager(keystoreManager)
                
                do {
                    try Web3Signer.signTX(transaction: &transaction!,
                                          keystore: keystoreManager,
                                          account: transaction!.from ?? transaction!.sender ?? EthereumAddress.contractDeploymentAddress(),
                                          password: "")
                } catch {
                    throw Web3Error.inputError(desc: "Failed to locally sign a transaction. \(error.localizedDescription)")
                }
                
                guard let transactionData = transaction!.encode(for: .transaction) else {
                    throw Web3Error.dataError
                }
                
                let response = try await web3.eth.send(raw: transactionData)
                if(response.hash != nil){
                    result["transaction_hash"] = JSON(response.hash)
                    resultArray.arrayObject?.append(result)
                    resultData = changeJsonObject(useData:["result": "OK", "value": resultArray])
                } else {
                    result["error"] = JSON("insufficient funds")
                    resultArray.arrayObject?.append(result)
                    resultData = changeJsonObject(useData:["result": "FAIL", "error": resultArray])
                }
            } else {
                // Address is zero
                result["error"] = JSON("pair not found")
                resultArray.arrayObject?.append(result)
                resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
            }
        } catch let error {
            result["error"] = JSON(error.localizedDescription)
            resultArray.arrayObject?.append(result)
            resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
        }
    return resultData
}

public func coinForTokenswapAsync(
    network: String,
    from: String,
    to_token_id: String,
    amount: String) async throws -> JSON {

    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    var result: JSON = JSON()
    resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])

        do {
            networkSettings(network: network)
            let accountInfo = try await getAccountInfoAsync(account: from)
            guard let privateKey = accountInfo["value"][0]["private"].string else {
                print("Error while fetching the private key")
                throw Web3Error.dataError
            }
            
            let from_token_id: String
            switch network {
            case "ethereum":
                from_token_id = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
            case "cypress":
                from_token_id = "0"
            case "polygon":
                from_token_id = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270"
            case "bnb":
                from_token_id = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c"
            default:
                throw Web3Error.dataError
            }
            var uniswapV2RouterAddress = EthereumAddress(uniswapV2RouterAddress)
            var uniswapV2FactoryAddress = EthereumAddress(uniswapV2FactoryAddress)
            
            let url = try await URL(string: rpcUrl)
            let web3 = try await Web3.new(url!)
            let credentials = try await EthereumKeystoreV3(privateKey: Data.fromHex(privateKey)!, password: "")
            
            var transactionHash = ""
            guard let amountInWei = Utilities.parseToBigUInt(amount, decimals: 18) else {
                throw Web3Error.inputError(desc: "Cannot parse inputted amount")
            }
            
            let deadline = Date().addingTimeInterval(600).timeIntervalSince1970
            var contract = web3.contract(abiSwapFactory, at: uniswapV2FactoryAddress, abiVersion: 2)!
            
            // Set up the parameters for the method call
            let parameters: [Any] = [from_token_id, to_token_id]
            
            let readOp = contract.createReadOperation("getPair", parameters: parameters)!
            readOp.transaction.from = EthereumAddress(from)
            
            let getPairResponse = try await readOp.callContractMethod()
            
            
            let ethereumAddress = getPairResponse["0"] as? EthereumAddress
            
            let addressString = ethereumAddress!.address
            let getPair = BigUInt(addressString.dropFirst(2), radix: 16)!
            var from = EthereumAddress(from)
            if getPair != BigUInt.zero {
                
                let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
                let gasPriceEstimate = try await getEstimateGasAsync(network: network, tx_type: "baseFee")
                var gasPrice: BigUInt? = nil
                
                if let valueArray = gasPriceEstimate["value"].arrayObject as? [[String: Any]] {
                    if let gas = valueArray[0]["gas"] as? String {
                        gasPrice = BigUInt(gas)
                    }
                }
                
                let gasLimit = BigUInt(200000)
                
                var transaction: CodableTransaction? = nil
                if(network == "bnb" || network == "tbnb") {
                    transaction = CodableTransaction(to:uniswapV2RouterAddress!, nonce:nonce, chainID:chainID, value:BigUInt(amountInWei), gasLimit: 200000, gasPrice: gasPrice)
                } else {
                    // tip 0.1gwei
                    transaction = CodableTransaction(type:.eip1559, to:uniswapV2RouterAddress!, nonce:nonce, chainID:chainID, value:BigUInt(amountInWei), gasLimit: gasLimit, maxFeePerGas: gasPrice, maxPriorityFeePerGas: BigUInt(maxPriorityFeePerGas))
                }
                transaction?.from = from
                
                contract = web3.contract(abiSwapRouter, at: uniswapV2RouterAddress, abiVersion: 2)!
                
                let deadlineInSeconds = Int(deadline)

                let contractData = contract.contract.method("swapExactETHForTokens", parameters: [BigUInt.zero, parameters, from, deadlineInSeconds], extraData: Data())

                transaction?.data = contractData!
                       
               let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
               let dataKey = Data.fromHex(formattedKey)!
               let keystore = try await EthereumKeystoreV3(privateKey: dataKey, password: "")
               let keystoreManager = KeystoreManager([keystore!])
               web3.addKeystoreManager(keystoreManager)
               
               do {
                   try Web3Signer.signTX(transaction: &transaction!,
                                         keystore: keystoreManager,
                                         account: transaction!.from ?? transaction!.sender ?? EthereumAddress.contractDeploymentAddress(),
                                         password: "")
               } catch {
                   throw Web3Error.inputError(desc: "Failed to locally sign a transaction. \(error.localizedDescription)")
               }
               
               guard let transactionData = transaction!.encode(for: .transaction) else {
                   throw Web3Error.dataError
               }
               
               let response = try await web3.eth.send(raw: transactionData)
               if(response.hash != nil){
                   result["transaction_hash"] = JSON(response.hash)
                   resultArray.arrayObject?.append(result)
                   resultData = changeJsonObject(useData:["result": "OK", "value": resultArray])
               } else {
                   result["error"] = JSON("insufficient funds")
                   resultArray.arrayObject?.append(result)
                   resultData = changeJsonObject(useData:["result": "FAIL", "error": resultArray])
               }
            } else {
                // Address is zero
                result["error"] = JSON("pair not found")
                resultArray.arrayObject?.append(result)
                resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
            }
        } catch let error {
            result["error"] = JSON(error.localizedDescription)
            resultArray.arrayObject?.append(result)
            resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
        }
    return resultData
}


public func tokenForTokenswapAsync(
    network: String,
    from: String,
    from_token_id: String,
    to_token_id: String,
    amount: String) async throws -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    var result: JSON = JSON()
    resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])

        do {
            networkSettings(network: network)
            let accountInfo = try await getAccountInfoAsync(account: from)
            guard let privateKey = accountInfo["value"][0]["private"].string else {
                print("Error while fetching the private key")
                throw Web3Error.dataError
            }
            var uniswapV2RouterAddress = EthereumAddress(uniswapV2RouterAddress)
            var uniswapV2FactoryAddress = EthereumAddress(uniswapV2FactoryAddress)
            
            let url = try await URL(string: rpcUrl)
            let web3 = try await Web3.new(url!)
            let credentials = try await EthereumKeystoreV3(privateKey: Data.fromHex(privateKey)!, password: "")
            
            var transactionHash = ""
            
            var contract = web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress(from_token_id)!, abiVersion: 2)!
            
            let callResult = try await contract
                .createReadOperation("decimals")!
                .callContractMethod()
            var decimals = BigUInt(0)
            guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
                throw Web3Error.inputError(desc: "Contract may not be ERC20 compatible, cannot get decimals")
            }
            decimals = decTyped
            let intDecimals = Int(decimals)
            guard let amountInWei = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
                throw Web3Error.inputError(desc: "Cannot parse inputted amount")
            }
            
            let deadline = Date().addingTimeInterval(600).timeIntervalSince1970
            contract = web3.contract(abiSwapFactory, at: uniswapV2FactoryAddress, abiVersion: 2)!
            
            // Set up the parameters for the method call
            let parameters: [Any] = [from_token_id, to_token_id]
            
            let readOp = contract.createReadOperation("getPair", parameters: parameters)!
            readOp.transaction.from = EthereumAddress(from)
            
            let getPairResponse = try await readOp.callContractMethod()
            
            
            let ethereumAddress = getPairResponse["0"] as? EthereumAddress
            
            let addressString = ethereumAddress!.address
            let getPair = BigUInt(addressString.dropFirst(2), radix: 16)!
            var from = EthereumAddress(from)
            if getPair != BigUInt.zero {
                
                let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
                let gasPriceEstimate = try await getEstimateGasAsync(network: network, tx_type: "baseFee")
                var gasPrice: BigUInt? = nil
                
                if let valueArray = gasPriceEstimate["value"].arrayObject as? [[String: Any]] {
                    if let gas = valueArray[0]["gas"] as? String {
                        gasPrice = BigUInt(gas)
                    }
                }
                
                let gasLimit = BigUInt(200000)
                
                var transaction: CodableTransaction? = nil
                if(network == "bnb" || network == "tbnb") {
                    transaction = CodableTransaction(to:uniswapV2RouterAddress!, nonce:nonce, chainID:chainID, gasLimit: gasLimit, gasPrice: gasPrice)
                } else {
                    // tip 0.1gwei
                    transaction = CodableTransaction(type:.eip1559, to:uniswapV2RouterAddress!, nonce:nonce, chainID:chainID, gasLimit: gasLimit, maxFeePerGas: gasPrice, maxPriorityFeePerGas: BigUInt(maxPriorityFeePerGas))
                }
                transaction?.from = from
                
                contract = web3.contract(abiSwapRouter, at: uniswapV2RouterAddress, abiVersion: 2)!
                
                let deadlineInSeconds = Int(deadline)

                let contractData = contract.contract.method("swapExactTokensForTokens", parameters: [amountInWei, BigUInt.zero, parameters, from, deadlineInSeconds], extraData: Data())

                transaction?.data = contractData!
                       
               let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
               let dataKey = Data.fromHex(formattedKey)!
               let keystore = try await EthereumKeystoreV3(privateKey: dataKey, password: "")
               let keystoreManager = KeystoreManager([keystore!])
               web3.addKeystoreManager(keystoreManager)
               
               do {
                   try Web3Signer.signTX(transaction: &transaction!,
                                         keystore: keystoreManager,
                                         account: transaction!.from ?? transaction!.sender ?? EthereumAddress.contractDeploymentAddress(),
                                         password: "")
               } catch {
                   throw Web3Error.inputError(desc: "Failed to locally sign a transaction. \(error.localizedDescription)")
               }
               
               guard let transactionData = transaction!.encode(for: .transaction) else {
                   throw Web3Error.dataError
               }
               
               let response = try await web3.eth.send(raw: transactionData)
               if(response.hash != nil){
                   result["transaction_hash"] = JSON(response.hash)
                   resultArray.arrayObject?.append(result)
                   resultData = changeJsonObject(useData:["result": "OK", "value": resultArray])
               } else {
                   result["error"] = JSON("insufficient funds")
                   resultArray.arrayObject?.append(result)
                   resultData = changeJsonObject(useData:["result": "FAIL", "error": resultArray])
               }
            } else {
                // Address is zero
                result["error"] = JSON("pair not found")
                resultArray.arrayObject?.append(result)
                resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
            }
        } catch let error {
            result["error"] = JSON(error.localizedDescription)
            resultArray.arrayObject?.append(result)
            resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
        }
    return resultData
}


public func tokenForCoinswapAsync(
    network: String,
    from: String,
    from_token_id: String,
    amount: String) async throws -> JSON {

    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    var result: JSON = JSON()
    resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])

        do {
            networkSettings(network: network)
            let accountInfo = try await getAccountInfoAsync(account: from)
            guard let privateKey = accountInfo["value"][0]["private"].string else {
                print("Error while fetching the private key")
                throw Web3Error.dataError
            }
            let to_token_id: String
            switch network {
            case "ethereum":
                to_token_id = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
            case "cypress":
                to_token_id = "0"
            case "polygon":
                to_token_id = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270"
            case "bnb":
                to_token_id = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c"
            default:
                throw Web3Error.dataError
            }
            var uniswapV2RouterAddress = EthereumAddress(uniswapV2RouterAddress)
            var uniswapV2FactoryAddress = EthereumAddress(uniswapV2FactoryAddress)
            
            let url = try await URL(string: rpcUrl)
            let web3 = try await Web3.new(url!)
            let credentials = try await EthereumKeystoreV3(privateKey: Data.fromHex(privateKey)!, password: "")
            
            var transactionHash = ""
            var contract = web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress(from_token_id)!, abiVersion: 2)!
            
            let callResult = try await contract
                .createReadOperation("decimals")!
                .callContractMethod()
            var decimals = BigUInt(0)
            guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
                throw Web3Error.inputError(desc: "Contract may not be ERC20 compatible, cannot get decimals")
            }
            decimals = decTyped
            let intDecimals = Int(decimals)
            guard let amountInWei = Utilities.parseToBigUInt(amount, decimals: intDecimals) else {
                throw Web3Error.inputError(desc: "Cannot parse inputted amount")
            }
            
            let deadline = Date().addingTimeInterval(600).timeIntervalSince1970
            contract = web3.contract(abiSwapFactory, at: uniswapV2FactoryAddress, abiVersion: 2)!
            
            // Set up the parameters for the method call
            let parameters: [Any] = [from_token_id, to_token_id]
            
            let readOp = contract.createReadOperation("getPair", parameters: parameters)!
            readOp.transaction.from = EthereumAddress(from)
            
            let getPairResponse = try await readOp.callContractMethod()
            
            
            let ethereumAddress = getPairResponse["0"] as? EthereumAddress
            
            let addressString = ethereumAddress!.address
            let getPair = BigUInt(addressString.dropFirst(2), radix: 16)!
            var from = EthereumAddress(from)
            if getPair != BigUInt.zero {
                
                let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
                let gasPriceEstimate = try await getEstimateGasAsync(network: network, tx_type: "baseFee")
                var gasPrice: BigUInt? = nil
                
                if let valueArray = gasPriceEstimate["value"].arrayObject as? [[String: Any]] {
                    if let gas = valueArray[0]["gas"] as? String {
                        gasPrice = BigUInt(gas)
                    }
                }
                
                let gasLimit = BigUInt(200000)
                
                var transaction: CodableTransaction? = nil
                if(network == "bnb" || network == "tbnb") {
                    transaction = CodableTransaction(to:uniswapV2RouterAddress!, nonce:nonce, chainID:chainID, gasLimit: gasLimit, gasPrice: gasPrice)
                } else {
                    // tip 0.1gwei
                    transaction = CodableTransaction(type:.eip1559, to:uniswapV2RouterAddress!, nonce:nonce, chainID:chainID, gasLimit: gasLimit, maxFeePerGas: gasPrice, maxPriorityFeePerGas: BigUInt(maxPriorityFeePerGas))
                }
                transaction?.from = from
                
                contract = web3.contract(abiSwapRouter, at: uniswapV2RouterAddress, abiVersion: 2)!
                
                let deadlineInSeconds = Int(deadline)

                let contractData = contract.contract.method("swapExactTokensForETH", parameters: [amountInWei,BigUInt.zero, parameters, from, deadlineInSeconds], extraData: Data())

                transaction?.data = contractData!
                       
               let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
               let dataKey = Data.fromHex(formattedKey)!
               let keystore = try await EthereumKeystoreV3(privateKey: dataKey, password: "")
               let keystoreManager = KeystoreManager([keystore!])
               web3.addKeystoreManager(keystoreManager)
               
               do {
                   try Web3Signer.signTX(transaction: &transaction!,
                                         keystore: keystoreManager,
                                         account: transaction!.from ?? transaction!.sender ?? EthereumAddress.contractDeploymentAddress(),
                                         password: "")
               } catch {
                   throw Web3Error.inputError(desc: "Failed to locally sign a transaction. \(error.localizedDescription)")
               }
               
               guard let transactionData = transaction!.encode(for: .transaction) else {
                   throw Web3Error.dataError
               }
               
               let response = try await web3.eth.send(raw: transactionData)
               if(response.hash != nil){
                   result["transaction_hash"] = JSON(response.hash)
                   resultArray.arrayObject?.append(result)
                   resultData = changeJsonObject(useData:["result": "OK", "value": resultArray])
               } else {
                   result["error"] = JSON("insufficient funds")
                   resultArray.arrayObject?.append(result)
                   resultData = changeJsonObject(useData:["result": "FAIL", "error": resultArray])
               }
            } else {
                // Address is zero
                result["error"] = JSON("pair not found")
                resultArray.arrayObject?.append(result)
                resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
            }
        } catch let error {
            result["error"] = JSON(error.localizedDescription)
            resultArray.arrayObject?.append(result)
            resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
        }
    return resultData
}
