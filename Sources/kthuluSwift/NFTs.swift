//
//  NFTs.swift
//  kthulu-ios-sdk
//
//  Created by Dev ABC on 2023/07/03.
//

import Foundation
import BigInt
import web3swift
import Web3Core
import SwiftyJSON

enum CustomError: Error {
    case invalidParameters
}
public func getMintableAddress(
    owner:  [String] ) async throws -> JSON {

    var CADAta: JSON = JSON()
        
    let own = "'\(owner.joined(separator: "','"))'"
        
    var CAQuery =
        "SELECT " +
            "network, " +
            "collection_id, " +
            "collection_name, " +
            "collection_symbol, " +
            "nft_type, " +
            "creator, " +
            "owner, " +
            "total_supply, " +
            "deployment_date, " +
            "slug, " +
            "category, " +
            "logo_url, " +
            "image_s3_url, " +
            "isverified, " +
            "numOwners, " +
            "currency, " +
            "discord_link, " +
            "twitter_link, " +
            "instagram_link, " +
            "facebook_link, " +
            "telegram_link, " +
            "external_url " +
        "FROM " +
            "nft_collection_table " +
        "WHERE " +
            "network IN ('ethereum','cypress','polygon','bnb') " +
            "AND " +
                "creator IN ('0x780A19638D126d59f4Ed048Ae1e0DC77DAf39a77','0x7E055Cb85FBE64da619865Df8a392d12f009aD81')" +
            "AND " +
                " owner IN (\(own))"
        
        print(CAQuery)
        let CAResult = sqlJsonArray(sqlQuery: CAQuery)
        
        do {
            var CAArray: [[String: Any]] = []
            
            for (_, subJson): (String, JSON) in CAResult {
                let network = subJson["network"].string
                let collection_id = subJson["collection_id"].string
                let collection_name = subJson["collection_name"].string
                let collection_symbol = subJson["collection_symbol"].string
                let nft_type = subJson["nft_type"].string
                let creator = subJson["creator"].string
                let owner = subJson["owner"].string
                let total_supply = subJson["total_supply"].string
                let deployment_date = subJson["deployment_date"].int ?? 0
                let slug = subJson["slug"].string
                let category = subJson["category"].string
                let logo_url = subJson["logo_url"].string
                let image_s3_url = subJson["image_s3_url"].string
                let isverified = subJson["isverified"].string
                let numOwners = subJson["numOwners"].int ?? 0
                let currency = subJson["currency"].string
                let discord_link = subJson["discord_link"].string
                let twitter_link = subJson["twitter_link"].string
                let instagram_link = subJson["instagram_link"].string
                let facebook_link = subJson["facebook_link"].string
                let telegram_link = subJson["telegram_link"].string
                let external_url = subJson["external_url"].string
                
                

                let objRes: [String: Any] = [
                    "network": network,
                    "collection_id": collection_id,
                    "collection_name": collection_name,
                    "collection_symbol": collection_symbol,
                    "nft_type": nft_type,
                    "creator": creator,
                    "owner": owner,
                    "total_supply": total_supply,
                    "deployment_date": deployment_date,
                    "slug": slug,
                    "category": category,
                    "logo_url": logo_url,
                    "image_s3_url": image_s3_url,
                    "isverified": isverified,
                    "numOwners": numOwners,
                    "currency": currency,
                    "discord_link": discord_link,
                    "twitter_link": twitter_link,
                    "instagram_link": instagram_link,
                    "facebook_link": facebook_link,
                    "telegram_link": telegram_link,
                    "external_url": external_url,
                ]
                CAArray.append(objRes)
            }
            
            CADAta["result"] = JSON("OK")
            CADAta["value"] = JSON(CAArray)
            return CADAta
        } catch _{
            let failJSON: JSON = ["result": JSON("FAIL"), "value": JSON([])]
            return failJSON
        }
        
}
//숨김처리
public func setNFTsHide(
    network: String,
    account: String,
    collection_id : String,
    token_id : String ) async throws -> JSON {
        
    var hideData: JSON = JSON()
    
        var insertQuery =
            "INSERT INTO " +
                "nft_hide_table (network, account, collection_id, token_id, image_url, nft_name) " +
            "SELECT " +
                "'\(network)', " +
                "'\(account)', " +
                "'\(collection_id)', " +
                "'\(token_id)', " +
                "token.image_url AS image_url, " +
                "token.nft_name AS nft_name " +
            "FROM " +
                "nft_token_table AS token " +
            "WHERE " +
                "token.network = '\(network)' " +
                "AND " +
                "token.collection_id = '\(collection_id)' " +
                "AND " +
                    "token.token_id = '\(token_id)'"

        do {
            // Assuming sqlJsonObject(sqlQuery:) is an asynchronous function.
            let hideResult = try await sqlJsonObject(sqlQuery: insertQuery)
            
            // Handle the result as needed.
            // For example, you could update the trashData JSON with the result.
//            trashData["result"] = JSON(trashResult)
            hideData["result"] = JSON("OK")
        } catch {
            // Handle any errors that might occur during the database operation.
            throw error
            hideData["result"] = JSON("FAIL")
        }
    return hideData
}

