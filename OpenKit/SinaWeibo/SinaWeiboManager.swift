//
//  SinaWeiboManager.swift
//  OpenKit
//
//  Created by William Lee on 09/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public class SinaWeiboManager: NSObject {
  
  static let shared: SinaWeiboManager = SinaWeiboManager()
  
  fileprivate var authorizationHandle: SinaWeiboManager.AuthorizationHandle?
  fileprivate var shareHandle: SinaWeiboManager.ShareHandle?
  
  fileprivate var appID: String = ""
  fileprivate var appKey: String = ""
  fileprivate var redirectURI: String = ""
  
  fileprivate var accessToken: String?
  fileprivate var refreshToken: String?
  fileprivate var userID: String?
}

// MARK: - Required
public extension SinaWeiboManager {
  /// 注册SDK
  class func register(_ appID: String, _ appKey: String, _ redirectURI: String) {
    
    SinaWeiboManager.shared.appID = appID
    SinaWeiboManager.shared.appKey = appKey
    SinaWeiboManager.shared.redirectURI = redirectURI
    
    let code = WeiboSDK.registerApp(appID)
    #if DEBUG
      WeiboSDK.enableDebugMode(true)
      print(WeiboSDK.getVersion())
      print(code)
    #endif
  }
  
  /// SDK来操作打开URL
  class func handleOpen(_ url: URL) -> Bool {
    
    let code = WeiboSDK.handleOpen(url, delegate: SinaWeiboManager.shared)
    
    #if DEBUG
      print(code)
    #endif
    
    return code
  }
}

// MARK: - Optional
public extension SinaWeiboManager {
  
  /// 是否安装了新浪微博
  class func isInstall() -> Bool {
    
    return WeiboSDK.isWeiboAppInstalled()
  }
  
}

// MARK: - Authorization
internal extension SinaWeiboManager {
  
  /// 进行登陆授权
  typealias AuthorizationHandle = (_ user: SinaWeiboUserItem?, _ message: String) -> Void
  class func authorization(handle: @escaping AuthorizationHandle) {
    
    let request = WBAuthorizeRequest()
    request.redirectURI = SinaWeiboManager.shared.redirectURI
    request.scope = "all"
    WeiboSDK.send(request)
  }
}

// MARK: - Share
internal extension SinaWeiboManager {
  
  typealias ShareHandle = (_ isSuccess: Bool, _ message: String) -> Void
  class func share(with item: SinaWeiboShareItem, handle: @escaping ShareHandle) {
    
    SinaWeiboManager.shared.shareHandle = handle
    
    let authorizeRequest = WBAuthorizeRequest()
    authorizeRequest.redirectURI = SinaWeiboManager.shared.redirectURI
    authorizeRequest.scope = "all"
    
    let object = WBMessageObject()
    object.text = item.content + item.link
    
    let imageObject = WBImageObject()
    imageObject.imageData = item.image
    object.imageObject = imageObject
    
    let request = WBSendMessageToWeiboRequest.request(withMessage: object, authInfo: authorizeRequest, access_token: SinaWeiboManager.shared.accessToken) as? WBSendMessageToWeiboRequest
    request?.userInfo = ["ShareMessageFrom" : "SendMessageToWeiboViewController",
                         "Other_Info_1": 123, "Other_Info_2": ["obj1", "obj2"], "Other_Info_3": ["key1": "obj1", "key2": "obj2"]]
    let code = WeiboSDK.send(request)
    #if DEBUG
      print(code)
    #endif
  }
  
}

// MARK: - WeiboSDKDelegate
extension SinaWeiboManager: WeiboSDKDelegate {
  
  public func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
    
  }
  
  public func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
    
    #if DEBUG
      print(response)
    #endif
    
    if response.isKind(of: WBSendMessageToWeiboResponse.self) {
      
      //Share
      guard let response = response as? WBSendMessageToWeiboResponse else { return }
      self.handleSendMessageResponse(response)
      
    }
    else if response.isKind(of: WBAuthorizeResponse.self) {
      
      //Authorize
      guard let response = response as? WBAuthorizeResponse else { return }
      self.handleSendAuthorizationResponse(response)
      
    }
    else {
      
      //Nothing
    }
    
  }
  
}

// MARK: - WBHttpRequestDelegate
extension SinaWeiboManager: WBHttpRequestDelegate {
  
  public func request(_ request: WBHttpRequest!, didFinishLoadingWithDataResult data: Data!) {
    
    if request.url == APIPath.userInfo.rawValue {
      
      guard let data = data else {
        
        self.authorizationHandle?(nil, "授权失败")
        return
      }
      guard let reusltJson = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
        
        self.authorizationHandle?(nil, "授权失败")
        return
      }
      guard let result = reusltJson as? [String : Any] else {
        
        self.authorizationHandle?(nil, "授权失败")
        return
      }
      
      #if DEBUG
        print("SinaWB**********UserInfo:\(result)")
      #endif
      
      var user: SinaWeiboUserItem = SinaWeiboUserItem()
      user.id = result["idstr"] as? String
      user.avatar = result["avatar_hd"] as? String
      if let gender = result["gender"] as? String {
        
        switch gender {
        case "m":
          
          user.gender = 1
          
        case "f":
          
          user.gender = 2
        default:
          break
        }
      }
      user.nickname = result["screen_name"] as? String
      
      self.authorizationHandle?(user, "获取用户数据成功")
    }
  }
  
  public func request(_ request: WBHttpRequest!, didFailWithError error: Error!) {
    
    if request.url == APIPath.userInfo.rawValue {
      
      self.authorizationHandle?(nil, "授权失败")
    }
    #if DEBUG
      print(request.url, error.localizedDescription)
    #endif
  }
  
}

// MARK: - Handle
fileprivate extension SinaWeiboManager {
  
  func handleSendMessageResponse(_ response: WBSendMessageToWeiboResponse) {
    
    switch response.statusCode {
    case .success:
      
      self.shareHandle?(true, "分享成功")
      
    case .userCancel:
      
      self.shareHandle?(false, "取消分享")
      return
      
    default:
      
      self.shareHandle?(false, "分享失败")
      return
    }
    
    //      self.accessToken = response.authResponse.accessToken
    //      self.userID = response.authResponse.userID
  }
  
  func handleSendAuthorizationResponse(_ response: WBAuthorizeResponse) {
    
    switch response.statusCode {
    case .success:
      
      self.accessToken = response.accessToken
      self.userID = response.userID
      self.refreshToken = response.refreshToken
      
      var parameters: [String : String] = [:]
      parameters["uid"] = self.userID
      parameters["access_token"] = self.accessToken
      
      let _ = WBHttpRequest(url: APIPath.userInfo.rawValue, httpMethod: "GET", params: parameters, delegate: self, withTag: "Login")
      
      return
    case .userCancel:
      
      self.authorizationHandle?(nil, "用户取消授权登陆")
      return
      
    default:
      
      self.authorizationHandle?(nil, "用户授权登陆失败")
      return
    }
  }
  
}

// MARK: - Utility
fileprivate extension SinaWeiboManager {
  
  enum APIPath: String {
    
    case userInfo = "https://api.weibo.com/2/users/show.json"
    
  }
  
}







