//
//  OpenManager+Pay.swift
//  OpenKit
//
//  Created by William Lee on 2018/11/12.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public extension OpenManager {
  
  enum PayType {
    
    /// 支付宝支付
    case alipay
    /// 微信支付
    case wechat
    
    case unknow
  }
  
  typealias PayHandle = (_ isSuccess: Bool, _ message: String) -> Void
  
  static func pay(withType type: PayType, parameters: [String : Any], handle: @escaping PayHandle) {
    
    switch type {
//    case .wechat:
//
//      var item = WeChatPayItem()
//
//      item.resultCode = parameters["resultCode"] as? String ?? ""
//      item.returnCode = parameters["returnCode"] as? String ?? ""
//      item.partnerId = parameters["partnerId"] as? String ?? ""
//      item.package = parameters["package"] as? String ?? ""
//      item.sign = parameters["paySign"] as? String ?? ""
//      item.prepayId = parameters["prepayId"] as? String ?? ""
//      item.nonceStr = parameters["nonceStr"] as? String ?? ""
//      item.timeStamp = UInt32(parameters["timestamp"] as? String ?? "0") ?? 0
//
//      WeChatManager.pay(with: item, handle: { handle($0, $1) })
      
    case .alipay:
      
      var item = AlipayPayItem()
      
      item.order = parameters["response"] as? String ?? ""
      
      AlipayManager.pay(with: item, handle: { handle($0, $1) })
      
    default: return
    }
    
  }
  
}