//숨김해제
public func deleteNFTsHide(
    network: String,
    account: String,
    collection_id: String,
    token_id: String ) async throws -> JSON {
   
    var hideData: JSON = JSON()
        
        var deleteQuery =
            "DELETE FROM " +
                "nft_hide_table " +
            "WHERE " +
                "network = '\(network)' " +
                "AND " +
                    "account = '\(account)' " +
                "AND " +
                    "collection_id = '\(collection_id)' " +
                "AND " +
                    "token_id = '\(token_id)' "
        do {
            let deleteResult = try await sqlJsonObject(sqlQuery: deleteQuery)
            
            hideData["result"] = JSON("OK")
        } catch {

            throw error
            hideData["result"] = JSON("FAIL")
        }
    return hideData
}
//숨김 조회
public func getNFTsHide(
    network: [String],
    account: [String],
    sort: String? = nil,
    limit: Int? = nil,
    page_number: Int? = nil ) async throws -> JSON {
        
        var hidden: JSON = JSON()
        let net = "'\(network.joined(separator: "','"))'"
        let acc = "'\(account.joined(separator: "','"))'"
        
        var offset: Int
        if let pageNumber = page_number, let limitValue = limit {
            offset = (pageNumber - 1) * limitValue
        } else {
            offset = 0 // 또는 적절한 기본값 설정
        }
        
        var hideQuery =
            "SELECT " +
                "hide.network AS network, " +
                "hide.account AS account, " +
                "hide.collection_id AS collection_id, " +
                "hide.token_id AS token_id, " +
                "hide.image_url AS image_url, " +
                "hide.nft_name AS nft_name " +
           "FROM " +
               "nft_hide_table AS hide " +
           "WHERE " +
                "hide.network IN (\(net)) " +
                "AND " +
                    "hide.account IN (\(acc))"
        hideQuery += " ORDER BY idx "
        if sort == "asc" {
            hideQuery += " ASC "
        } else {
            hideQuery += " DESC "
        }
        
        var sumQuery =
            "SELECT " +
                "count(*) AS sum " +
            "FROM " +
                "nft_hide_table " +
            "WHERE " +
                "network IN (\(net)) " +
                "AND " +
                    "account IN (\(acc))"
        
        print(hideQuery)
        print(sumQuery)
        
        let hideResult = sqlJsonArray(sqlQuery: hideQuery)
        let sumResult = sqlJsonArray(sqlQuery: sumQuery)
        
        do {
            
            var hideData: [[String: Any]] = []
            
            for (_, subJson): (String, JSON) in hideResult {
                let network = subJson["network"].string
                let account = subJson["account"].string
                let collection_id = subJson["collection_id"].string
                let token_id = subJson["token_id"].string
                let image_url = subJson["image_url"].string
                let nft_name = subJson["nft_name"].string
                
                let objRes: [String: Any] = [
                    "network": network,
                    "account": account,
                    "collection_id": collection_id,
                    "token_id": token_id,
                    "image": image_url,
                    "name":nft_name
                    
                ]
                hideData.append(objRes)
            }
            
            let page_count: Int?
            var sum: Int? = nil
            if let sumValue = sumResult.array?.first?["sum"].int {
                sum = sumValue
            }
            if let sumValue = sum, let limitValue = limit {
                page_count = Int(ceil(Double(sumValue) / Double(limitValue)))
            } else {
                page_count = 0
            }
            
            hidden["result"] = JSON("OK")
            if let sort = sort {
                hidden["sort"] = JSON(sort)
            } else {
                hidden["sort"] = JSON("desc")
            }
            hidden["page_count"] = JSON(page_count)
            if let sumValue = sumResult.array?.first?["sum"].int {
                hidden["sum"] = JSON(sumValue)
            } else {
                hidden["sum"] = JSON(0)
            }
            hidden["value"] = JSON(hideData)
            return hidden
        }catch _{
            let failJSON: JSON = ["result": JSON("FAIL"), "value": JSON([])]
            return failJSON
        }
        
        
}

//nft 조회 (String)
public func getNFTsByWallet(network: [String],
                            account: String? = nil,
                            collection_id: String? = nil,
                            sort: String? = nil,
                            limit: Int? = nil,
                            page_number: Int? = nil) async throws -> JSON {
    var nfts: JSON = JSON()
    let net = "'\(network.joined(separator: "','"))'"
    
    var offset: Int
    if let pageNumber = page_number, let limitValue = limit {
        offset = (pageNumber - 1) * limitValue
    } else {
        offset = 0 // 또는 적절한 기본값 설정
    }

    var strQuery =
        "SELECT" +
            " owner.network AS network," +
            " collection.collection_id AS collection_id," +
            " collection.collection_name AS collection_name," +
            " collection.collection_symbol AS collection_symbol," +
            " collection.creator AS creator," +
            " collection.deployment_date AS deployment_date," +
            " collection.total_supply AS total_supply," +
            " token.nft_type AS nft_type," +
            " token.minted_time AS minted_time," +
            " token.block_number AS block_number," +
            " owner.owner_account AS owner_account," +
            " token.token_id AS token_id," +
            " owner.balance AS balance," +
            " token.token_uri AS token_uri," +
            " token.nft_name AS nft_name," +
            " token.description AS description," +
            " token.image_url AS image_url," +
            " token.external_url AS external_url," +
            " token.attribute AS attribute," +
            " token.token_info AS token_info" +
        " FROM" +
            " nft_owner_table AS owner" +
        " JOIN" +
            " nft_token_table AS token" +
        " ON" +
            " owner.collection_id = token.collection_id" +
            " AND" +
                " owner.token_id = token.token_id" +
            " AND" +
                " owner.network = token.network" +
        " JOIN" +
            " nft_collection_table AS collection" +
        " ON" +
            " token.collection_id = collection.collection_id" +
            " AND" +
                " token.network = collection.network" +
        " WHERE" +
            " owner.network IN (\(net))" +
            " AND" +
                " owner.balance != '0'"
    if let accountValue = account {
        strQuery += " AND owner.owner_account = '\(accountValue)'"
    }
    if let collectionIdValue = collection_id {
        strQuery += " AND owner.collection_id = '\(collectionIdValue)'"
    }
    strQuery += " AND NOT EXISTS ( SELECT 1 FROM nft_hide_table AS hide WHERE hide.network = owner.network AND hide.account = owner.owner_account AND hide.token_id = owner.token_id AND hide.collection_id = owner.collection_id)"
    strQuery += " ORDER BY token.block_number"
    if sort == "asc" {
        strQuery += " ASC"
    } else {
        strQuery += " DESC"
    }
    strQuery += ", CAST(token.token_id AS SIGNED) DESC"
    if let limitValue = limit {
        strQuery += " LIMIT \(limitValue) OFFSET \(offset)"
    }
    print("String ==== \n", strQuery)

    var sumQuery =
            "SELECT" +
                " count(*) AS sum" +
            " FROM" +
                " nft_owner_table AS owner" +
            " JOIN" +
                " nft_token_table AS token" +
            " ON" +
                " owner.collection_id = token.collection_id" +
                " AND" +
                    " owner.token_id = token.token_id" +
                " AND" +
                    " owner.network = token.network" +
            " JOIN" +
                " nft_collection_table AS collection" +
            " ON" +
                " token.collection_id = collection.collection_id" +
                " AND" +
                    " token.network = collection.network" +
            " WHERE" +
                " owner.network IN (\(net))" +
                " AND" +
                " owner.balance != '0'"
    if let accountValue = account {
        sumQuery += " AND owner.owner_account = '\(accountValue)'"
    }
    if let collectionIdValue = collection_id {
        sumQuery += " AND owner.collection_id = '\(collectionIdValue)'"
    }
    sumQuery += " AND NOT EXISTS ( SELECT 1 FROM nft_hide_table AS hideWHERE hide.network = owner.network AND hide.account = owner.owner_account AND hide.token_id = owner.token_id AND hide.collection_id = owner.collection_id)"
    let nftResult = sqlJsonArray(sqlQuery: strQuery)
    let sumResult = sqlJsonArray(sqlQuery: sumQuery)
    
    do {
        if((account == nil && collection_id == nil) || (limit == nil && page_number != nil)){
            throw CustomError.invalidParameters
        }
        var updatedNFTs: [[String: Any]] = []
        
        for (_, subJson): (String, JSON) in nftResult {
            let network = subJson["network"].string
            let collection_id = subJson["collection_id"].string
            let collection_name = subJson["collection_name"].string
            let collection_symbol = subJson["collection_symbol"].string
            let collection_creator = subJson["creator"].string
            let collection_timestamp = subJson["deployment_date"].int ?? 0
            let collection_total_supply = subJson["total_supply"].string
            let nft_type = subJson["nft_type"].string
            let minted_timestamp = subJson["minted_time"].int ?? 0
            let block_number = subJson["block_number"].int ?? 0
            let owner = subJson["owner_account"].string
            let token_id = subJson["token_id"].string
            let token_balance = subJson["balance"].string
            let token_uri = subJson["token_uri"].string
            let name = subJson["nft_name"].string
            let description = subJson["description"].string
            let image = subJson["image_url"].string
            let external_url = subJson["external_url"].string
            let attributes = subJson["attribute"].string
            let metadata = subJson["token_info"].string
            

            let objRes: [String: Any] = [
                "network": network,
                "collection_id": collection_id,
                "collection_name": collection_name,
                "collection_symbol": collection_symbol,
                "collection_creator": collection_creator,
                "collection_timestamp": collection_timestamp,
                "collection_total_supply": collection_total_supply,
                "nft_type": nft_type,
                "minted_timestamp": minted_timestamp,
                "block_number": block_number,
                "owner": owner,
                "token_id":token_id,
                "token_balance": token_balance,
                "token_uri": token_uri,
                "name": name,
                "description": description,
                "image": image,
                "external_url": external_url,
                "attributes": attributes,
                "metadata": metadata
            ]
            updatedNFTs.append(objRes)
        }
        
        let page_count: Int?
        var sum: Int? = nil
        if let sumValue = sumResult.array?.first?["sum"].int {
            sum = sumValue
        }
        if let sumValue = sum, let limitValue = limit {
            page_count = Int(ceil(Double(sumValue) / Double(limitValue)))
        } else {
            page_count = 0
        }
        
        nfts["result"] = JSON("OK")
        if let sort = sort {
            nfts["sort"] = JSON(sort)
        } else {
            nfts["sort"] = JSON("desc") // 또는 적절한 기본값 설정
        }
        nfts["page_count"] = JSON(page_count)
        if let sumValue = sumResult.array?.first?["sum"].int {
            nfts["sum"] = JSON(sumValue)
        } else {
            nfts["sum"] = JSON(0)
        }
        nfts["value"] = JSON(updatedNFTs)
        return nfts
    } catch _{
        let failJSON: JSON = ["result": JSON("FAIL"), "value": JSON([])]
        return failJSON
    }
}


