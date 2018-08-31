//
//  QQManager.swift
//  OpenKit
//
//  Created by William Lee on 13/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import OtherKit

internal class QQManager: NSObject {
  
  static let shared: QQManager = QQManager()
  
  private var authorizationHandle: QQManager.AuthorizationHandle?
  private var shareHandle: QQManager.ShareHandle?
  
  private var appID: String = ""
  private var appSecret: String = ""
  private var tencentOAuth: TencentOAuth?
  
}

// MARK: - Required
internal extension QQManager {
  
  /// 注册SDK
  class func register(_ appID: String, _ appSecret: String) {
    
    QQManager.shared.appID = appID
    QQManager.shared.appSecret = appSecret
    QQManager.shared.tencentOAuth = TencentOAuth(appId: appID, andDelegate: QQManager.shared)
  }
  
  /// SDK来操作打开URL
  class func handleOpen(_ url: URL) -> Bool {
    
    return TencentOAuth.handleOpen(url) || QQApiInterface.handleOpen(url, delegate: QQManager.shared)
  }
  
}

// MARK: - Optional
internal extension QQManager {
  
  /// 是否安装了QQ
  class func isInstallQQ() -> Bool {
    
    return TencentOAuth.iphoneQQInstalled()
  }
  
  /// 是否安装了TIM
  class func isInstallTIM() -> Bool {
    
    return TencentOAuth.iphoneTIMInstalled()
  }
}

// MARK: - Authorization
internal extension QQManager {
  
  typealias AuthorizationHandle = (_ user: QQUserItem?, _ message: String) -> Void
  class func authorization(handle: @escaping QQManager.AuthorizationHandle) {
    
    QQManager.shared.authorizationHandle = handle
    let permissions: [String] = [kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]
    QQManager.shared.tencentOAuth?.authorize(permissions)
  }
  
}

// MARK: - Share
internal extension QQManager {
  
  typealias ShareHandle = (_ isSuccess: Bool, _ message: String) -> Void
  class func share(with item: QQShareItem, handle: @escaping QQManager.ShareHandle) {
    
    QQManager.shared.shareHandle = handle
    
    guard let link = URL(string: item.link) else {
      
      QQManager.shared.shareHandle?(false, "分享的地址无效")
      return
    }

    let object = QQApiNewsObject(url: link, title: item.title, description: item.content, previewImageData: item.image, targetContentType: QQApiURLTargetTypeNews)
    let request = SendMessageToQQReq(content: object)
    
    let code = QQApiInterface.send(request)
    
    
    /*
     QQApiSendResultCode 说明
     EQQAPISENDSUCESS = 0,                      操作成功
     EQQAPIQQNOTINSTALLED = 1,                   没有安装QQ
     EQQAPIQQNOTSUPPORTAPI = 2,
     EQQAPIMESSAGETYPEINVALID = 3,              参数错误
     EQQAPIMESSAGECONTENTNULL = 4,
     EQQAPIMESSAGECONTENTINVALID = 5,
     EQQAPIAPPNOTREGISTED = 6,                   应用未注册
     EQQAPIAPPSHAREASYNC = 7,
     EQQAPIQQNOTSUPPORTAPI_WITH_ERRORSHOW = 8,
     EQQAPISENDFAILD = -1,                       发送失败
     //qzone分享不支持text类型分享
     EQQAPIQZONENOTSUPPORTTEXT = 10000,
     //qzone分享不支持image类型分享
     EQQAPIQZONENOTSUPPORTIMAGE = 10001,
     //当前QQ版本太低，需要更新至新版本才可以支持
     EQQAPIVERSIONNEEDUPDATE = 10002,
     */
    
    if code != EQQAPISENDSUCESS {
      
      QQManager.shared.shareHandle?(false, "分享失败")
      
    }
  }
  
}


// MARK: - QQApiInterfaceDelegate
extension QQManager: QQApiInterfaceDelegate {
  
  func onReq(_ req: QQBaseReq!) {
    
  }
  
  func onResp(_ resp: QQBaseResp!) {
    
    if resp.isKind(of: SendMessageToQQResp.self) {
      
      guard let response = resp as? SendMessageToQQResp else { return }
      self.handleSendMessageResponse(response)
    }
    
  }
  
  func isOnlineResponse(_ response: [AnyHashable : Any]!) {
    
  }
  
  
}

// MARK: - TencentSessionDelegate
extension QQManager: TencentSessionDelegate {
  
  func tencentDidLogin() {
    
    if self.tencentOAuth?.accessToken?.count ?? 0 > 0 {
      
      self.tencentOAuth?.getUserInfo()
      
    } else {
      
      self.authorizationHandle?(nil, "登陆失败")
    }
  }
  
  func tencentDidNotLogin(_ cancelled: Bool) {
    
    if cancelled {
      
      self.authorizationHandle?(nil, "用户取消登陆")
      
    } else {
      
      self.authorizationHandle?(nil, "登陆失败")
    }
  }
  
  func tencentDidNotNetWork() {
    
    self.authorizationHandle?(nil, "无网络连接，请设置网络")
  }
  
  func getUserInfoResponse(_ response: APIResponse!) {
    
    guard response.retCode == Int32(URLREQUEST_SUCCEED.rawValue) else {
      
      self.authorizationHandle?(nil, "获取用户信息失败")
      return
    }
    
    guard let userInfo = response.jsonResponse as? [String : Any] else {
      
      self.authorizationHandle?(nil, "获取用户信息失败")
      return
    }
    
    //登陆获取信息
    var user: QQUserItem = QQUserItem()
    user.id = self.tencentOAuth?.openId
    user.avatar = userInfo["figureurl_qq_2"] as? String ?? userInfo["figureurl_qq_1"] as? String ?? userInfo["figureurl_2"] as? String ?? userInfo["figureurl_1"] as? String ?? ""
    
    if let gender = userInfo["gender"] as? String {
      
      if gender == "男" {
        
        user.gender = 1
      }
      
      if gender == "女" {
        
        user.gender = 2
      }
    }
    user.nickname = userInfo["nickname"] as? String
    
    #if DEBUG
      print(userInfo)
    #endif
    self.authorizationHandle?(user, "获取用户数据成功")
  }
  
}

// MARK: - Handle
private extension QQManager {
  
  func handleSendMessageResponse(_ response: SendMessageToQQResp) {
    
    switch response.result {
      
    case "0": self.shareHandle?(true, "分享成功")
      
    case "-4": self.shareHandle?(false, "取消分享")
      
    default: self.shareHandle?(false, "分享失败")
    }
    
  }
  
}













