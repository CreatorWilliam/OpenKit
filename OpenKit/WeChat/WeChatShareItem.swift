//
//  WeChatShareItem.swift
//  OpenKit
//
//  Created by William Lee on 09/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

internal struct WeChatShareItem {
  
  /// 标题, 长度不能超过512字节
  var title: String = ""
  
  /// 长度不能超过1K
  var content: String = ""
  
  /// 网页的url地址, 不能为空且长度不能超过10K
  var link: String = ""
  
  /// 缩略图, 大小不能超过32K
  var image: UIImage = UIImage()
  
}
