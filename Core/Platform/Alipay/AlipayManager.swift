//
//  AlipayManager.swift
//  OpenWithPayKit
//
//  Created by William Lee on 2018/11/12.
//  Copyright © 2018 William Lee. All rights reserved.
//

import OtherKit

class AlipayManager {
  
  static let shared: AlipayManager = AlipayManager()
  
  var payHandle: PayHandle?
  
  private static let appID: String = ""
  
  /// 在info.plist注册的scheme
  private static let scheme: String = ""
}

// MARK: - Required
extension AlipayManager {
  
  /// 通知SDK是否响应打开URL
  static func handleOpen(_ url: URL) -> Bool {
    
    guard url.host == "safepay" else { return false }
    
    AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (result) in
      
      guard let result = result as? [String : Any] else { return }
      AlipayManager.shared.handlePayResponse(result)
    })
    return true
  }
  
}

// MARK: - Pay
extension AlipayManager {
  
  typealias PayHandle = (_ isSuccess: Bool, _ message: String) -> Void
  static func pay(with item: AlipayPayItem,
                  handle: @escaping PayHandle) {
    
    AlipayManager.shared.payHandle = handle
    AlipaySDK.defaultService().payOrder(item.order, fromScheme: AlipayManager.scheme, callback: { (result) in
      
      let result = result as? [String: Any] ?? [:]
      AlipayManager.shared.handlePayResponse(result)
    })
    
  }
  
}

// MARK: - Handle
extension AlipayManager {
  
  func handlePayResponse(_ response: [String : Any]) {
    
    /*
     9000  订单支付成功
     8000  正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
     4000  订单支付失败
     5000  重复请求
     6001  用户中途取消
     6002  网络连接出错
     6004  支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
     其它  其它支付错误
     */
    let code = response["resultStatus"] as? String ?? ""
    var message: String = ""
    var isSuccess: Bool = false
    switch code {
    case "9000":
      
      isSuccess = true
      message = "支付成功"
    case "4000": message = "支付失败"
    case "6001": message = "取消支付"
    case "6002": message = "网络异常，请稍后重试"
    default: message = "支付异常，状态码：\(code)"
    }
    self.payHandle?(isSuccess, message)
  }
  
}