//nft 조회 (Array)
public func getNFTsByWalletArray(network: [String],
                            account: [String]? = nil,
                            collection_id: String? = nil,
                            sort: String? = nil,
                            limit: Int? = nil,
                            page_number: Int? = nil) async throws -> JSON {
    var nfts: JSON = JSON()
    let net = "'\(network.joined(separator: "','"))'"
    let acc = "'\(account?.joined(separator: "','") ?? "")'"
    
    var offset: Int
    if let pageNumber = page_number, let limitValue = limit {
        offset = (pageNumber - 1) * limitValue
    } else {
        offset = 0 // 또는 적절한 기본값 설정
    }

    var strQuery =
        "SELECT" +
            " owner.network AS network," +
            " collection.collection_id AS collection_id," +
            " collection.collection_name AS collection_name," +
            " collection.collection_symbol AS collection_symbol," +
            " collection.creator AS creator," +
            " collection.deployment_date AS deployment_date," +
            " collection.total_supply AS total_supply," +
            " token.nft_type AS nft_type," +
            " token.minted_time AS minted_time," +
            " token.block_number AS block_number," +
            " owner.owner_account AS owner_account," +
            " token.token_id AS token_id," +
            " owner.balance AS balance," +
            " token.token_uri AS token_uri," +
            " token.nft_name AS nft_name," +
            " token.description AS description," +
            " token.image_url AS image_url," +
            " token.external_url AS external_url," +
            " token.attribute AS attribute," +
            " token.token_info AS token_info" +
        " FROM" +
            " nft_owner_table AS owner" +
        " JOIN" +
            " nft_token_table AS token" +
        " ON" +
            " owner.collection_id = token.collection_id" +
            " AND" +
                " owner.token_id = token.token_id" +
            " AND" +
                " owner.network = token.network" +
        " JOIN" +
            " nft_collection_table AS collection" +
        " ON" +
            " token.collection_id = collection.collection_id" +
            " AND" +
                " token.network = collection.network" +
        " WHERE" +
            " owner.network IN (\(net))" +
            " AND" +
                " owner.balance != '0'"
    if (account != nil) {
        strQuery += " AND owner.owner_account IN (\(acc))"
    }
    if let collectionIdValue = collection_id {
        strQuery += " AND owner.collection_id = '\(collectionIdValue)'"
    }
    strQuery += " AND NOT EXISTS ( SELECT 1 FROM nft_hide_table AS hide WHERE hide.network = owner.network AND hide.account = owner.owner_account AND hide.token_id = owner.token_id AND hide.collection_id = owner.collection_id)"
    strQuery += " ORDER BY token.block_number"
    if sort == "asc" {
        strQuery += " ASC"
    } else {
        strQuery += " DESC"
    }
    strQuery += ", CAST(token.token_id AS SIGNED) DESC"
    if let limitValue = limit {
        strQuery += " LIMIT \(limitValue) OFFSET \(offset)"
    }
    print(strQuery)
    var sumQuery =
            "SELECT" +
                " count(*) AS sum" +
            " FROM" +
                " nft_owner_table AS owner" +
            " JOIN" +
                " nft_token_table AS token" +
            " ON" +
                " owner.collection_id = token.collection_id" +
                " AND" +
                    " owner.token_id = token.token_id" +
                " AND" +
                    " owner.network = token.network" +
            " JOIN" +
                " nft_collection_table AS collection" +
            " ON" +
                " token.collection_id = collection.collection_id" +
                " AND" +
                    " token.network = collection.network" +
            " WHERE" +
                " owner.network IN (\(net))" +
                " AND" +
                " owner.balance != '0'"
    if (account != nil) {
        sumQuery += " AND owner.owner_account IN (\(acc))"
    }
    if let collectionIdValue = collection_id {
        sumQuery += " AND owner.collection_id = '\(collectionIdValue)' "
    }
    sumQuery += " AND NOT EXISTS ( SELECT 1 FROM nft_hide_table AS hide WHERE hide.network = owner.network AND hide.account = owner.owner_account AND hide.token_id = owner.token_id AND hide.collection_id = owner.collection_id)"
    
    print(sumQuery)
    let nftResult = sqlJsonArray(sqlQuery: strQuery)
    let sumResult = sqlJsonArray(sqlQuery: sumQuery)
    
    do {
        if((account == nil && collection_id == nil) || (limit == nil && page_number != nil)){
            throw CustomError.invalidParameters
        }
        var updatedNFTs: [[String: Any]] = []
        
        for (_, subJson): (String, JSON) in nftResult {
            let network = subJson["network"].string
            let collection_id = subJson["collection_id"].string
            let collection_name = subJson["collection_name"].string
            let collection_symbol = subJson["collection_symbol"].string
            let collection_creator = subJson["creator"].string
            let collection_timestamp = subJson["deployment_date"].int ?? 0
            let collection_total_supply = subJson["total_supply"].string
            let nft_type = subJson["nft_type"].string
            let minted_timestamp = subJson["minted_time"].int ?? 0
            let block_number = subJson["block_number"].int ?? 0
            let owner = subJson["owner_account"].string
            let token_id = subJson["token_id"].string
            let token_balance = subJson["balance"].string
            let token_uri = subJson["token_uri"].string
            let name = subJson["nft_name"].string
            let description = subJson["description"].string
            let image = subJson["image_url"].string
            let external_url = subJson["external_url"].string
            let attributes = subJson["attribute"].string
            let metadata = subJson["token_info"].string
            

            let objRes: [String: Any] = [
                "network": network,
                "collection_id": collection_id,
                "collection_name": collection_name,
                "collection_symbol": collection_symbol,
                "collection_creator": collection_creator,
                "collection_timestamp": collection_timestamp,
                "collection_total_supply": collection_total_supply,
                "nft_type": nft_type,
                "minted_timestamp": minted_timestamp,
                "block_number": block_number,
                "owner": owner,
                "token_id":token_id,
                "token_balance": token_balance,
                "token_uri": token_uri,
                "name": name,
                "description": description,
                "image": image,
                "external_url": external_url,
                "attributes": attributes,
                "metadata": metadata
            ]
            updatedNFTs.append(objRes)
        }
        
        let page_count: Int?
        var sum: Int? = nil
        if let sumValue = sumResult.array?.first?["sum"].int {
            sum = sumValue
        }
        if let sumValue = sum, let limitValue = limit {
            page_count = Int(ceil(Double(sumValue) / Double(limitValue)))
        } else {
            page_count = 0
        }
        
        nfts["result"] = JSON("OK")
        if let sort = sort {
            nfts["sort"] = JSON(sort)
        } else {
            nfts["sort"] = JSON("desc") // 또는 적절한 기본값 설정
        }
        nfts["page_count"] = JSON(page_count)
        if let sumValue = sumResult.array?.first?["sum"].int {
            nfts["sum"] = JSON(sumValue)
        } else {
            nfts["sum"] = JSON(0)
        }
        nfts["value"] = JSON(updatedNFTs)
        return nfts
    } catch _{
        let failJSON: JSON = ["result": JSON("FAIL"), "value": JSON([])]
        return failJSON
    }
}


