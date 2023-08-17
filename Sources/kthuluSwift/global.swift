//
//  global.swift
//  ios-SDK-test
//
//  Created by Dev ABC on 2023/06/27.
//

import Foundation
import Security
import CryptoKit
import SwiftyJSON
import KeychainAccess
import Foundation
import BigInt
import web3swift
import Web3Core
import SwiftyJSON

//public var addrTransferGoerli = "0x25df7c4d54ce69faf37352cbe98e2d3f9281eaf7"
//public var addrBridgeGoerli = "0x25df7c4d54ce69faf37352cbe98e2d3f9281eaf7"
//public var erc20DeployGoerli = "0xc11735Ce3c155E755bC9839A5B5d06dEa0482306"
//public var erc20DeployMumbai = "0x95f34cD3FE7ca6273f7EaFcA35E65A36aa8894cC"
//public var erc20DeployPolygon = "0x96856126a6bb4870cDD3e179004CD18cEf569044"

var dbServer: String? = nil
var dbUser: String? = nil
var dbPasswd: String? = nil
var dbName: String? = nil

public func dbSetting(server: String, user: String, passwd: String, name: String){
    dbServer = server
    dbUser = user
    dbPasswd = passwd
    dbName = name
}


var rpcUrl = "";
var chainID = BigUInt(0);
var erc20DeployContractAddress = "";
var erc721DeployContractAddress = "";
var erc1155DeployContractAddress = "";

public func networkSettings(network: String) {
    switch (network) {
        case "ethereum":
            rpcUrl = "https://eth.meowrpc.com"
            chainID = BigUInt(1)
        case "cypress":
            rpcUrl = "https://rpc.ankr.com/klaytn"
            chainID = BigUInt(8217)
        case "polygon":
            rpcUrl = "https://polygon-rpc.com"
            chainID = BigUInt(137)
            erc20DeployContractAddress = "0x96856126a6bb4870cDD3e179004CD18cEf569044"
            erc721DeployContractAddress = "0x780A19638D126d59f4Ed048Ae1e0DC77DAf39a77"
            erc1155DeployContractAddress = "0x7E055Cb85FBE64da619865Df8a392d12f009aD81"
        case "bnb":
            rpcUrl = "https://bsc-dataseed.binance.org"
            chainID = BigUInt(56)
        case "goerli":
            rpcUrl = "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161"
            chainID = BigUInt(5)
            erc20DeployContractAddress = "0xc11735Ce3c155E755bC9839A5B5d06dEa0482306"
            erc721DeployContractAddress = "0x4F6b53a83c71EF127FE6e3f76f666A064116E201"
            erc1155DeployContractAddress = "0xFEA394a312369b7772513cF856ce4424C1756F2C"
        case "baobab":
            erc20DeployContractAddress = "0x808ee7147d91eae0f658164248402ac380eb5f17"
            erc721DeployContractAddress = "0x780A19638D126d59f4Ed048Ae1e0DC77DAf39a77"
            erc1155DeployContractAddress = "0x96856126a6bb4870cdd3e179004cd18cef569044"
        case "mumbai":
            rpcUrl = "https://polygon-mumbai.infura.io/v3/4458cf4d1689497b9a38b1d6bbf05e78"
            chainID = BigUInt(80001)
            erc20DeployContractAddress = "0x95f34cD3FE7ca6273f7EaFcA35E65A36aa8894cC"
            erc721DeployContractAddress = "0xE00838B7948833cf14935489bAF52F2d8d0c2d23"
            erc1155DeployContractAddress = "0x57040e8b36AD23BB766572cED73A1daC6596d375"
        case "bnbTest":
            rpcUrl = "https://data-seed-prebsc-1-s1.binance.org:8545/"
            chainID = BigUInt(97)
        case "tbnb":
            erc20DeployContractAddress = "0x808EE7147d91EAe0f658164248402ac380EB5F17"
            erc721DeployContractAddress = "0xB668Bd1358442ba36eb9f2E00B2E79b2c6F1bD98"
            erc1155DeployContractAddress = "0x23205635BcFAEeb236360D35731d708415246DAC"
        default:
            print("Invalid main network type")
//            throw illegalArgumentException("Invalid main network type")
        }
    
}


public var erc20MumbaiAbi = "[{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"addrToken\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"string\",\"name\":\"tokenType\",\"type\":\"string\"}],\"name\":\"Deployed\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"name\":\"balanceReceived\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"name\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"symbol\",\"type\":\"string\"},{\"internalType\":\"uint256\",\"name\":\"totalSupply\",\"type\":\"uint256\"},{\"internalType\":\"address\",\"name\":\"owner_\",\"type\":\"address\"}],\"name\":\"deployedERC20\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"addrToken\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getBalance\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"receiveMoney\",\"outputs\":[],\"stateMutability\":\"payable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"addresspayable\",\"name\":\"_to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"_amount\",\"type\":\"uint256\"}],\"name\":\"withdrawMoney\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"stateMutability\":\"payable\",\"type\":\"receive\"}]"

