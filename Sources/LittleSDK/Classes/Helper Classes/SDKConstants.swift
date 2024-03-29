//
//  Constants.swift
//  LittleSDK
//
//  Created by Gabriel John on 10/05/2021.
//

import UIKit

class SDKConstants {
    
    var chainkey: NSString=""
    var iv: NSString="i7otp4rq4ysrdh5v"
    var headerkey: NSString=""
    var headeriv: NSString="HDJAK$2$23232Fax"
        
    var live = "lwCGahusOkXBoFnNKoWjOC58LxqE0rYr6QCBcag234r0pkyhIFs/8YyL3zZcOT1C"
    var uat = "oMmWr0f0bfDELjSmIqIpgnU/USZNk3hHo+k42DEsDlEejQ+2FXu21HrYmzke3fgyJs+FRbwCnp+JwTBHLP49mw=="
    var mapsKey = "H+9x5dNgB0X7+tCZaCwKe9SbL0rG7i55NxDxQ+LReuubZ+nLUyINNG70bIAgqkME"
    var placesKey = "qn89yrVStFuJG6EEqugAV92lsc77lTXy1DeXZWhu3/4SZH6ASWxUB4zepBJ9TMrW"
    var littleMapKey = "/iPGWhGGttczgqTb/ZAXW8KcCKzPlbe259mm7o2VnHAuzftRz+s6VHkH5LguC1WK"
    
    init(){
        let _key1:String="X0MZL&sHwmxbtA"
        let _key2:String="A29C333B-2C77-4094-A1D3-856BA52C"
        chainkey = _key1.hash256() as NSString
        headerkey = _key2 as NSString
    }
    
    func link() -> String {
        if SDKAllMethods().getIsUAT() {
            return uat
        }
        
        return live
    }
    
    static let testDriverEmail = "og12@gmail.com"
    
    // Colors
    static let littleRed = UIColor(hex: "#D52029")
    static let littleGreen = UIColor(hex: "#0D9848")
    
    // Equity
//    static var littleSDKThemeColor = UIColor(hex: "#A32A29")
    // Vooma
    static var littleSDKThemeColor = UIColor(hex: "#891755")
    
    // Equity
//    static var littleSDKDarkThemeColor = UIColor(hex: "#A32A29")
    // Vooma
    static var littleSDKDarkThemeColor = UIColor(hex: "#891755")
    
    static var littleSDKLabelColor = UIColor(hex: "#404040")
    static var littleSDKCellBackgroundColor = UIColor(hex: "#FFFFFF")
    static var littleSDKPageBackgroundColor = UIColor(hex: "#FFFFFF")
    
    // Change to vooma or quity
    static let SDK_CLIENT = SDKClient.VOOMA
    
}