//거래내역 조회
public func getNFTsTransferHistory(network: String,
                                   collection_id: String? = nil,
                                   token_id:String? = nil,
                                   type:String? = nil,
                                   sort:String? = nil,
                                   limit:Int? = nil,
                                   page_number:Int? = nil) async throws -> JSON {
    var history: JSON = JSON()
    
    var offset: Int
    if let pageNumber = page_number, let limitValue = limit {
        offset = (pageNumber - 1) * limitValue
    } else {
        offset = 0 // 또는 적절한 기본값 설정
    }
    
    var transferQuery =
        " SELECT" +
            " transfer.network AS network," +
            " sales.buyer_account AS buyer_account," +
            " transfer.`from` AS from_address," +
            " transfer.`to` AS to_address," +
            " transfer.collection_id AS collection_id," +
            " transfer.block_number AS block_number," +
            " transfer.`timestamp` AS timestamp," +
            " transfer.transaction_hash AS transaction_hash," +
            " transfer.log_id AS log_id," +
            " transfer.token_id AS token_id," +
            " transfer.amount AS amount," +
            " sales.currency AS currency," +
            " sales.currency_symbol AS currency_symbol," +
            " sales.decimals AS decimals," +
            " sales.price AS price," +
            " sales.market AS market," +
            " sales.sales_info AS sales_info," +
        " CASE " +
            " WHEN " +
                " sales.sales_info IS NOT NULL THEN 'sales'" +
            " ELSE " +
                " 'transfer'" +
        " END AS " +
            " transaction_type" +
        " FROM " +
            " nft_transfer_table AS transfer" +
        " LEFT OUTER JOIN" +
            " nft_sales_table AS sales" +
        " ON " +
            " transfer.transaction_hash = sales.transaction_hash" +
        " LEFT JOIN" +
            " nft_transaction_type_table AS type" +
        " ON" +
            " transfer.transaction_hash = type.transaction_hash" +
        " WHERE " +
            " transfer.network = '\(network)'"
        if let token_id = token_id {
            transferQuery += " AND transfer.token_id = '\(token_id)' "
        }
        if let collection_id = collection_id {
            transferQuery += " AND transfer.collection_id = '\(collection_id)' "
        }
        if type == "transfer" {
            transferQuery += " AND type.transaction_type = 'transfer' ORDER BY transfer.block_number"
        } else if type == "sales" {
            transferQuery += " AND type.transaction_type = 'sales' ORDER BY transfer.block_number"
        } else {
            transferQuery += " ORDER BY transfer.block_number"
        }
        if sort == "asc" {
            transferQuery += " ASC"
        } else {
            transferQuery += " DESC"
        }
        transferQuery += ", CAST(transfer.token_id AS SIGNED) DESC"
        if let limit = limit {
            let offset = offset ?? 0
            transferQuery += " LIMIT \(limit) OFFSET \(offset)"
        }
    
    var sumQuery =
        "SELECT" +
            " count(*) AS sum" +
        " FROM" +
            " nft_transfer_table AS transfer" +
        " LEFT JOIN" +
            " nft_sales_table AS sales" +
        " ON" +
            " transfer.transaction_hash = sales.transaction_hash" +
        " LEFT JOIN" +
            " nft_transaction_type_table AS type" +
        " ON" +
            " transfer.transaction_hash = type.transaction_hash" +
        " WHERE" +
            " transfer.network = '\(network)'"
        if let tokenIdValue = token_id {
            sumQuery += " AND transfer.token_id = '\(tokenIdValue)' "
        }
        if let collectionIdValue = collection_id {
            sumQuery += " AND transfer.collection_id = '\(collectionIdValue)' "
        }
        if let typeValue = type {
            sumQuery += " AND type.transaction_type = '\(typeValue)'"
        }

    let sumResult = sqlJsonArray(sqlQuery: sumQuery)
    let transferResult = sqlJsonArray(sqlQuery: transferQuery)
    
    do {
        if((token_id == nil && collection_id == nil) || (limit == nil && page_number != nil)){
            throw CustomError.invalidParameters
        }
        
        var transferData: [[String: Any]] = []
        
        for (_, subJson): (String, JSON) in transferResult {
            let network = subJson["network"].string
            let buyer_account = subJson["buyer_account"].string
            let from_address = subJson["from_address"].string
            let to_address = subJson["to_address"].string
            let collection_id = subJson["collection_id"].string
            let block_number = subJson["block_number"].int ?? 0
            let timestamp = subJson["timestamp"].int ?? 0
            let transaction_hash = subJson["transaction_hash"].string
            let log_id = subJson["log_id"].string
            let token_id = subJson["token_id"].string
            let amount = subJson["amount"].string
            let currency = subJson["currency"].string
            let currency_symbol = subJson["currency_symbol"].string
            let decimals = subJson["decimals"].string
            let price = subJson["price"].string
            let market = subJson["market"].string
            let sales_info = subJson["sales_info"].string
            let transaction_type = subJson["transaction_type"].string
            
            let objRes: [String: Any] = [
                "network": network,
                "buyer": buyer_account,
                "from": from_address,
                "to": to_address,
                "collection_id": collection_id,
                "block_number": block_number,
                "timestamp": timestamp,
                "transaction_hash": transaction_hash,
                "log_id":log_id,
                "token_id":token_id,
                "amount": amount,
                "currency": currency,
                "currency_symbol": currency_symbol,
                "decimals": decimals,
                "price": price,
                "market": market,
                "sales_info": sales_info,
                "transaction_type": transaction_type
            ]
            transferData.append(objRes)
        }
        
        let page_count: Int?
        var sum: Int? = nil
        if let sumValue = sumResult.array?.first?["sum"].int {
            sum = sumValue
        }
        if let sumValue = sum, let limitValue = limit {
            page_count = Int(ceil(Double(sumValue) / Double(limitValue)))
        } else {
            page_count = 0
        }
        
        history["result"] = JSON("OK")
        if let sort = sort {
            history["sort"] = JSON(sort)
        } else {
            history["sort"] = JSON("desc")
        }
        history["page_count"] = JSON(page_count)
        if let sumValue = sumResult.array?.first?["sum"].int {
            history["sum"] = JSON(sumValue)
        } else {
            history["sum"] = JSON(0)
        }
        history["value"] = JSON(transferData)
        return history
    }catch _{
        let failJSON: JSON = ["result": JSON("FAIL"), "value": JSON([])]
        return failJSON
    }
}