public var kthuluErc20 = "[{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"addrToken\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"string\",\"name\":\"tokenType\",\"type\":\"string\"}],\"name\":\"Deployed\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"name\":\"balanceReceived\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"name\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"symbol\",\"type\":\"string\"},{\"internalType\":\"uint256\",\"name\":\"totalSupply\",\"type\":\"uint256\"},{\"internalType\":\"address\",\"name\":\"owner_\",\"type\":\"address\"}],\"name\":\"deployedERC20\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"addrToken\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getBalance\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"receiveMoney\",\"outputs\":[],\"stateMutability\":\"payable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"addresspayable\",\"name\":\"_to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"_amount\",\"type\":\"uint256\"}],\"name\":\"withdrawMoney\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"stateMutability\":\"payable\",\"type\":\"receive\"}]"
public var kthuluErc721 = "[{\"inputs\":[{\"internalType\":\"string\",\"name\":\"name_\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"symbol_\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"tokenBaseURI_\",\"type\":\"string\"},{\"internalType\":\"uint8\",\"name\":\"uriType_\",\"type\":\"uint8\"},{\"internalType\":\"address\",\"name\":\"owner_\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"approved\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"operator\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"bool\",\"name\":\"approved\",\"type\":\"bool\"}],\"name\":\"ApprovalForAll\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"previousOwner\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"newOwner\",\"type\":\"address\"}],\"name\":\"OwnershipTransferred\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"Paused\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"previousAdminRole\",\"type\":\"bytes32\"},{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"newAdminRole\",\"type\":\"bytes32\"}],\"name\":\"RoleAdminChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"sender\",\"type\":\"address\"}],\"name\":\"RoleGranted\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"sender\",\"type\":\"address\"}],\"name\":\"RoleRevoked\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"Unpaused\",\"type\":\"event\"},{\"inputs\":[],\"name\":\"DEFAULT_ADMIN_ROLE\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"LOCK_ROLE\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"MINTER_ROLE\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"PAUSER_ROLE\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"burn\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"getApproved\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"}],\"name\":\"getRoleAdmin\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"internalType\":\"uint256\",\"name\":\"index\",\"type\":\"uint256\"}],\"name\":\"getRoleMember\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"}],\"name\":\"getRoleMemberCount\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getTokenBaseURI\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getUriType\",\"outputs\":[{\"internalType\":\"uint8\",\"name\":\"\",\"type\":\"uint8\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"grantRole\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"hasRole\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"operator\",\"type\":\"address\"}],\"name\":\"isApprovedForAll\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"lock\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"}],\"name\":\"mint\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"},{\"internalType\":\"string\",\"name\":\"tokenUri\",\"type\":\"string\"}],\"name\":\"mint\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256[]\",\"name\":\"tokenIds\",\"type\":\"uint256[]\"},{\"internalType\":\"string[]\",\"name\":\"tokenUris\",\"type\":\"string[]\"}],\"name\":\"mintBatch\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"ownerOf\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"pause\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"paused\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"renounceOwnership\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"renounceRole\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"revokeRole\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256[]\",\"name\":\"tokenId\",\"type\":\"uint256[]\"}],\"name\":\"safeBatchTransferFrom\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"safeTransferFrom\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"},{\"internalType\":\"bytes\",\"name\":\"data\",\"type\":\"bytes\"}],\"name\":\"safeTransferFrom\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"operator\",\"type\":\"address\"},{\"internalType\":\"bool\",\"name\":\"approved\",\"type\":\"bool\"}],\"name\":\"setApprovalForAll\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"tokenBaseURI_\",\"type\":\"string\"}],\"name\":\"setTokenBaseURI\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint8\",\"name\":\"uriType_\",\"type\":\"uint8\"}],\"name\":\"setUriType\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes4\",\"name\":\"interfaceId\",\"type\":\"bytes4\"}],\"name\":\"supportsInterface\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"index\",\"type\":\"uint256\"}],\"name\":\"tokenByIndex\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"index\",\"type\":\"uint256\"}],\"name\":\"tokenOfOwnerByIndex\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"tokenURI\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"newOwner\",\"type\":\"address\"}],\"name\":\"transferOwnership\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"unLock\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"unpause\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"

public var kthuluErc1155 = "[{\"inputs\":[{\"internalType\":\"string\",\"name\":\"name_\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"symbol_\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"tokenBaseURI_\",\"type\":\"string\"},{\"internalType\":\"uint8\",\"name\":\"uriType_\",\"type\":\"uint8\"},{\"internalType\":\"address\",\"name\":\"owner_\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"operator\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"bool\",\"name\":\"approved\",\"type\":\"bool\"}],\"name\":\"ApprovalForAll\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"previousOwner\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"newOwner\",\"type\":\"address\"}],\"name\":\"OwnershipTransferred\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"Paused\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"previousAdminRole\",\"type\":\"bytes32\"},{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"newAdminRole\",\"type\":\"bytes32\"}],\"name\":\"RoleAdminChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"sender\",\"type\":\"address\"}],\"name\":\"RoleGranted\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"sender\",\"type\":\"address\"}],\"name\":\"RoleRevoked\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"operator\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256[]\",\"name\":\"ids\",\"type\":\"uint256[]\"},{\"indexed\":false,\"internalType\":\"uint256[]\",\"name\":\"values\",\"type\":\"uint256[]\"}],\"name\":\"TransferBatch\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"operator\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"TransferSingle\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"string\",\"name\":\"value\",\"type\":\"string\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"}],\"name\":\"URI\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"Unpaused\",\"type\":\"event\"},{\"inputs\":[],\"name\":\"DEFAULT_ADMIN_ROLE\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"LOCK_ROLE\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"MINTER_ROLE\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"PAUSER_ROLE\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"}],\"name\":\"balanceOf\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address[]\",\"name\":\"accounts\",\"type\":\"address[]\"},{\"internalType\":\"uint256[]\",\"name\":\"ids\",\"type\":\"uint256[]\"}],\"name\":\"balanceOfBatch\",\"outputs\":[{\"internalType\":\"uint256[]\",\"name\":\"\",\"type\":\"uint256[]\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"burn\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"internalType\":\"uint256[]\",\"name\":\"ids\",\"type\":\"uint256[]\"},{\"internalType\":\"uint256[]\",\"name\":\"values\",\"type\":\"uint256[]\"}],\"name\":\"burnBatch\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"}],\"name\":\"getRoleAdmin\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"internalType\":\"uint256\",\"name\":\"index\",\"type\":\"uint256\"}],\"name\":\"getRoleMember\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"}],\"name\":\"getRoleMemberCount\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getTokenBaseURI\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getUriType\",\"outputs\":[{\"internalType\":\"uint8\",\"name\":\"\",\"type\":\"uint8\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"grantRole\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"hasRole\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"operator\",\"type\":\"address\"}],\"name\":\"isApprovedForAll\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"internalType\":\"bytes\",\"name\":\"data\",\"type\":\"bytes\"}],\"name\":\"mint\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"internalType\":\"string\",\"name\":\"tokenUri\",\"type\":\"string\"},{\"internalType\":\"bytes\",\"name\":\"data\",\"type\":\"bytes\"}],\"name\":\"mint\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256[]\",\"name\":\"ids\",\"type\":\"uint256[]\"},{\"internalType\":\"uint256[]\",\"name\":\"amounts\",\"type\":\"uint256[]\"},{\"internalType\":\"bytes\",\"name\":\"data\",\"type\":\"bytes\"}],\"name\":\"mintBatch\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256[]\",\"name\":\"tokenIds\",\"type\":\"uint256[]\"},{\"internalType\":\"uint256[]\",\"name\":\"amounts\",\"type\":\"uint256[]\"},{\"internalType\":\"string[]\",\"name\":\"tokenUris\",\"type\":\"string[]\"},{\"internalType\":\"bytes\",\"name\":\"data\",\"type\":\"bytes\"}],\"name\":\"mintBatch\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"pause\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"paused\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"renounceOwnership\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"renounceRole\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"role\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"revokeRole\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256[]\",\"name\":\"ids\",\"type\":\"uint256[]\"},{\"internalType\":\"uint256[]\",\"name\":\"amounts\",\"type\":\"uint256[]\"},{\"internalType\":\"bytes\",\"name\":\"data\",\"type\":\"bytes\"}],\"name\":\"safeBatchTransferFrom\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"internalType\":\"bytes\",\"name\":\"data\",\"type\":\"bytes\"}],\"name\":\"safeTransferFrom\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"operator\",\"type\":\"address\"},{\"internalType\":\"bool\",\"name\":\"approved\",\"type\":\"bool\"}],\"name\":\"setApprovalForAll\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"tokenBaseURI_\",\"type\":\"string\"}],\"name\":\"setTokenBaseURI\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint8\",\"name\":\"uriType_\",\"type\":\"uint8\"}],\"name\":\"setUriType\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes4\",\"name\":\"interfaceId\",\"type\":\"bytes4\"}],\"name\":\"supportsInterface\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"newOwner\",\"type\":\"address\"}],\"name\":\"transferOwnership\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"unpause\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"uri\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"}]"
public var abiWrapped20 = "[[{\"inputs\":[{\"internalType\":\"string\",\"name\":\"name\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"symbol\",\"type\":\"string\"},{\"internalType\":\"address\",\"name\":\"bridge\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"spender\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"spender\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"internalType\":\"uint8\",\"name\":\"\",\"type\":\"uint8\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"spender\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"subtractedValue\",\"type\":\"uint256\"}],\"name\":\"decreaseAllowance\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"spender\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"addedValue\",\"type\":\"uint256\"}],\"name\":\"increaseAllowance\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getBridge\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"bridge\",\"type\":\"address\"}],\"name\":\"setBridge\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getPublisher\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"publisher\",\"type\":\"address\"}],\"name\":\"setPublisher\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"mint\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"burn\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"burnFrom\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]]";

