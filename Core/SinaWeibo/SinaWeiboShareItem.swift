//
//  SinaWeiboShareItem.swift
//  OpenKit
//
//  Created by William Lee on 09/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

internal struct SinaWeiboShareItem {
  
  /// 标题, 长度不能超过512字节
  var title: String = ""
  
  /// 消息的文本内容 长度小于2000个汉字
  var content: String = ""
  
  /// 网页的url地址, 不能为空且长度不能超过10K
  var link: String = ""
  
  /// 缩略图, 图片真实数据内容 大小不能超过10M
  var image: Data = Data()
  
}
