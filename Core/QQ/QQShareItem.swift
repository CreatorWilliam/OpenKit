//
//  QQShareItem.swift
//  OpenKit
//
//  Created by William Lee on 13/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

internal struct QQShareItem {
  
  /// 标题, 长度不能超过512字节
  var title: String = ""
  
  /// 消息的文本内容 长度小于2000个汉字
  var content: String = ""
  
  /// <URL地址,必填，最长512个字符
  var link: String = ""
  
  /// <预览图像数据，最大1M字节
  var image: Data = Data()
  
}
