//
//  SinaWeiboUserItem.swift
//  OpenKit
//
//  Created by William Lee on 09/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct SinaWeiboUserItem {
  
  /// 当且仅当该移动应用已获得该用户的userinfo授权时，才会出现该字段，可用于用户唯一标识
  var id: String?
  /// 普通用户昵称
  var nickname: String?
  /// 普通用户性别，1为男性，2为女性
  var gender: Int = 0
  /// 普通用户个人资料填写的省份
  var province: String?
  /// 普通用户个人资料填写的城市
  var city: String?
  /// 国家，如中国为CN
  var country: String?
  ///用户头像，最后一个数值代表正方形头像大小（有0、46、64、96、132数值可选，0代表640*640正方形头像），用户没有头像时该项为空
  var avatar: String?
  /// 用户特权信息，json数组，如微信沃卡用户为（chinaunicom）
  var privilege: [String]?
  /// 手机号码
  var phone: String?
}