public func sendNFT721TransactionAsync(network: String, fromAddress: String, toAddress: String, tokenId: String, nftContractAddress: String) async throws -> JSON {
    var result: JSON = JSON()
    do {
        let getAddressInfo = try await getAccountInfo(account: fromAddress)
        var privateKey = ""
        if(getAddressInfo["value"] != []){
            let value = getAddressInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }
        let from = EthereumAddress(fromAddress)
        let to = EthereumAddress(toAddress)
        let ca = EthereumAddress(nftContractAddress)!

        networkSettings(network: network)
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        
//        let rpcUrl = try URL(string: getRPCUrl(network: network))!
//        let chainID = try getChainID(network: network)
//        let web3 = try await Web3.new(rpcUrl)
        
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "transferERC721", tokenAddress: nftContractAddress, fromAddress: fromAddress, toAddress: toAddress, tokenId: tokenId)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(Web3.Utils.erc721ABI, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca, nonce:nonce, chainID:chainID, gasLimit: gasLimit!, gasPrice: gasPrice)
        } else {
            // tip 0.1gwei
            transaction = CodableTransaction(type:.eip1559, to:ca, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 35000000000)
        }
        transaction?.from = from
        let contractData = contract.contract.method("safeTransferFrom", parameters: [from, to, BigUInt(tokenId)], extraData: Data())
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

public func sendNFT1155TransactionAsync(network: String, fromAddress: String, toAddress: String, tokenId: String, nftContractAddress: String, amount: String) async throws -> JSON {
    var result: JSON = JSON()
    do {
        let getAddressInfo = try await getAccountInfo(account: fromAddress)
        var privateKey = ""
        if(getAddressInfo["value"] != []){
            let value = getAddressInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }
        let from = EthereumAddress(fromAddress)
        let to = EthereumAddress(toAddress)
        let ca = EthereumAddress(nftContractAddress)!

        networkSettings(network: network)
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        
//        let rpcUrl = try URL(string: getRPCUrl(network: network))!
//        let chainID = try getChainID(network: network)
//        let web3 = try await Web3.new(rpcUrl)
        
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "transferERC1155", tokenAddress: nftContractAddress, fromAddress: fromAddress, toAddress: toAddress, tokenAmount: amount, tokenId: tokenId)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(Web3.Utils.erc1155ABI, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, gasPrice: gasPrice)
        } else {
            transaction = CodableTransaction(type:.eip1559, to:ca, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 35000000000)
        }
        transaction?.from = from
        let contractData = contract.contract.method("safeTransferFrom", parameters: [from, to, BigUInt(tokenId), BigUInt(amount), [UInt8(0)]], extraData: Data())
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
public func sendErc721BatchAsync(network: String, fromAddress: String, toAddress: String, tokenId: [String], nftContractAddress: String) async throws -> JSON {
    var result: JSON = JSON()
    do{
        let accountInfo = try await getAccountInfo(account: fromAddress)
        var privateKey = ""
        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }
        let from = EthereumAddress(fromAddress)
        let to = EthereumAddress(toAddress)
        let ca = EthereumAddress(nftContractAddress)!

        networkSettings(network: network)
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "batchTransferERC721", tokenAddress: nftContractAddress, fromAddress: fromAddress, toAddress: toAddress, batchTokenId: tokenId)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(kthuluErc721, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, gasPrice: gasPrice)
        } else {
            transaction = CodableTransaction(type:.eip1559, to:ca, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 35000000000)
        }
        transaction?.from = from
        let contractData = contract.contract.method("safeBatchTransferFrom", parameters: [from, to, tokenId.compactMap{BigUInt($0)}], extraData: Data())
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
public func sendErc1155BatchAsync(network: String, fromAddress: String, toAddress: String, tokenId: [String], nftContractAddress: String, amount: [String]) async throws -> JSON {
    var result: JSON = JSON()
    do {
        let accountInfo = try await getAccountInfo(account: fromAddress)
        var privateKey = ""
        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }
        let from = EthereumAddress(fromAddress)
        let to = EthereumAddress(toAddress)
        let ca = EthereumAddress(nftContractAddress)!

        networkSettings(network: network)
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        
//        let rpcUrl = try URL(string: getRPCUrl(network: network))!
//        let chainID = try getChainID(network: network)
//        let web3 = try await Web3.new(rpcUrl)
        
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "batchTransferERC1155", tokenAddress: nftContractAddress, fromAddress: fromAddress, toAddress: toAddress, batchTokenId: tokenId, batchTokenAmount: amount)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(kthuluErc1155, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, gasPrice: gasPrice)
        } else {
            transaction = CodableTransaction(type:.eip1559, to:ca, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 35000000000)
        }
        transaction?.from = from
        let contractData = contract.contract.method("safeBatchTransferFrom", parameters: [from, to, tokenId.compactMap{BigUInt($0)}, amount.compactMap{BigUInt($0)}, [UInt8(0)]], extraData: Data())
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

