//
//  OpenManager+Authorization.swift
//  OpenKit
//
//  Created by William Lee on 09/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// MARK: - Authorization
public extension OpenManager {
  
  typealias AuthorizationHandle = (_ item: OpenAuthorizationItem) -> Void
  
  /// 授权
  ///
  /// - Parameters:
  ///   - type: 授权类型
  ///   - handle: 授权结果回调
  class func authorization(with type: OpenAuthorizationItem.OpenAuthorizationType, handle: @escaping AuthorizationHandle) {
    
    switch type {
    case .weChat:
      
      WeChatManager.authorization(handle: { (user, message) in
        
        handle(OpenAuthorizationItem(user, message))
      })
     
    case .sinaWeibo:
      
      SinaWeiboManager.authorization(handle: { (user, message) in
        
        handle(OpenAuthorizationItem(user, message))
      })
      
    case .qq:
      
      QQManager.authorization(handle: { (user, message) in
        
        handle(OpenAuthorizationItem(user, message))
      })
      
    default: break
      
    }
  }
  
}
