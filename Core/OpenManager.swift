//
//  OpenManager.swift
//  OpenKit
//
//  Created by William Lee on 09/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public class OpenManager {

}

// MARK: - Register
public extension OpenManager {
  
  /// 注册微信开放平台SDK
  ///
  /// - Parameters:
  ///   - appID: 开放平台AppID
  ///   - appSecret: 开放平台AppSecret
  class func registerWeChatSDK(withAppID appID: String, appSecret: String) {
    
    WeChatManager.register(appID, appSecret)
  }
  
  /// 注册新浪微博开放平台SDK
  ///
  /// - Parameters:
  ///   - appID: 开放平台AppID
  ///   - appKey: 开放平台AppKey
  ///   - redirectURI: 开放平台回调地址
  class func registerSinaWeiboSDK(withAppID appID: String, appKey: String, redirectURI: String) {
    
    SinaWeiboManager.register(appID, appKey, redirectURI)
  }
  
  /// 注册QQ开放平台SDK
  ///
  /// - Parameters:
  ///   - appID: 开放平台AppID
  ///   - appSecret: 开放平台AppSecret
  class func registerQQSDK(withAppID appID: String, appSecret: String) {
    
    QQManager.register(appID, appSecret)
  }
  
}

// MARK: - Check
public extension OpenManager {
  
  /// 是否安装了微信
  class func isInstallWeChat() -> Bool {
    
    return WeChatManager.isInstall()
  }
  
  /// 是否安装了新浪微博
  class func isInstallSinaWeibo() -> Bool {
    
    return SinaWeiboManager.isInstall()
  }
  
}
