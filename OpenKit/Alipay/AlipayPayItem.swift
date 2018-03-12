//
//  AlipayPayItem.swift
//  OpenKit
//
//  Created by William Lee on 12/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

struct AlipayPayItem {
  
  /// 支付请求参数字符串，主要包含商户的订单信息，key=value形式，以&连接
  var order: String = ""
  
}
