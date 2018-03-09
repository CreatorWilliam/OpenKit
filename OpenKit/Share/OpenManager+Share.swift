//
//  OpenManager+Share.swift
//  OpenKit
//
//  Created by William Lee on 09/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// MARK: - Share
public extension OpenManager {
  
  typealias ShareHandle = (_ isSuccess: Bool, _ message: String) -> Void
  
  /// 分享
  ///
  /// - Parameters:
  ///   - item: 要分享的内容
  ///   - type: 分享的类型
  ///   - handle: 分享结果回调
  class func share(with item: OpenShareItem, for type: OpenShareItem.ShareType, complet handle: @escaping ShareHandle) {
    
    switch type {
    case .wechatSession:
      
      WeChatManager.share(with: item.prepareForWeChat(), scene: .session, handle: { (isSuccess, message) in
        
        handle(isSuccess, message)
      })
      
    case .wechatTimeline:
      
      WeChatManager.share(with: item.prepareForWeChat(), scene: .timeline, handle: { (isSuccess, message) in
        
        handle(isSuccess, message)
      })
      
    case .sinaWeibo:
      
      SinaWeiboManager.share(with: item.prepareForSinaWeibo(), handle: { (isSuccess, message) in
      
        handle(isSuccess, message)
      })
    }
    
  }
  
}