public var abiWrappedERC721 =
"[{\"inputs\":[{\"internalType\":\"address\",\"name\":\"transfer\",\"type\":\"address\"},{\"internalType\":\"string\",\"name\":\"_name\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"_symbol\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"baseUri\",\"type\":\"string\"},{\"internalType\":\"uint8\",\"name\":\"uriType\",\"type\":\"uint8\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"approved\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"operator\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"bool\",\"name\":\"approved\",\"type\":\"bool\"}],\"name\":\"ApprovalForAll\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"previousOwner\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"newOwner\",\"type\":\"address\"}],\"name\":\"OwnershipTransferred\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"inputs\":[],\"name\":\"_uriType\",\"outputs\":[{\"internalType\":\"uint8\",\"name\":\"\",\"type\":\"uint8\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"getApproved\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"operator\",\"type\":\"address\"}],\"name\":\"isApprovedForAll\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"renounceOwnership\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"safeTransferFrom\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"},{\"internalType\":\"bytes\",\"name\":\"data\",\"type\":\"bytes\"}],\"name\":\"safeTransferFrom\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"operator\",\"type\":\"address\"},{\"internalType\":\"bool\",\"name\":\"approved\",\"type\":\"bool\"}],\"name\":\"setApprovalForAll\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes4\",\"name\":\"interfaceId\",\"type\":\"bytes4\"}],\"name\":\"supportsInterface\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getTransfer\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"transfer\",\"type\":\"address\"}],\"name\":\"setTransfer\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getPublisher\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"publisher\",\"type\":\"address\"}],\"name\":\"setPublisher\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"ownerOf\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"tokenURI\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"},{\"internalType\":\"string\",\"name\":\"tokenUri\",\"type\":\"string\"}],\"name\":\"setTokenURI\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"baseUri\",\"type\":\"string\"}],\"name\":\"setBaseURI\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getBaseURI\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getUriType\",\"outputs\":[{\"internalType\":\"uint8\",\"name\":\"\",\"type\":\"uint8\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint8\",\"name\":\"uriType\",\"type\":\"uint8\"}],\"name\":\"setUriType\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"},{\"internalType\":\"string\",\"name\":\"uri\",\"type\":\"string\"}],\"name\":\"mint\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"burn\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"lockState\",\"outputs\":[{\"internalType\":\"uint8\",\"name\":\"\",\"type\":\"uint8\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"lock\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"unlock\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"},{\"internalType\":\"string\",\"name\":\"tokenUri\",\"type\":\"string\"}],\"name\":\"export721\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"newOwner\",\"type\":\"address\"}],\"name\":\"transferOwnership\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"

public var deployERC721 = "[{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"addrToken\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"string\",\"name\":\"tokenType\",\"type\":\"string\"}],\"name\":\"Deployed\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"name\":\"balanceReceived\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"name\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"symbol\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"tokenBaseURI\",\"type\":\"string\"},{\"internalType\":\"uint8\",\"name\":\"uriType_\",\"type\":\"uint8\"},{\"internalType\":\"address\",\"name\":\"owner_\",\"type\":\"address\"}],\"name\":\"deployedERC721\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"addrToken\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getBalance\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"receiveMoney\",\"outputs\":[],\"stateMutability\":\"payable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address payable\",\"name\":\"_to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"_amount\",\"type\":\"uint256\"}],\"name\":\"withdrawMoney\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"stateMutability\":\"payable\",\"type\":\"receive\"}]"

public var deployERC1155 = "[{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"addrToken\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"string\",\"name\":\"tokenType\",\"type\":\"string\"}],\"name\":\"Deployed\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"name\":\"balanceReceived\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"name\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"symbol\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"tokenBaseURI\",\"type\":\"string\"},{\"internalType\":\"uint8\",\"name\":\"uriType_\",\"type\":\"uint8\"},{\"internalType\":\"address\",\"name\":\"owner_\",\"type\":\"address\"}],\"name\":\"deployedERC1155\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"addrToken\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getBalance\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"receiveMoney\",\"outputs\":[],\"stateMutability\":\"payable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address payable\",\"name\":\"_to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"_amount\",\"type\":\"uint256\"}],\"name\":\"withdrawMoney\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"stateMutability\":\"payable\",\"type\":\"receive\"}]"

public var abiTransferGoerli =  "[{\"inputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\",\"signature\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"reserveID\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"nhID\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"addrToken\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"enum IBridgeEvent.TokenType\",\"name\":\"tokenType\",\"type\":\"uint8\"}],\"name\":\"Create\",\"type\":\"event\",\"signature\":\"0xa5b7aa1aca2501ddcb11a372a1b7b4a699f7bb58cab5f21386422feb845c9552\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"nhNFT\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"enum IBridgeEvent.TokenType\",\"name\":\"kind\",\"type\":\"uint8\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"fromNFT\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"toNetwork\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"fee\",\"type\":\"uint256\"}],\"name\":\"FromNFT\",\"type\":\"event\",\"signature\":\"0x4652b2f214e15200f627dd9f0589f6c1f6fa68aee1f19aed0a895bd3bea74a3b\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"nhToken\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"fromToken\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"toNetwork\",\"type\":\"uint256\"}],\"name\":\"FromToken\",\"type\":\"event\",\"signature\":\"0xe373d781aee465f8eb40b2034aa4c6c769a185c28360f4a8d970c85685258c90\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint8\",\"name\":\"version\",\"type\":\"uint8\"}],\"name\":\"Initialized\",\"type\":\"event\",\"signature\":\"0x7f26b83ff96e1f2b6a682f133852f6798a09c465da95921460cefb3847402498\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"addrToken\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"enum IBridgeEvent.TokenType\",\"name\":\"kind\",\"type\":\"uint8\"},{\"indexed\":false,\"internalType\":\"string\",\"name\":\"baseUri\",\"type\":\"string\"},{\"indexed\":false,\"internalType\":\"uint8\",\"name\":\"uriType\",\"type\":\"uint8\"}],\"name\":\"Register\",\"type\":\"event\",\"signature\":\"0x2771bca31dd40ca5838bfc40fc5063e49ff49235e90223669dc5d81916e52d04\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"nhid\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"enum IBridgeEvent.TokenType\",\"name\":\"kind\",\"type\":\"uint8\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"toToken\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"Rollback\",\"type\":\"event\",\"signature\":\"0x6178a3cfb152f67aa3da61e846377526adf7648be4b942a8965d609659650f23\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"nhid\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"token\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"enum IBridgeEvent.TokenType\",\"name\":\"kind\",\"type\":\"uint8\"},{\"indexed\":false,\"internalType\":\"bool\",\"name\":\"able\",\"type\":\"bool\"}],\"name\":\"SetWrapped\",\"type\":\"event\",\"signature\":\"0xf1b389efb3d920ecab565443ece138fe688ad0a501dbfad1e7a655c6ea1e690b\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"transId\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"nhid\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"nhTokenId\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"enum IBridgeEvent.TokenType\",\"name\":\"kind\",\"type\":\"uint8\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"toToken\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"toTokenId\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"ToNFT\",\"type\":\"event\",\"signature\":\"0x9008c2c4b6b5b4c6d3e4f99d0cf734ba233740c12aed563b1a0f5114a7f71b83\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"transId\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"nhid\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"toToken\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"ToToken\",\"type\":\"event\",\"signature\":\"0xefb9c013ecb6b4f83e49b67984ab9a06c79dad27d507fe5ee4824fcae82fd45e\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"bridgeConfig\",\"type\":\"address\"}],\"name\":\"initialize\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0xc4d66de8\"},{\"inputs\":[],\"name\":\"getConfigAddr\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\",\"constant\":true,\"signature\":\"0xa79314b5\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"config\",\"type\":\"address\"}],\"name\":\"setConfigAddr\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0xb00664d7\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nftAddr\",\"type\":\"address\"},{\"internalType\":\"string\",\"name\":\"baseUri\",\"type\":\"string\"}],\"name\":\"setBaseURI\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0x88433651\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nftAddr\",\"type\":\"address\"},{\"internalType\":\"uint8\",\"name\":\"uriType\",\"type\":\"uint8\"}],\"name\":\"setUriType\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0x7f7df879\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nftAddr\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"newPublisher\",\"type\":\"address\"}],\"name\":\"setPublisher\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0x33e2eb8d\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nftAddr\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"ownable\",\"type\":\"address\"}],\"name\":\"transferOwnership\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0x6d435421\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"nhNFT\",\"type\":\"uint256\"},{\"internalType\":\"address\",\"name\":\"thisNFT\",\"type\":\"address\"},{\"internalType\":\"bool\",\"name\":\"thisLockable\",\"type\":\"bool\"},{\"internalType\":\"uint8\",\"name\":\"nftType\",\"type\":\"uint8\"}],\"name\":\"setWrapNFT\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0x32193f4d\"},{\"inputs\":[],\"name\":\"getWrapNFTLength\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\",\"constant\":true,\"signature\":\"0x1666de87\"},{\"inputs\":[{\"internalType\":\"uint32\",\"name\":\"idx\",\"type\":\"uint32\"}],\"name\":\"getWrapNFTByIdx\",\"outputs\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"nhNFT\",\"type\":\"uint256\"},{\"internalType\":\"address\",\"name\":\"thisNFT\",\"type\":\"address\"},{\"internalType\":\"bool\",\"name\":\"thisLockable\",\"type\":\"bool\"},{\"internalType\":\"uint8\",\"name\":\"nftType\",\"type\":\"uint8\"}],\"internalType\":\"struct IBridgeConfig.WrappedNFT\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\",\"constant\":true,\"signature\":\"0x26183828\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"thisNFT\",\"type\":\"address\"}],\"name\":\"getWrapIdxByThisNFT\",\"outputs\":[{\"internalType\":\"uint32\",\"name\":\"\",\"type\":\"uint32\"}],\"stateMutability\":\"view\",\"type\":\"function\",\"constant\":true,\"signature\":\"0xf8ed9adf\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"nhNFT\",\"type\":\"uint256\"}],\"name\":\"getWrapIdxByNHNFT\",\"outputs\":[{\"internalType\":\"uint32\",\"name\":\"\",\"type\":\"uint32\"}],\"stateMutability\":\"view\",\"type\":\"function\",\"constant\":true,\"signature\":\"0xdb99db94\"},{\"inputs\":[{\"internalType\":\"uint32\",\"name\":\"idx\",\"type\":\"uint32\"}],\"name\":\"deleteWrapNFTByIdx\",\"outputs\":[{\"internalType\":\"uint32\",\"name\":\"\",\"type\":\"uint32\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0xb4944d38\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"reserveID\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"nftNHID\",\"type\":\"uint256\"},{\"internalType\":\"string\",\"name\":\"name\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"symbol\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"baseUri\",\"type\":\"string\"},{\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"internalType\":\"uint8\",\"name\":\"uriType\",\"type\":\"uint8\"}],\"name\":\"createWrapped721\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"newThisNFT\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0x83b55f6c\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"name\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"symbol\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"baseUri\",\"type\":\"string\"},{\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"internalType\":\"uint8\",\"name\":\"uriType\",\"type\":\"uint8\"}],\"name\":\"deployWrapped721\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"newThisNFT\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0x2536b946\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"reserveID\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"nftNHID\",\"type\":\"uint256\"},{\"internalType\":\"string\",\"name\":\"baseUri\",\"type\":\"string\"},{\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"internalType\":\"uint8\",\"name\":\"uriType\",\"type\":\"uint8\"}],\"name\":\"createWrapped1155\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"newThisNFT\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0x2134205d\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"baseUri\",\"type\":\"string\"},{\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"internalType\":\"uint8\",\"name\":\"uriType\",\"type\":\"uint8\"}],\"name\":\"deployWrapped1155\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"newThisNFT\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0x2163bfb6\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"addrNFT\",\"type\":\"address\"},{\"internalType\":\"enum IBridgeEvent.TokenType\",\"name\":\"nftKind\",\"type\":\"uint8\"},{\"internalType\":\"string\",\"name\":\"baseUri\",\"type\":\"string\"},{\"internalType\":\"uint8\",\"name\":\"uriType\",\"type\":\"uint8\"}],\"name\":\"registerNFT\",\"outputs\":[],\"stateMutability\":\"payable\",\"type\":\"function\",\"payable\":true,\"signature\":\"0x8f612615\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"toNetwork\",\"type\":\"uint256\"},{\"internalType\":\"address\",\"name\":\"addrNFT\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"moveFromERC721\",\"outputs\":[],\"stateMutability\":\"payable\",\"type\":\"function\",\"payable\":true,\"signature\":\"0x4196ac9d\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"toNetwork\",\"type\":\"uint256\"},{\"internalType\":\"address\",\"name\":\"addrNFT\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"moveFromERC1155\",\"outputs\":[],\"stateMutability\":\"payable\",\"type\":\"function\",\"payable\":true,\"signature\":\"0xbf603207\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"transId\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"nhTokenAddr\",\"type\":\"uint256\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"nhTokenId\",\"type\":\"uint256\"},{\"internalType\":\"string\",\"name\":\"uri\",\"type\":\"string\"}],\"name\":\"moveToERC721\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0x342c5989\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"transId\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"nhTokenAddr\",\"type\":\"uint256\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"nhTokenId\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"internalType\":\"string\",\"name\":\"uri\",\"type\":\"string\"}],\"name\":\"moveToERC1155\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0x4ed80915\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"transId\",\"type\":\"uint256\"},{\"internalType\":\"address\",\"name\":\"addrNFT\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"}],\"name\":\"rollbackERC721\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0x5a5dbf26\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"transId\",\"type\":\"uint256\"},{\"internalType\":\"address\",\"name\":\"addrNFT\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"tokenId\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"rollbackERC1155\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\",\"signature\":\"0xffcdca28\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"bytes\",\"name\":\"\",\"type\":\"bytes\"}],\"name\":\"onERC1155Received\",\"outputs\":[{\"internalType\":\"bytes4\",\"name\":\"\",\"type\":\"bytes4\"}],\"stateMutability\":\"pure\",\"type\":\"function\",\"constant\":true,\"signature\":\"0xf23a6e61\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"bytes\",\"name\":\"\",\"type\":\"bytes\"}],\"name\":\"onERC721Received\",\"outputs\":[{\"internalType\":\"bytes4\",\"name\":\"\",\"type\":\"bytes4\"}],\"stateMutability\":\"pure\",\"type\":\"function\",\"constant\":true,\"signature\":\"0x150b7a02\"}]"


