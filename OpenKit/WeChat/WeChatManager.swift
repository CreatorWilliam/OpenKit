//
//  WeChatManager.swift
//  OpenKit
//
//  Created by William Lee on 09/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

internal class WeChatManager: NSObject {
  
  static let shared: WeChatManager = WeChatManager()
  
  fileprivate var authorizationHandle: WeChatManager.AuthorizationHandle?
  fileprivate var shareHandle: WeChatManager.ShareHandle?
  fileprivate var payHandle: PayHandle?
  
  fileprivate var appID: String = ""
  fileprivate var appSecret: String = ""
  
  /// 接口调用凭证
  fileprivate var access_token: String?
  /// access_token接口调用凭证超时时间，单位（秒）
  fileprivate var expires_in: String?
  /// 用户刷新access_token
  fileprivate var refresh_token: String?
  /// 授权用户唯一标识
  fileprivate var openid: String?
  /// 用户授权的作用域，使用逗号（,）分隔
  fileprivate var scope: String?
  
  fileprivate var user: WeChatUserItem = WeChatUserItem()
  
  
  private override init() { }
  
}

// MARK: - Required
internal extension WeChatManager {
  
  /// 注册SDK
  class func register(_ appID: String, _ appSecret: String) {
    
    WeChatManager.shared.appID = appID
    WeChatManager.shared.appSecret = appSecret
    WXApi.registerApp(appID, enableMTA: false)
  }
  
  /// 通知SDK是否响应打开URL
  class func handleOpen(_ url: URL) -> Bool {
    
    return WXApi.handleOpen(url, delegate: WeChatManager.shared)
  }
  
}

// MARK: - Optional
internal extension WeChatManager {
  
  /// 是否安装了微信
  class func isInstall() -> Bool {
    
    return WXApi.isWXAppInstalled()
  }
  
}

// MARK: - Authorization
internal extension WeChatManager {
  
  typealias AuthorizationHandle = (_ user: WeChatUserItem?, _ message: String) -> Void
  class func authorization(handle: @escaping WeChatManager.AuthorizationHandle) {
    
    WeChatManager.shared.authorizationHandle = handle
    
    let request = SendAuthReq()
    request.scope = "snsapi_userinfo"
    request.state = "777"
    
    WXApi.send(request)
  }
  
}

// MARK: - Share
internal extension WeChatManager {
  
  enum ShareScene: Int32 {
    
    //聊天
    case session = 0
    //朋友圈
    case timeline = 1
    //收藏
    case favorite = 2
    
  }
  
  typealias ShareHandle = (_ isSuccess: Bool, _ message: String) -> Void
  class func share(with item: WeChatShareItem, scene: ShareScene, handle: @escaping WeChatManager.ShareHandle) {
    
    WeChatManager.shared.shareHandle = handle
    
    let message = WXMediaMessage()
    message.title = item.title
    message.description = item.content
    message.setThumbImage(item.image)
    
    let webObject = WXWebpageObject()
    webObject.webpageUrl = item.link
    message.mediaObject = webObject
    
    let request = SendMessageToWXReq()
    request.bText = false
    request.message = message
    request.scene = scene.rawValue
    WXApi.send(request)
  }
  
}

// MARK: - Pay
internal extension WeChatManager {
  
  typealias PayHandle = (_ isSuccess: Bool, _ message: String) -> Void
  class func pay(with item: WeChatPayItem, handle: @escaping WeChatManager.PayHandle) {
    
    WeChatManager.shared.payHandle = handle
    
    let request = PayReq()
    request.partnerId           = item.partnerId
    request.prepayId            = item.prepayId
    request.nonceStr            = item.nonceStr
    request.timeStamp           = item.timeStamp
    request.package             = item.package// "Sign=WXPay"
    request.sign                = item.sign
    let result = WXApi.send(request)
    if result == false {
      #if DEBUG
      print("支付失败")
      #endif
    }
  }
  
}

// MARK: - WXApiDelegate
extension WeChatManager: WXApiDelegate {
  
  public func onResp(_ resp: BaseResp!) {
    
    if resp.isKind(of: SendMessageToWXResp.self) {
      
      //分享回调
      guard let response = resp as? SendMessageToWXResp else { return }
      self.handleSendMessageResponse(response)
      
    }
    else if resp.isKind(of: SendAuthResp.self) {
      
      //微信登录回调
      guard let response = resp as? SendAuthResp else { return }
      self.handleSendAuthorizationResponse(response)
      
    }
    else if resp.isKind(of: PayResp.self) {
      
      //微信支付回调
      guard let response = resp as? PayResp else { return }
      self.handleSendPayResponse(response)
      
    }
    else {
      
      //Nothing
    }
  }
  
  public func onReq(_ req: BaseReq!) {
    #if DEBUG
    print(req.openID, req.type)
    #endif
  }
  
}