public func deployErc721Async(network: String, fromAddress: String, name: String, symbol: String, baseURI: String, uriType: String, owner: String) async throws -> JSON {
    var result: JSON = JSON()
    do {
        let accountInfo = try await getAccountInfo(account: fromAddress)
        var privateKey = ""
        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }
        networkSettings(network: network)
        let ownerEA = EthereumAddress(owner)
        let from = EthereumAddress(fromAddress)
        let ca = EthereumAddress(erc721DeployContractAddress)
        
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        
//        let rpcUrl = try URL(string: getRPCUrl(network: network))!
//        let chainID = try getChainID(network: network)
//        let web3 = try await Web3.new(rpcUrl)
        
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "deployERC721", fromAddress: fromAddress, name: name, symbol: symbol, baseURI: baseURI, owner: owner, uriType:  uriType)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(deployERC721, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca!, nonce:nonce, chainID:chainID, gasLimit: gasLimit!, gasPrice: gasPrice)
        } else {
            // tip 1gwei
            transaction = CodableTransaction(type:.eip1559, to:ca!, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 35000000000)
        }
        transaction?.from = from
        let contractData = contract.contract.method("deployedERC721", parameters: [name,symbol,baseURI,UInt8(uriType),ownerEA], extraData: Data())
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

public func deployErc1155Async(network: String, fromAddress: String, name: String, symbol: String, baseURI: String, owner: String, uriType: String) async throws -> JSON {
    var result: JSON = JSON()
    do {
        let accountInfo = try await getAccountInfo(account: fromAddress)
        var privateKey = ""
        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }
        networkSettings(network: network)
        let ownerEA = EthereumAddress(owner)
        let from = EthereumAddress(fromAddress)
        let ca = EthereumAddress(erc1155DeployContractAddress)
        
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        
//        let rpcUrl = try URL(string: getRPCUrl(network: network))!
//        let chainID = try getChainID(network: network)
//        let web3 = try await Web3.new(rpcUrl)
        
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "deployERC1155", fromAddress: fromAddress, name: name, symbol: symbol, baseURI: baseURI, owner: owner, uriType:  uriType)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(deployERC1155, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca!, nonce:nonce, chainID:chainID, gasLimit: gasLimit!, gasPrice: gasPrice)
        } else {
            // tip 1gwei
            transaction = CodableTransaction(type:.eip1559, to:ca!, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 35000000000)
        }
        transaction?.from = from
        let contractData = contract.contract.method("deployedERC1155", parameters: [name,symbol,baseURI,UInt8(uriType),ownerEA], extraData: Data())
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

public func mintErc721Async(network: String, fromAddress: String, toAddress: String, tokenURI: String, tokenId: String, nftContractAddress: String) async throws -> JSON {
    var result: JSON = JSON()
    do {
        let accountInfo = try await getAccountInfo(account: fromAddress)
        var privateKey = ""
        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }

        let from = EthereumAddress(fromAddress)
        let to = EthereumAddress(toAddress)
        let ca = EthereumAddress(nftContractAddress)
        
        networkSettings(network: network)
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        
//        let rpcUrl = try URL(string: getRPCUrl(network: network))!
//        let chainID = try getChainID(network: network)
//        let web3 = try await Web3.new(rpcUrl)
        
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "mintERC721", tokenAddress: nftContractAddress, fromAddress: fromAddress, toAddress: toAddress, tokenId: tokenId, tokenURI: tokenURI)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(kthuluErc721, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca!, nonce:nonce, chainID:chainID, gasLimit: gasLimit!, gasPrice: gasPrice)
        } else {
            // tip 1gwei
            transaction = CodableTransaction(type:.eip1559, to:ca!, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 35000000000)
        }
        transaction?.from = from
        let contractData = contract.contract.method("mint", parameters: [to,BigUInt(tokenId),tokenURI], extraData: Data())
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

public func mintErc1155Async(network: String, fromAddress: String, toAddress: String, tokenURI: String, tokenId: String, nftContractAddress: String, amount: String) async throws -> JSON {
    var result: JSON = JSON()
    do {
        let accountInfo = try await getAccountInfo(account: fromAddress)
        var privateKey = ""
        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }

        let from = EthereumAddress(fromAddress)
        let to = EthereumAddress(toAddress)
        let ca = EthereumAddress(nftContractAddress)
        
        networkSettings(network: network)
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        
//        let rpcUrl = try URL(string: getRPCUrl(network: network))!
//        let chainID = try getChainID(network: network)
//        let web3 = try await Web3.new(rpcUrl)
        
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "mintERC1155", tokenAddress: nftContractAddress, fromAddress: fromAddress, toAddress: toAddress, tokenAmount: amount, tokenId: tokenId, tokenURI: tokenURI)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(kthuluErc1155, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca!, nonce:nonce, chainID:chainID, gasLimit: gasLimit!, gasPrice: gasPrice)
        } else {
            // tip 1gwei
            transaction = CodableTransaction(type:.eip1559, to:ca!, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 35000000000)
        }
        transaction?.from = from
        let contractData = contract.contract.method("mint", parameters: [to,BigUInt(tokenId),BigUInt(amount),tokenURI,[UInt8(0)]], extraData: Data())
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

public func batchMintErc721Async(network: String, fromAddress: String, toAddress: String, tokenId: [String], tokenURI: [String], nftContractAddress: String) async throws -> JSON {
    var result: JSON = JSON()
    do{
        let accountInfo = try await getAccountInfo(account: fromAddress)
        var privateKey = ""
        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }
        let from = EthereumAddress(fromAddress)
        let to = EthereumAddress(toAddress)
        let ca = EthereumAddress(nftContractAddress)!

        networkSettings(network: network)
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "batchMintERC721", tokenAddress: nftContractAddress, fromAddress: fromAddress, toAddress: toAddress, batchTokenId: tokenId, batchTokenURI: tokenURI)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(kthuluErc721, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, gasPrice: gasPrice)
        } else {
            transaction = CodableTransaction(type:.eip1559, to:ca, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 35000000000)
        }
        transaction?.from = from
        let contractData = contract.contract.method("mintBatch", parameters: [to, tokenId.compactMap{BigUInt($0)}, tokenURI], extraData: Data())
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

public func batchMintErc1155Async(network: String, fromAddress: String, toAddress: String, tokenId: [String], tokenURI: [String], nftContractAddress: String, amount: [String]) async throws -> JSON {
    var result: JSON = JSON()
    do{
        let accountInfo = try await getAccountInfo(account: fromAddress)
        var privateKey = ""
        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }
        let from = EthereumAddress(fromAddress)
        let to = EthereumAddress(toAddress)
        let ca = EthereumAddress(nftContractAddress)!

        networkSettings(network: network)
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "batchMintERC1155", tokenAddress: nftContractAddress, fromAddress: fromAddress, toAddress: toAddress, batchTokenId: tokenId, batchTokenAmount: amount, batchTokenURI: tokenURI)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(kthuluErc1155, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, gasPrice: gasPrice)
        } else {
            transaction = CodableTransaction(type:.eip1559, to:ca, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 35000000000)
        }
        transaction?.from = from
        let contractData = contract.contract.method("mintBatch", parameters: [to, tokenId.compactMap{BigUInt($0)}, amount.compactMap{BigUInt($0)}, tokenURI, [UInt8(0)]], extraData: Data())
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