// Create RSA key pair
public func generateRSAKeyPair() throws -> (publicKey: SecKey, privateKey: SecKey) {
    let attributes: [CFString: Any] = [
        kSecAttrKeyType: kSecAttrKeyTypeRSA,
        kSecAttrKeySizeInBits: 2048
    ]
    
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
        throw error!.takeRetainedValue() as Error
    }
    
    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
        throw NSError(domain: "YourErrorDomain", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Failed to generate public key"
        ])
    }
    
    return (publicKey, privateKey)
}

// Initialize and save Key Pair
public func initializeKeyPair() throws {
    let keyPair = try generateRSAKeyPair()
    let publicKey = keyPair.publicKey
    let privateKey = keyPair.privateKey
    
    // Save public key
    try saveKey(key: "public_key", data: publicKey)
    
    // Save private key
    try saveKey(key: "private_key", data: privateKey)
}

// Generate public key
public func getPublicKey() throws -> SecKey {
    if let publicKey = try loadKey(key:"public_key") {
            return publicKey
    } else {
        try initializeKeyPair()
        let publicKey = try loadKey(key:"public_key")
        return publicKey!
    }

}

// Generate private key
public func getPrivateKey() throws -> SecKey {
    let privateKey = try loadKey(key:"private_key")
    return privateKey!
}