// MARK: - Handle
fileprivate extension WeChatManager {
  
  func handleSendMessageResponse(_ response: SendMessageToWXResp) {
    
    if response.errCode == WXSuccess.rawValue {
      
      self.shareHandle?(true, "分享成功")
      
    }
    else if response.errCode == WXErrCodeUserCancel.rawValue {
      
      self.shareHandle?(false, "取消分享")
    }
    else {
      
      self.shareHandle?(false, "分享失败")
    }
  }
  
  func handleSendAuthorizationResponse(_ response: SendAuthResp) {
    
    //成功则继续进行
    guard response.errCode == WXSuccess.rawValue else {
      
      self.authorizationHandle?(nil, "获取授权失败")
      return
    }
    
    //获取AccessToken来获取用户信息
    self.getAccessToken(with: response, { (isSuccess) in
      
      guard isSuccess else {
        
        self.authorizationHandle?(nil, "获取授权失败")
        return
      }
      
      //获取用户信息
      self.getUserInfo({ (isSuccess) in
        
        guard isSuccess else {
          
          self.authorizationHandle?(nil, "获取用户信息失败")
          return
        }
        
        self.authorizationHandle?(self.user, "获取用户数据成功")
      })
      
    })
    
  }
  
  func handleSendPayResponse(_ response: PayResp) {
    
    if response.errCode == WXSuccess.rawValue {
      
      self.payHandle?(true, "微信支付成功")
      
    }
    else if response.errCode == WXErrCodeUserCancel.rawValue {
      
      self.payHandle?(false, "取消支付")
    }
    else {
      
      self.payHandle?(false, "微信支付失败：错误码-\(response.errCode)错误信息-\(response.errStr)")
    }
    
  }
  
}

// MARK: - Utility
fileprivate extension WeChatManager {
  
  typealias CompleteHandle = (_ isSuccess: Bool) -> Void
  
  /// API地址
  enum SDK: String {
    
    //基地址
    case base = "https://api.weixin.qq.com"
    
    //获取AccessToken
    case accessToken = "/sns/oauth2/access_token"
    //刷新AccessToken
    case refreshAccessToken = "/sns/oauth2/refresh_token"
    //获取用户信息
    case userInfo = "/sns/userinfo"
    
    //拼接完整的接口地址
    var api: String {
      
      return SDK.base.rawValue.appending(self.rawValue)
    }
    
  }
  
  /// 获取AccessToken
  func getAccessToken(with response:SendAuthResp, _ completeHandle: @escaping CompleteHandle) {
    
    guard let code = response.code else { return }
    
    let urlString = "\(SDK.accessToken.api)?appid=\(self.appID)&secret=\(self.appSecret)&code=\(code)&grant_type=authorization_code"
    guard let url = URL(string: urlString) else { return }
    let dataTask =  URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
      
      var isSuccess: Bool = false
      
      //返回时进行回调
      defer {
        
        completeHandle(isSuccess)
      }
      
      guard let data = data else { return }
      guard let reusltJson = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else { return }
      guard let result = reusltJson as? [String : Any] else { return }
      
      //如果没有获取到AccessToken及OpenID，则直接返回
      guard let accessToken = result["access_token"] as? String else { return }
      guard let openID = result["refresh_token"] as? String else { return }
      
      self.access_token = accessToken
      self.expires_in  = result["expires_in"] as? String
      self.refresh_token = openID
      self.openid = result["openid"] as? String
      self.scope = result["scope"] as? String
      self.user.unionid = result["unionid"] as? String
      
      #if DEBUG
        print("WXAccessToken:\n\(result)")
      #endif
      
      isSuccess = true
      
    }
    dataTask.resume()
    
  }
  
  /// 刷新AccessToken
  func refreshAccessToken(_ completeHandle: @escaping CompleteHandle) {
    
    guard let refreshToken = self.refresh_token else { return }
    let urlString = "\(SDK.refreshAccessToken.api)?appid=\(self.appID)&refresh_token=\(refreshToken)&grant_type=refresh_token"
    guard let url = URL(string: urlString) else { return }
    let dataTask =  URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
      
      var isSuccess: Bool = false
      
      //返回时进行回调
      defer {
        
        completeHandle(isSuccess)
      }
      
      guard let data = data else { return }
      guard let reusltJson = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else { return }
      guard let result = reusltJson as? [String : Any] else { return }
      
      self.access_token = result["access_token"] as? String
      self.expires_in  = result["expires_in"] as? String
      self.refresh_token = result["refresh_token"] as? String
      self.openid = result["openid"] as? String
      self.scope = result["scope"] as? String
      
      #if DEBUG
        print("WX**********RefreshAccessToken:\(result)")
      #endif
      isSuccess = true
      
    }
    dataTask.resume()
    
  }
  
  /// 获取用户信息
  func getUserInfo(_ completeHandle: @escaping CompleteHandle) {
    
    guard let accessToken = self.access_token else { return }
    guard let openID = self.openid else { return }
    let urlString = "\(SDK.userInfo.api)?access_token=\(accessToken)&openid=\(openID)"
    guard let url = URL(string: urlString) else { return }
    
    #if DEBUG
      print(url)
    #endif
    
    let dataTask =  URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
      
      var isSuccess: Bool = false
      
      //返回时进行回调
      defer {
        
        completeHandle(isSuccess)
      }
      
      guard let data = data else { return }
      guard let reusltJson = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else { return }
      guard let result = reusltJson as? [String : Any] else { return }
      
      #if DEBUG
        print("WX**********UserInfo:\(result)")
      #endif
      
      self.openid = result["openid"] as? String
      
      self.user.unionid = result["unionid"] as? String
      self.user.nickname = result["nickname"] as? String
      self.user.sex = result["sex"] as? Int ?? 0
      self.user.province = result["province"] as? String
      self.user.city = result["city"] as? String
      self.user.country = result["country"] as? String
      self.user.headimgurl = result["headimgurl"] as? String
      self.user.privilege = result["privilege"] as? [String]
      
      isSuccess = true
      
    }
    dataTask.resume()
  }
}