public func burnErc721Async(network: String, fromAddress: String, tokenId: String, nftContractAddress: String) async throws -> JSON {
    var result: JSON = JSON()
    do {
        let accountInfo = try await getAccountInfo(account: fromAddress)
        var privateKey = ""
        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }

        let from = EthereumAddress(fromAddress)
        let ca = EthereumAddress(nftContractAddress)
        
        networkSettings(network: network)
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "burnERC721", tokenAddress: nftContractAddress, fromAddress: fromAddress, tokenId: tokenId)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(kthuluErc721, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca!, nonce:nonce, chainID:chainID, gasLimit: gasLimit!, gasPrice: gasPrice)
        } else {
            // tip 1gwei
            transaction = CodableTransaction(type:.eip1559, to:ca!, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 35000000000)
        }
        transaction?.from = from
        let contractData = contract.contract.method("burn", parameters: [BigUInt(tokenId)], extraData: Data())
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

public func burnErc1155Async(network: String, fromAddress: String, tokenId: String, nftContractAddress: String, amount: String) async throws -> JSON {
    var result: JSON = JSON()
    do {
        let accountInfo = try await getAccountInfo(account: fromAddress)
        var privateKey = ""
        if(accountInfo["value"] != []){
            let value = accountInfo["value"]
            if value[0]["private"].string != nil {
                privateKey = value[0]["private"].string!
            }
        }

        let from = EthereumAddress(fromAddress)
        let ca = EthereumAddress(nftContractAddress)
        
        networkSettings(network: network)
        var url = try await URL(string:rpcUrl)
        let web3 = try await Web3.new(url!)
        
        let nonce = try await web3.eth.getTransactionCount(for: from!, onBlock: .pending)
        let gasPrice = try await getEstimateGasAsync(network: network, txType: "baseFee")
        let gasLimit = try await getEstimateGasAsync(network: network, txType: "burnERC1155", tokenAddress: nftContractAddress, fromAddress: fromAddress, tokenAmount: amount, tokenId: tokenId)
        let data = "0x".data(using: .utf8)!
        let contract = web3.contract(kthuluErc1155, at: ca, abiVersion: 2)!
        var transaction: CodableTransaction? = nil
        if(network == "bnb" || network == "bnbTest") {
            transaction = CodableTransaction(to:ca!, nonce:nonce, chainID:chainID, gasLimit: gasLimit!, gasPrice: gasPrice)
        } else {
            // tip 1gwei
            transaction = CodableTransaction(type:.eip1559, to:ca!, nonce:nonce, chainID:chainID, gasLimit:gasLimit!, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 35000000000)
        }
        transaction?.from = from
        let contractData = contract.contract.method("burn", parameters: [from,BigUInt(tokenId),BigUInt(amount)], extraData: Data())
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


public func verifyNFT(network: String, tokenId: String, contractAddress: String, apiKey: String) async throws -> JSON {
    var result: JSON = [
        "ContractVerify": false,
        "TokenURIAvailable": false,
        "TokenURIResponseOnTime": false,
        "TokenURIDecentralized": false,
        "MetadataStandard": false,
        "MetadataImageAvailable": false,
        "TokenURIisHTTPS": false,
        "ImageURIisHTTPS": false
    ]
    var nftType: String? = nil
    var tokenURI: String? = nil
    var tokenInfo: String? = nil
    var imageURL: String? = nil
    do {
        var query =
            "SELECT nft_type FROM " +
                "nft_token_table " +
            "WHERE " +
        "network = '\(network)' " +
        "AND " +
            "collection_id = '\(contractAddress)' "
        "AND " +
            "token_id = '\(tokenId)' "
        do {
            let res = try await sqlJsonObject(sqlQuery: query)
            nftType = res["nft_type"].string
            tokenURI = res["token_uri"].string
            tokenInfo = res["token_info"].string
            imageURL = res["image_url"].string
        } catch {
            throw error
        }

        // step1. NFT 컨트랙트 검증
        //        let hostUrl = "https://api.etherscan.io/api?module=contract&action=getabi&address=\(contractAddress)&apikey=\(apiKey)"
        let hostUrl = "https://api.polygonscan.com/api?module=contract&action=getabi&address=\(contractAddress)&apikey=\(apiKey)"


        do {
            guard let url = URL(string: hostUrl) else {
                print("Invalid URL")
                return false
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let responseJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let apiResult = responseJSON["result"] as? String else {
                print("Invalid API response")
                return false
            }
            
            // Parse the ABI if it exists
            let contractABI = (apiResult != "Contract source code not verified") ? try JSONSerialization.jsonObject(with: Data(apiResult.utf8)) as? [[String: Any]] : []
            
            if contractABI!.isEmpty {
                result["ContractVerify"] = false
                result["ContractStandard"] = false
            } else {
                result["ContractVerify"] = true
            }
            
            let bytecodeFunctions = contractABI?.filter { $0["type"] as? String == "function" } ?? []
        //            print(bytecodeFunctions)
            if(nftType == "erc721") {
                let balanceOf = bytecodeFunctions.contains { ($0["name"] as? String) == "balanceOf" }
                let ownerOf = bytecodeFunctions.contains { ($0["name"] as? String) == "ownerOf" }
                let transferFrom = bytecodeFunctions.contains { ($0["name"] as? String) == "transferFrom" }
                let approve = bytecodeFunctions.contains { ($0["name"] as? String) == "approve" }
                let setApprovalForAll = bytecodeFunctions.contains { ($0["name"] as? String) == "setApprovalForAll" }
                let getApproved = bytecodeFunctions.contains { ($0["name"] as? String) == "getApproved" }
                let isApprovedForAll = bytecodeFunctions.contains { ($0["name"] as? String) == "isApprovedForAll" }
                
                var safeTransferFromWith_data = false
                var safeTransferFromWithout_data = false
                
                for jsonObject in bytecodeFunctions {
                    if let name = jsonObject["name"] as? String,
                       name == "safeTransferFrom",
                       let inputs = jsonObject["inputs"] as? [[String: String]],
                       inputs.contains(where: { $0["name"] == "_data" }) {
                        safeTransferFromWith_data = true
                    }
                    if let name = jsonObject["name"] as? String,
                       name == "safeTransferFrom" {
                        safeTransferFromWithout_data = true
                    }
                }
                
                let contractStandard: JSON = [
                    "balanceof": balanceOf,
                    "ownerOf": ownerOf,
                    "transferFrom": transferFrom,
                    "approve": approve,
                    "setApprovalForAll": setApprovalForAll,
                    "getApproved": getApproved,
                    "isApprovedForAll": isApprovedForAll,
                    "safeTransferFromWith_data": safeTransferFromWith_data,
                    "safeTransferFromWithout_data": safeTransferFromWithout_data
                ]
                result["ContractStandard"] = contractStandard
            } else if(nftType == "erc1155") {
                let balanceOf = bytecodeFunctions.contains { ($0["name"] as? String) == "balanceOf" }
                let balanceOfBatch = bytecodeFunctions.contains { ($0["name"] as? String) == "balanceOfBatch" }
                let setApprovalForAll = bytecodeFunctions.contains { ($0["name"] as? String) == "setApprovalForAll" }
                let isApprovedForAll = bytecodeFunctions.contains { ($0["name"] as? String) == "isApprovedForAll" }
                let safeTransferFrom = bytecodeFunctions.contains { ($0["name"] as? String) == "safeTransferFrom" }
                let safeBatchTransferFrom = bytecodeFunctions.contains { ($0["name"] as? String) == "safeBatchTransferFrom" }
                
                let contractStandard: JSON = [
                    "balanceof": balanceOf,
                    "balanceOfBatch": balanceOfBatch,
                    "setApprovalForAll": setApprovalForAll,
                    "isApprovedForAll": isApprovedForAll,
                    "safeTransferFrom": safeTransferFrom,
                    "safeBatchTransferFrom": safeBatchTransferFrom
                ]
                result["ContractStandard"] = contractStandard
            }
            
            let ca = EthereumAddress(contractAddress)
            networkSettings(network: network)
            var rpc = try await URL(string:rpcUrl)
            let web3 = try await Web3.new(rpc!)
            let contract = web3.contract(kthuluErc721, at: ca, abiVersion: 2)!
            var parameter = ""
            if(nftType == "erc721") {
                parameter = "0x80ac58cd"
            } else if(nftType == "erc1155") {
                parameter = "0xd9b67a26"
            }
            let readOp = contract.createReadOperation("supportsInterface", parameters: [parameter])!
            let response = try await readOp.callContractMethod()
            if let value = response["0"] {
                result["supportsInterface"] = JSON(value)
            }
            
            
            // step2. tokenURI검증
            if tokenURI == nil || tokenURI?.isEmpty == true {
            } else {
                if tokenURI!.prefix(12) == "ipfs://ipfs/" {
                    tokenURI = "https://ipfs.io/ipfs/\(tokenURI!.suffix(from: tokenURI!.index(tokenURI!.startIndex, offsetBy: 12)))"
                } else if tokenURI!.prefix(7) == "ipfs://" {
                    tokenURI = "https://ipfs.io/ipfs/\(tokenURI!.suffix(from: tokenURI!.index(tokenURI!.startIndex, offsetBy: 7)))"
                } else if tokenURI!.prefix(5) == "ar://" {
                    tokenURI = "https://arweave.net/\(tokenURI!.suffix(from: tokenURI!.index(tokenURI!.startIndex, offsetBy: 5)))"
                }
            
                if tokenURI!.contains("ipfs") || tokenURI!.contains("arweave") {
                    result["TokenURIDecentralized"] = true
                } else {
                }
                
                let token_url = URL(string: tokenURI!)!
                
                let startTime = Date()
                
                let semaphore = DispatchSemaphore(value: 0)
                
                let task = URLSession.shared.dataTask(with: token_url) { (data, response, error) in
                    defer {
                        semaphore.signal()
                    }
                    
                    let endTime = Date()
                    
                    if let error = error {
                        print("Error: \(error)")
                        
                    } else {
                        if let response = response as? HTTPURLResponse {
        //                                                    print("Status Code: \(response.statusCode)")
                            if response.statusCode == 200 {
                                result["TokenURIAvailable"] = true
                            } else {
                                return
                            }
                        } else {
                            return
                        }
                        
                        let elapsedTime = endTime.timeIntervalSince(startTime)
        //                        print("Elapsed Time: \(elapsedTime) seconds")
                        if elapsedTime < 1 {
                            result["TokenURIResponseOnTime"] = true
                        }
                        
                        if let data = data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: [])
                                //                            print("Response JSON: \(json)")
                                
                            } catch {
                                print("JSON Parsing Error: \(error)")
                            }
                        }
                    }
                }
                
                task.resume()
                _ = semaphore.wait(timeout: .now() + 5)
                
                // Protocol 체크
                if tokenURI!.hasPrefix("https://"){
                    result["TokenURIisHTTPS"] = true
                } else {
                }
            }
            
            // step3. Metadata검증
            if tokenInfo == nil || tokenInfo?.isEmpty == true {
            } else {
                if let jsonData = tokenInfo!.data(using: .utf8) {
                    do {
                        let json = try JSON(data: jsonData)
                        
                        var trueCount = 0
                        
                        if json["name"].exists() {
                            trueCount += 1
                        }
                        
                        if json["image"].exists() {
                            trueCount += 1
                            if imageURL!.prefix(12) == "ipfs://ipfs/" {
                                imageURL = "https://ipfs.io/ipfs/\(imageURL!.suffix(from: imageURL!.index(imageURL!.startIndex, offsetBy: 12)))"
                            } else if imageURL!.prefix(7) == "ipfs://" {
                                imageURL = "https://ipfs.io/ipfs/\(imageURL!.suffix(from: imageURL!.index(imageURL!.startIndex, offsetBy: 7)))"
                            } else if imageURL!.prefix(5) == "ar://" {
                                imageURL = "https://arweave.net/\(imageURL!.suffix(from: imageURL!.index(imageURL!.startIndex, offsetBy: 5)))"
                            }
        //                            print(imageURL)
                            let image_url = URL(string: imageURL!)
                            let semaphore2 = DispatchSemaphore(value: 0)
                            
                            let task = URLSession.shared.dataTask(with: image_url!) { (data, response, error) in
                                defer {
                                    semaphore2.signal()
                                }
                                if let response = response as? HTTPURLResponse {
        //                                                            print("Status Code: \(response.statusCode)")
                                    if response.statusCode == 200 {
                                        result["MetadataImageAvailable"] = true
                                    }
                                }
                            }
                            task.resume()
                            _ = semaphore2.wait(timeout: .now() + 5)
                            // Protocol 체크
                            if imageURL!.hasPrefix("https://"){
                                result["ImageURIisHTTPS"] = true
                            } else {
                            }
                        }
                        
                        if json["description"].exists() {
                            trueCount += 1
                        }
                        
                        if json["attributes"].exists() {
                            trueCount += 1
                        }
                        
        //                        print("Number of keys found: \(trueCount)")
                        if(trueCount == 4) {
                            result["MetadataStandard"] = true
                        }
                        
                    } catch {
                        print("JSON parsing error: \(error)")
                    }
                }
            }
            
            return result
        } catch {
            print("Error: \(error)")
            return result
        }
    }
}