// Encrypt
public func encrypt(input: String) throws -> String? {
    let publicKey = try getPublicKey()
    
    guard let data = input.data(using: .utf8) else {
        return nil
    }
    
    var error: Unmanaged<CFError>?
    guard let encryptedData = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionPKCS1, data as CFData, &error) else {
        throw error!.takeRetainedValue() as Error
    }
    
    let encryptedDataAsData = encryptedData as Data
    let base64EncodedData = encryptedDataAsData.base64EncodedString()
    return base64EncodedData
}

// Decrypt
public func decrypt(input: String) throws -> String? {
    let privateKey = try getPrivateKey()
    
    guard let encryptedData = Data(base64Encoded: input) else {
        return nil
    }
    
    var error: Unmanaged<CFError>?
    guard let decryptedData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionPKCS1, encryptedData as CFData, &error) else {
        throw error!.takeRetainedValue() as Error
    }
    
    guard let decryptedString = String(data: decryptedData as Data, encoding: .utf8) else {
        return nil
    }
    
    return decryptedString
}

// Save key
public func saveKey(key: String, data: SecKey) throws {
    let query: [CFString: Any] = [
        kSecClass: kSecClassKey,
        kSecAttrApplicationTag: key,
        kSecValueRef: data
    ]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
        throw NSError(domain: "YourErrorDomain", code: Int(status), userInfo: [
            NSLocalizedDescriptionKey: "Failed to save key in Keychain"
        ])
    }
}

