//
//  OpenPayItem.swift
//  OpenKit
//
//  Created by William Lee on 09/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct OpenPayItem {
  
  /// 支付类型
  internal let type: OpenPayItem.PayType
  
  /// 包含微信支付相关信息
  internal var weChatItem = WeChatPayItem()
  /// 包含支付宝支付相关信息
  internal var alipayItem = AlipayPayItem()
  
  /// 创建微信支付Item
  ///
  /// - Parameters:
  ///   - partnerId: 商家向财付通申请的商家id
  ///   - prepayId: 预支付订单
  ///   - nonceStr: 随机串，防重发
  ///   - timeStamp: 时间戳，防重发
  ///   - package: 商家根据财付通文档填写的数据和签名
  ///   - sign: 商家根据微信开放平台文档对数据做的签名
  public init(weChatWithPartnerId partnerId: String, prepayId: String, nonceStr: String, timeStamp: Int, package: String, sign: String) {
    
    self.type = .weChat
    
    self.weChatItem.partnerId = partnerId
    self.weChatItem.package = package
    self.weChatItem.sign = sign
    self.weChatItem.prepayId = prepayId
    self.weChatItem.nonceStr = nonceStr
    self.weChatItem.timeStamp = UInt32(timeStamp)
  }
  
  public init(alipayWithOrder string: String) {
    
    self.type = .alipay
    self.alipayItem.order = string
  }
  
}

internal extension OpenPayItem {
  
  enum PayType {
    
    /// 微信支付
    case weChat
    
    /// 支付宝
    case alipay
  }
  
}
