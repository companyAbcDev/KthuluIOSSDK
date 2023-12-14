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
            transaction = CodableTransaction(type:.eip1559, to:toAddress, nonce:nonce, chainID:chainID, value:value, data:data, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: BigUInt(maxPriorityFeePerGas))
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
            transaction = CodableTransaction(type:.eip1559, to:token_id, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: BigUInt(maxPriorityFeePerGas))
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

        var to_network = to_network;
        switch to_network {
            case "ethereum":
                to_network = "ETHEREUM"
            case "cypress":
                to_network = "KLAYTN"
            case "polygon":
                to_network = "POLYGON"
            case "bnb":
                to_network = "BNBMAIN"
            case "sepolia":
                to_network = "SEPOLIA"
            case "baobab":
                to_network = "BAOBAB"
            case "mumbai":
                to_network = "MUMBAI"
            case "tbnb":
                to_network = "BNBTEST"
            default:
                to_network = ""
        }
        
        var txFeeData = try await getNetworkFeeAsync(network: network, to_network: to_network, fee_type: "token")
                
        var txFee: BigUInt?
        if let valueArray = txFeeData["value"].arrayObject as? [[String: Any]], let txFeeString = valueArray.first?["networkFee"] as? String {
            txFee = BigUInt(txFeeString)
        }
        
        print("value", value)
        print("txFee", txFee)

        let totalAmount = value + txFee!
        
        let networkHex = try await textToHex(to_network)
        
        if(network == "bnb" || network == "tbnb") {
            transaction = CodableTransaction(to:bridgeContractAddress!, nonce:nonce, chainID:chainID, value:totalAmount, gasLimit: gasLimit, gasPrice: gasPrice)
        } else {
            transaction = CodableTransaction(type:.eip1559, to:bridgeContractAddress!, nonce:nonce, chainID:chainID, value:totalAmount, gasLimit:gasLimit, maxFeePerGas: gasPrice, maxPriorityFeePerGas: BigUInt(maxPriorityFeePerGas))
        }
        transaction?.from = from
        let contractData = contract.contract.method("moveFromETHER", parameters: [networkHex], extraData: Data())
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
        result["transaction_hash"] = JSON(response.hash)
        resultArray.arrayObject?.append(result)
        resultData = changeJsonObject(useData:["result": "OK", "value": resultArray])
        return resultData
    } catch let error{
        result["error"] = JSON(error.localizedDescription)
        resultArray.arrayObject?.append(result)
        resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
        return resultData
    }
}

public func bridgeTokenAsync(network: String, to_network: String, from : String, amount : String) async throws -> JSON {
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
        
        let tokenAddresses: [String: [String: String]] = [
            "ethereum": [
                "cypress": "0x39AAB030b052350A79ca9cB1F8992230288C512b",
                "polygon": "0xdF9c65B589e1286D4361EcFFa516e1fbfA4526df",
                "bnb": "0xcd9f176125b244cf5e9ca537d4fbbd62f7cec402"
            ],
            "cypress": [
                "ethereum": "0x8d868082C214a23aA31E1862FF183426A3a81c07",
                "polygon": "0x085AB24e511bEa905bDe815FA38a11eEB507E206",
                "bnb": "0x655108c33bbe4e1dee19b15c2fee5a2cf73eea64"
            ],
            "polygon": [
                "ethereum": "0x8f663C94A255835DA908D52657d83B071E59D96a",
                "cypress": "0x4F92e336aF5129bA4cD6d8cFE5272dc45B61cb06",
                "bnb": "0x8216acee6664c9ba1d340f48041931ddc3e800db"
            ],
            "bnb": [
                "ethereum": "0x4354453f99bB208ab0a2e8774F929D7DC282A0f7",
                "cypress": "0x909CCb87D6Ee34742A89AD1f60c171007B46d7dB",
                "polygon": "0x60398bD8F17d3866fB6dE9545D3168CECA5d9a0c"
            ]
        ]

        guard let tokenAddress = tokenAddresses[network]?[to_network] else {
            throw NSError(domain: "Invalid main network type", code: 1, userInfo: nil)
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
        
        var to_network = to_network;
        switch to_network {
            case "ethereum":
                to_network = "ETHEREUM"
            case "cypress":
                to_network = "KLAYTN"
            case "polygon":
                to_network = "POLYGON"
            case "bnb":
                to_network = "BNBMAIN"
            case "sepolia":
                to_network = "SEPOLIA"
            case "baobab":
                to_network = "BAOBAB"
            case "mumbai":
                to_network = "MUMBAI"
            case "tbnb":
                to_network = "BNBTEST"
            default:
                to_network = ""
        }
        
        let networkHex = try await textToHex(to_network)
        
        var txFeeData = try await getNetworkFeeAsync(network: network, to_network: to_network, fee_type: "token")
                
        var txFee: BigUInt?
        if let valueArray = txFeeData["value"].arrayObject as? [[String: Any]], let txFeeString = valueArray.first?["networkFee"] as? String {
            txFee = BigUInt(txFeeString)
        }
        
        if(network == "bnb" || network == "tbnb") {
            transaction = CodableTransaction(to:bridgeContractAddress!, nonce:nonce, chainID:chainID, value:txFee!, gasLimit: gasLimit, gasPrice: gasPrice)
        } else {
            transaction = CodableTransaction(type:.eip1559, to:bridgeContractAddress!, nonce:nonce, chainID:chainID, value:txFee!, gasLimit:gasLimit, maxFeePerGas: gasPrice, maxPriorityFeePerGas: BigUInt(maxPriorityFeePerGas))
        }
        transaction?.from = from
        let contractData = contract.contract.method("moveFromERC20", parameters: [networkHex, Address(tokenAddress), BigUInt(value)], extraData: Data())
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
        
        result["transaction_hash"] = JSON(response.hash)
        resultArray.arrayObject?.append(result)
        resultData = changeJsonObject(useData:["result": "OK", "value": resultArray])
        return resultData
        
    } catch let error{
        result["error"] = JSON(error.localizedDescription)
        resultArray.arrayObject?.append(result)
        resultData = changeJsonObject(useData:["result": "FAIL", "value": resultArray])
        return resultData
    }
}