// Load key
public func loadKey(key: String) throws -> SecKey? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassKey,
        kSecAttrApplicationTag as String: key,
        kSecReturnRef as String: true
    ]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status == errSecSuccess else {
        if status == errSecItemNotFound {
            return nil
        }
        throw NSError(domain: "YourErrorDomain", code: Int(status), userInfo: [
            NSLocalizedDescriptionKey: "Failed to fetch key from Keychain"
        ])
    }
    
    if CFGetTypeID(item) == SecKeyGetTypeID() {
        return item as! SecKey
    } else {
        return nil
    }
}

// Save json
public func saveJsonData(jsonObject: JSON, key: String) {
    let keychain = Keychain()
    let jsonData = try? jsonObject.rawData()
    keychain[data: key] = jsonData
}

// Load json
public func loadJsonData(key: String) -> JSON? {
    let keychain = Keychain()
    if let jsonData = keychain[data: key] {
        return try? JSON(data: jsonData)
    }
    return nil
}

// Change json String type
public func changeJsonString(useData:Any) -> String {
    let jsonData = try! JSONSerialization.data(withJSONObject: useData)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    return jsonString
}

// Change json object type
public func changeJsonObject(useData: [String: Any]) -> JSON {
    var jsonDictionary: JSON = [:]
    
    for(key, value) in useData {
        let jsonValue = JSON(value)
        jsonDictionary[key] = jsonValue
    }
    return jsonDictionary
}

