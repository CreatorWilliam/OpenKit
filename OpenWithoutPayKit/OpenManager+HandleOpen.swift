//
//  OpenManager+HandleOpen.swift
//  OpenWithoutPayKit
//
//  Created by William Lee on 2018/11/12.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// MARK: - HandleOpen
public extension OpenManager {
  
  /// 开放平台唤起应用时回调
  ///
  /// - Parameter url: 回调地址
  /// - Returns: 是否可以回调
  class func handleOpen(_ url: URL) -> Bool {
    
    return WeChatManager.handleOpen(url) ||
           SinaWeiboManager.handleOpen(url) ||
           QQManager.handleOpen(url)
  }
  
}
