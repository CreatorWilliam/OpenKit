//
//  AlipayManger.swift
//  OpenKit
//
//  Created by William Lee on 12/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import OtherKit

class AlipayManager {
  
  static var shared: AlipayManager = AlipayManager()
  
  fileprivate var payHandle: AlipayManager.PayHandle?
  
  /// 在info.plist注册的scheme
  fileprivate var scheme: String = ""
}

// MARK: - Required
extension AlipayManager {
  
  /// 注册支付宝开放平台SDK
  ///
  /// - Parameter scheme: 调用支付的app注册在info.plist中的scheme，用于回调唤起应用
  class func register(_ scheme: String) {
    
    AlipayManager.shared.scheme = scheme
  }
  
  /// 通知SDK是否响应打开URL
  class func handleOpen(_ url: URL) -> Bool {
    
    guard url.host == "safepay" else { return false }
    
    AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (result) in
      
      AlipayManager.shared.handlePayResponse(result as? [String : Any])
    })
    return true
  }
  
}

// MARK: - Pay
extension AlipayManager {
  
  typealias PayHandle = (_ isSuccess: Bool, _ message: String) -> Void
  class func pay(with orderItem: AlipayPayItem, handle: @escaping AlipayManager.PayHandle) {
    
    AlipayManager.shared.payHandle = handle
    AlipaySDK.defaultService().payOrder(orderItem.order, fromScheme: AlipayManager.shared.scheme, callback: { (result) in
      
      AlipayManager.shared.handlePayResponse(result as? [String : Any])
    })
    
  }
  
}

// MARK: - Handle
extension AlipayManager {
  
  func handlePayResponse(_ response: [String : Any]?) {
    
    print(response ?? [:])
    if let _ = response {
      
      self.payHandle?(true, "")
      return
    }
    self.payHandle?(false, "数据异常")
  }
  
}