// get Gas Price
public func getEstimateGasAsync(network: String, txType: String, tokenAddress: String? = nil, fromAddress: String? = nil, toAddress: String? = nil, tokenAmount: String? = nil, tokenId: String? = nil, toTokenAddress: String? = nil, toNetwork: String? = nil, batchTokenId: [String]? = nil, batchTokenAmount: [String]? = nil, batchTokenURI: [String]? = nil, name: String? = nil, symbol: String? = nil, baseURI: String? = nil, owner: String? = nil, uriType: String? = nil, tokenURI: String? = nil) async throws -> BigUInt? {
    
    networkSettings(network: network)
    var url = try await URL(string:rpcUrl)
    let web3 = try await Web3.new(url!)
    var gasPrice: BigUInt? = nil
    
    switch txType {
    case "baseFee":
        gasPrice = try await web3.eth.gasPrice()
//        let a = EthereumAddress(from: "0x2BfDa9A30384FcFa91D6D834D1491b4094C375A3")
//        let contract = web3.contract(abiWrappedERC721, at: a)!
//        let readOp = contract.createReadOperation("owner")!
//        readOp.transaction.from = EthereumAddress("0x2BfDa9A30384FcFa91D6D834D1491b4094C375A3")
//        let response = try await readOp.callContractMethod()
//        print(response)
    case "transferCoin":
        if let toAddress = toAddress, let fromAddress = fromAddress, let tokenAmount = tokenAmount {
            let from = EthereumAddress(fromAddress)!
            let to = EthereumAddress(toAddress)!
            let data = "0x".data(using: .utf8)!
            let nonce = try await web3.eth.getTransactionCount(for: from, onBlock: .pending)
            guard let value = Utilities.parseToBigUInt(tokenAmount, decimals: 18) else {
                throw Web3Error.inputError(desc: "Cannot parse inputted amount")
            }
            var transaction = CodableTransaction(to:to, nonce:nonce, chainID:chainID, value:value, data:data)
            let estimateGas = try await web3.eth.estimateGas(for: transaction)
            gasPrice = estimateGas
        }
    case "transferERC20":
        if let tokenAddress = tokenAddress, let toAddress = toAddress, let fromAddress = fromAddress, let tokenAmount = tokenAmount {
            let from = EthereumAddress(fromAddress)
            let to = EthereumAddress(toAddress)
            let token = EthereumAddress(tokenAddress)
            let contract = web3.contract(Web3.Utils.erc20ABI, at: token, abiVersion: 2)!
            let callResult = try await contract
                .createReadOperation("decimals")!
                .callContractMethod()
            
            var decimals = BigUInt(0)
            guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
                throw Web3Error.inputError(desc: "Contract may not be ERC20 compatible, cannot get decimals")
            }
            decimals = decTyped
            
            let intDecimals = Int(decimals)
            guard let value = Utilities.parseToBigUInt(tokenAmount, decimals: intDecimals) else {
                throw Web3Error.inputError(desc: "Cannot parse inputted amount")
            }
            
            let contractData = contract.contract.method("transfer", parameters: [to!, value], extraData: Data())
            var transaction = CodableTransaction(type: .eip1559, to: token!, chainID: chainID, data: contractData!)
            transaction.from = from
            let estimateGas = try await web3.eth.estimateGas(for: transaction)
            gasPrice = estimateGas
        }
    case "transferERC721":
        if (tokenAddress != nil && toAddress != nil && fromAddress != nil && tokenId != nil) {
            let from = EthereumAddress(fromAddress!)
            let to = EthereumAddress(toAddress!)
            let token = EthereumAddress(tokenAddress!)
            let contract = web3.contract(Web3.Utils.erc721ABI, at: token, abiVersion: 2)!
            let contractData = contract.contract.method("safeTransferFrom", parameters: [from, to, BigUInt(tokenId!)], extraData: Data())
            var transaction: CodableTransaction = CodableTransaction(type:.eip1559, to:token!, chainID:chainID, data: contractData!)
            transaction.from = from
            let estimateGas = try await web3.eth.estimateGas(for: transaction)
            gasPrice = estimateGas
        }
    case "transferERC1155":
        if (tokenAddress != nil && toAddress != nil && fromAddress != nil && tokenId != nil && tokenAmount != nil) {
            let from = EthereumAddress(fromAddress!)
            let to = EthereumAddress(toAddress!)
            let token = EthereumAddress(tokenAddress!)
            let contract = web3.contract(Web3.Utils.erc1155ABI, at: token, abiVersion: 2)!
            let contractData = contract.contract.method("safeTransferFrom", parameters: [from, to, BigUInt(tokenId!), BigUInt(tokenAmount!), [UInt8(0)]], extraData: Data())
            var transaction: CodableTransaction = CodableTransaction(type:.eip1559, to:token!, chainID:chainID, data: contractData!)
            transaction.from = from
            let estimateGas = try await web3.eth.estimateGas(for: transaction)
            gasPrice = estimateGas
        }
    case "batchTransferERC721":
        if (fromAddress != nil && toAddress != nil && fromAddress != nil && batchTokenId != nil) {
            let from = EthereumAddress(fromAddress!)
            let to = EthereumAddress(toAddress!)
            let token = EthereumAddress(tokenAddress!)
            let tokenId = batchTokenId!
            let contract = web3.contract(kthuluErc721, at: token, abiVersion: 2)!
            let contractData = contract.contract.method("safeBatchTransferFrom", parameters: [from, to, tokenId.compactMap{BigUInt($0)}], extraData: Data())
            var transaction: CodableTransaction = CodableTransaction(type:.eip1559, to:token!, chainID:chainID, data: contractData!)
            transaction.from = from
            let estimateGas = try await web3.eth.estimateGas(for: transaction)
            gasPrice = estimateGas
        }
    case "batchTransferERC1155":
        if (fromAddress != nil && toAddress != nil && fromAddress != nil && batchTokenId != nil && batchTokenAmount != nil) {
            let from = EthereumAddress(fromAddress!)
            let to = EthereumAddress(toAddress!)
            let token = EthereumAddress(tokenAddress!)
            let tokenId = batchTokenId!
            let amount = batchTokenAmount!
            let contract = web3.contract(kthuluErc1155, at: token, abiVersion: 2)!
            let contractData = contract.contract.method("safeBatchTransferFrom", parameters: [from, to, tokenId.compactMap{BigUInt($0)}, amount.compactMap{BigUInt($0)}, [UInt8(0)]], extraData: Data())
            var transaction: CodableTransaction = CodableTransaction(type:.eip1559, to:token!, chainID:chainID, data: contractData!)
            transaction.from = from
            let estimateGas = try await web3.eth.estimateGas(for: transaction)
            gasPrice = estimateGas
        }
    case "deployERC20":
        if (name != nil && symbol != nil && fromAddress != nil && tokenAmount != nil) {
            let from = EthereumAddress(fromAddress!)
            let ca = EthereumAddress(erc20DeployContractAddress)
            let contract = web3.contract(erc20MumbaiAbi, at: ca, abiVersion: 2)!
            let contractData = contract.contract.method("deployedERC20", parameters: [name,symbol,BigUInt(tokenAmount!), fromAddress], extraData: Data())
            var transaction: CodableTransaction = CodableTransaction(type:.eip1559, to:ca!, chainID:chainID, data: contractData!)
            transaction.from = from
            let estimateGas = try await web3.eth.estimateGas(for: transaction)
            gasPrice = estimateGas
        }
    case "deployERC721":
        if (name != nil && symbol != nil && fromAddress != nil && owner != nil && baseURI != nil && uriType != nil) {
            let from = EthereumAddress(fromAddress!)
            let owner = EthereumAddress(owner!)
            let ca = EthereumAddress(erc721DeployContractAddress)
            let contract = web3.contract(deployERC721, at: ca, abiVersion: 2)!
            let contractData = contract.contract.method("deployedERC721", parameters: [name, symbol, baseURI, UInt8(uriType!), owner], extraData: Data())
            var transaction: CodableTransaction = CodableTransaction(type:.eip1559, to:ca!, chainID:chainID, data: contractData!)
            transaction.from = from
            let estimateGas = try await web3.eth.estimateGas(for: transaction)
            gasPrice = estimateGas
        }
    case "deployERC1155":
        if (name != nil && symbol != nil && fromAddress != nil && owner != nil && baseURI != nil && uriType != nil) {
            let from = EthereumAddress(fromAddress!)
            let owner = EthereumAddress(owner!)
            let ca = EthereumAddress(erc1155DeployContractAddress)
            let contract = web3.contract(deployERC1155, at: ca, abiVersion: 2)!
            let contractData = contract.contract.method("deployedERC1155", parameters: [name, symbol, baseURI, UInt8(uriType!), owner], extraData: Data())
            var transaction: CodableTransaction = CodableTransaction(type:.eip1559, to:ca!, chainID:chainID, data: contractData!)
            transaction.from = from
            let estimateGas = try await web3.eth.estimateGas(for: transaction)
            gasPrice = estimateGas
        }
    case "mintERC721":
           if (fromAddress != nil && toAddress != nil && tokenURI != nil && tokenId != nil && tokenAddress != nil) {
               let from = EthereumAddress(fromAddress!)
               let to = EthereumAddress(toAddress!)
               let ca = EthereumAddress(tokenAddress!)
               let contract = web3.contract(kthuluErc721, at: ca, abiVersion: 2)!
               let contractData = contract.contract.method("mint", parameters: [to,BigUInt(tokenId!),tokenURI], extraData: Data())
               var transaction: CodableTransaction = CodableTransaction(type:.eip1559, to:ca!, chainID:chainID, data: contractData!)
               transaction.from = from
               let estimateGas = try await web3.eth.estimateGas(for: transaction)
               gasPrice = estimateGas
           }
    case "mintERC1155":
           if (fromAddress != nil && toAddress != nil && tokenURI != nil && tokenId != nil && tokenAddress != nil && tokenAmount != nil) {
               let from = EthereumAddress(fromAddress!)
               let to = EthereumAddress(toAddress!)
               let ca = EthereumAddress(tokenAddress!)
               let contract = web3.contract(kthuluErc1155, at: ca, abiVersion: 2)!
               let contractData = contract.contract.method("mint", parameters: [to,BigUInt(tokenId!),BigUInt(tokenAmount!),tokenURI,[UInt8(0)]], extraData: Data())
               var transaction: CodableTransaction = CodableTransaction(type:.eip1559, to:ca!, chainID:chainID, data: contractData!)
               transaction.from = from
               let estimateGas = try await web3.eth.estimateGas(for: transaction)
               gasPrice = estimateGas
           }
    case "batchMintERC721":
           if (fromAddress != nil && toAddress != nil && batchTokenURI != nil && batchTokenId != nil && tokenAddress != nil) {
               let from = EthereumAddress(fromAddress!)
               let to = EthereumAddress(toAddress!)
               let ca = EthereumAddress(tokenAddress!)
               let contract = web3.contract(kthuluErc721, at: ca, abiVersion: 2)!
               let contractData = contract.contract.method("mintBatch", parameters: [to, batchTokenId!.compactMap{BigUInt($0)}, batchTokenURI], extraData: Data())
               var transaction: CodableTransaction = CodableTransaction(type:.eip1559, to:ca!, chainID:chainID, data: contractData!)
               transaction.from = from
               let estimateGas = try await web3.eth.estimateGas(for: transaction)
               gasPrice = estimateGas
           }
    case "batchMintERC1155":
           if (fromAddress != nil && toAddress != nil && batchTokenURI != nil && batchTokenId != nil && tokenAddress != nil && batchTokenAmount != nil) {
               let from = EthereumAddress(fromAddress!)
               let to = EthereumAddress(toAddress!)
               let ca = EthereumAddress(tokenAddress!)
               let contract = web3.contract(kthuluErc1155, at: ca, abiVersion: 2)!
               let contractData = contract.contract.method("mintBatch", parameters: [to, batchTokenId!.compactMap{BigUInt($0)}, batchTokenAmount!.compactMap{BigUInt($0)}, batchTokenURI, [UInt8(0)]], extraData: Data())
               var transaction: CodableTransaction = CodableTransaction(type:.eip1559, to:ca!, chainID:chainID, data: contractData!)
               transaction.from = from
               let estimateGas = try await web3.eth.estimateGas(for: transaction)
               gasPrice = estimateGas
           }
    case "burnERC721":
           if (fromAddress != nil && tokenId != nil && tokenAddress != nil) {
               let from = EthereumAddress(fromAddress!)
               let ca = EthereumAddress(tokenAddress!)
               let contract = web3.contract(kthuluErc721, at: ca, abiVersion: 2)!
               let contractData = contract.contract.method("burn", parameters: [BigUInt(tokenId!)], extraData: Data())
               var transaction: CodableTransaction = CodableTransaction(type:.eip1559, to:ca!, chainID:chainID, data: contractData!)
               transaction.from = from
               let estimateGas = try await web3.eth.estimateGas(for: transaction)
               gasPrice = estimateGas
           }
    case "burnERC1155":
           if (fromAddress != nil && tokenId != nil && tokenAddress != nil && tokenAmount != nil) {
               let from = EthereumAddress(fromAddress!)
               let ca = EthereumAddress(tokenAddress!)
               let contract = web3.contract(kthuluErc1155, at: ca, abiVersion: 2)!
               let contractData = contract.contract.method("burn", parameters: [from,BigUInt(tokenId!),BigUInt(tokenAmount!)], extraData: Data())
               var transaction: CodableTransaction = CodableTransaction(type:.eip1559, to:ca!, chainID:chainID, data: contractData!)
               transaction.from = from
               let estimateGas = try await web3.eth.estimateGas(for: transaction)
               gasPrice = estimateGas
           }

    default:
        break
    }
    
    if let gasPrice = gasPrice {
        return BigUInt(Double(gasPrice) * 1.2) // Multiply by 1.2
    }
    
    return nil
}
