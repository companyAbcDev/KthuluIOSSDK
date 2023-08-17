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
        let accountInfo = try await getAccountInfo(account: from)
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
        
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "transferCoin", fromAddress: from, toAddress: to, tokenAmount: amount)!
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let fromAddress = EthereumAddress(from)
        let toAddress = EthereumAddress(to)!
        let data = "0x".data(using: .utf8)!
        let nonce = try await web3.eth.getTransactionCount(for: fromAddress!, onBlock: .pending)
        guard let value = Utilities.parseToBigUInt(amount, decimals: 18) else {
            throw Web3Error.inputError(desc: "Cannot parse inputted amount")
        }
        
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:toAddress, nonce:nonce, chainID:chainID, value:value, data:data, gasLimit: gasLimit, gasPrice: gasPrice)
        } else {
            transaction = CodableTransaction(type:.eip1559, to:toAddress, nonce:nonce, chainID:chainID, value:value, data:data, gasLimit:gasLimit, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 33000000000)
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
        let accountInfo = try await getAccountInfo(account: from)
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
        
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "transferERC20", tokenAddress: token_id, fromAddress: from, toAddress: to, tokenAmount: amount)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
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

public func deployErc20Async(network: String, owner: String, name: String, symbol: String, totalSupply: String) async throws -> JSON {
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON()
    var result: JSON = JSON()
    resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
    
    do {
        let accountInfo = try await getAccountInfo(account: owner)
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
        let ca = EthereumAddress(erc20DeployContractAddress)
        
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "deployERC20", fromAddress: owner, tokenAmount: totalSupply ,name: name, symbol: symbol)
        let ownerAddress = EthereumAddress(owner)
        let nonce = try await web3.eth.getTransactionCount(for: ownerAddress!, onBlock: .pending)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(erc20MumbaiAbi, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca!, nonce:nonce, chainID:chainID, gasLimit: gasLimit!, gasPrice: gasPrice)
        } else {
            // tip 0.1gwei
            transaction = CodableTransaction(type:.eip1559, to:ca!, nonce:nonce, chainID:chainID, gasLimit: gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 33000000000)
        }
        transaction?.from = ownerAddress
        let contractData = contract.contract.method("deployedERC20", parameters: [name,symbol,BigUInt(totalSupply), ownerAddress], extraData: Data())
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

public func mintErc20Async(network: String, publisherAddress: String, amount:String, ownerAddress: String) async throws -> JSON {
    var result: JSON = JSON()
    var value: JSON = JSON()
    do {
        let accountInfo = try await getAccountInfo(account: publisherAddress)
        var privateKey = ""
        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }
        let publisherAddress = EthereumAddress(publisherAddress)
        let ownerAddress = EthereumAddress(ownerAddress)
        let ca = EthereumAddress("")
        
        networkSettings(network: network)
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        
        let nonce = try await web3.eth.getTransactionCount(for: publisherAddress!, onBlock: .pending)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = BigUInt(4000000)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(abiWrappedERC721, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca!, nonce:nonce, chainID:chainID, gasLimit: 200000, gasPrice: gasPrice)
        } else {
            transaction = CodableTransaction(type:.eip1559, to:ca!, nonce:nonce, chainID:chainID, gasLimit:200000, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 1000000000)
        }
        transaction?.from = publisherAddress
        let contractData = contract.contract.method("mint", parameters: [ownerAddress,BigUInt(amount)], extraData: Data())
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
        result["transaction_hash"] = JSON(response.hash)
        return result
    } catch let error{
        result["result"] = JSON("FAIL")
        result["transaction_hash"] = JSON(error.localizedDescription)
        return result
    }
}
