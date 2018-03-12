//
//  OpenManager+Pay.swift
//  OpenKit
//
//  Created by William Lee on 09/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

// MARK: - Pay
public extension OpenManager {
  
  typealias PayHandle = (_ isSuccess: Bool, _ message: String?) -> Void
  
  /// 进行支付操作
  ///
  /// - Parameters:
  ///   - item: 根据OpenPayItem不同初始化方法，自动判断不同的支付方式
  ///   - handle: 支付结果回调
  class func pay(with item: OpenPayItem, handle: @escaping PayHandle) {
    
    switch item.type {
    case .weChat:
      
      let item = item.weChatItem
      WeChatManager.pay(with: item, handle: { (isSuccess, message) in
        
        handle(isSuccess, message)
      })
    
    case .alipay:
      
      AlipayManager.pay(with: item.alipayItem, handle: { (isSuccess, message) in
        
        handle(isSuccess, message)
      })
      break
    }
    
  }
  
}