public func getExpectedAmountOutAsync(
    network: String,
    fromTokenId: String? = nil,
    toTokenId: String? = nil,
    amount: String
) async -> JSON {
    networkSettings(network: network)
    var jsonData = JSON()
    var resultArray: JSON = JSON([])
    var resultData: JSON = JSON(["result": "FAIL", "value": resultArray])
    
    let defaultTokenIds = [
        "ethereum": "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        "cypress": "0",
        "polygon": "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270",
        "bnb": "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c"
    ]
    
    let actualFromTokenId = fromTokenId ?? defaultTokenIds[network]
    let actualToTokenId = toTokenId ?? defaultTokenIds[network]
    
    if network == "cypress" {
        return JSON(["result": "FAIL", "value": [JSON(["error": "cypress is not supported"])]])
    }
    
    do {
        let url = try await URL(string: rpcUrl)
        let web3 = try await Web3.new(url!)
        // Getting pair using the getPair function of the contract
        let contract = web3.contract(abiSwapFactory, at: EthereumAddress(uniswapV2FactoryAddress), abiVersion: 2)!
        guard let readOperation = contract.createReadOperation("getPair", parameters: [actualFromTokenId, actualToTokenId]) else {
            throw Web3Error.dataError // 혹은 적절한 에러 메시지와 함께 다른 에러 유형을 던질 수 있습니다.
        }
        let getPairResponse = try await readOperation.callContractMethod()
        
        guard let ethereumAddress = getPairResponse["0"] as? EthereumAddress else {
            throw Web3Error.dataError
        }

        let addressString = ethereumAddress.address
        let getPair = BigUInt(addressString.dropFirst(2), radix: 16)!
        if getPair == BigUInt.zero {
            throw Web3Error.dataError
        } else {
            
            // Decimals of the fromToken
            var contract = web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress(actualFromTokenId!)!, abiVersion: 2)!
            var callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
            guard let fromDecimalsBigUInt = callResult["0"] as? BigUInt else {
                throw Web3Error.dataError
            }
            let fromDecimals = Int(fromDecimalsBigUInt)

            let decimalMultiplier = BigUInt(10).power(fromDecimals)
            guard let amountInWei = Utilities.parseToBigUInt(amount, decimals: fromDecimals) else {
                throw Web3Error.inputError(desc: "Cannot parse inputted amount")
            }

            // Get amounts out
            contract = web3.contract(abiSwapRouter, at: EthereumAddress(uniswapV2RouterAddress)!, abiVersion: 2)!
            let parameters: [Any] = [amountInWei, [EthereumAddress(actualFromTokenId!)!, EthereumAddress(actualToTokenId!)!]]
            let amountsOutResponse = try await contract.createReadOperation("getAmountsOut", parameters: parameters)!.callContractMethod()

            guard let amountsOut = amountsOutResponse["0"] as? [BigUInt] else {
                throw Web3Error.dataError
            }

            // Decimals of the toToken
            contract = web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress(actualToTokenId!)!, abiVersion: 2)!
            callResult = try await contract.createReadOperation("decimals")!.callContractMethod()
            guard let toDecimalsBigUInt = callResult["0"] as? BigUInt else {
                throw Web3Error.dataError
            }
            let toDecimals = Int(toDecimalsBigUInt)
            
            if let lastAmountOut = amountsOut.last {
                let newBalance = Double(lastAmountOut) / pow(10.0, Double(toDecimals))
                print("newBalance", newBalance)
                jsonData["balnace"] = JSON(newBalance)
                resultArray.arrayObject?.append(jsonData)
                resultData = changeJsonObject(useData:["result": "OK", "value": resultArray])
            }

        }
    } catch let error {
        resultArray = JSON([])
        jsonData["error"] = JSON(error.localizedDescription)
        resultArray.arrayObject?.append(jsonData)
        resultData = changeJsonObject(useData: ["result": "FAIL", "value": resultArray])
    }
    
    return resultData
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

public func checkTransactionStatusAsync(network: String, txHash: String) async throws -> String {
    do {
        networkSettings(network: network)
        let url = try await URL(string: rpcUrl)
        let web3 = try await Web3.new(url!)
        let txReceipt = try await web3.eth.transactionReceipt(Data.fromHex(txHash)!)
        if(txReceipt.status == .ok) {
            return "Transaction Successful"
        } else if(txReceipt.status == .failed) {
            return "Transaction Failed"
        } else {
            return "Transaction not yet mined"
        }
    } catch let error {
        return "Transaction not yet mined"
    }
}
