//
//  AlipayPayItem.swift
//  OpenWithPayKit
//
//  Created by William Lee on 2018/11/12.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct AlipayPayItem {
  
  /// 支付请求参数字符串，主要包含商户的订单信息，key=value形式，以&连接
  public var order: String = ""
  
}
