//
//  OpenAuthorizationItem.swift
//  OpenKit
//
//  Created by William Lee on 09/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct OpenAuthorizationItem {
  
  /// 授权类型
  public let type: OpenAuthorizationType
  /// 授权结果消息
  public let message: String?
  
  /// 用户唯一ID
  public let id: String?
  /// 昵称
  public let nickname: String?
  /// 头像
  public let avatar: String?
  /// 性别
  public let gender: OpenAuthorizationItem.Gender
  /// 手机
  public let phone: String?
  
  private init() {
    
    self.type = .none
    self.message = nil
    self.id = nil
    self.nickname = nil
    self.avatar = nil
    self.phone = nil
    self.gender = .unkown
  }
  
}

public extension OpenAuthorizationItem {
  
  enum Gender {
    
    /// 男
    case male
    /// 女
    case female
    
    /// 未知
    case unkown
  }
  
  enum OpenAuthorizationType {
    
    /// 微信授权登陆
    case weChat
    /// 新浪微博授权登陆
    case sinaWeibo
    /// QQ授权登陆
    case qq
    
    /// 未设置授权模式
    case none
  }
  
}

internal extension OpenAuthorizationItem {
  
  init(_ item: WeChatUserItem?, _ message: String?) {
    
    self.type = .weChat
    self.message = message
    
    self.id = item?.unionid
    self.nickname = item?.nickname
    self.avatar = item?.headimgurl
    self.phone = item?.phone
    
    if item?.sex == 1 {
      
      self.gender = .male
      
    } else if item?.sex == 2 {
      
      self.gender = .female
      
    } else {
      
      self.gender = .unkown
    }
  }
  
  init(_ item: SinaWeiboUserItem?, _ message: String?) {
   
    self.type = .sinaWeibo
    self.message = message
    
    self.id = item?.id
    self.nickname = item?.nickname
    self.avatar = item?.avatar
    self.phone = item?.phone
    
    if item?.gender == 1 {
      
      self.gender = .male
      
    } else if item?.gender == 2 {
      
      self.gender = .female
      
    } else {
      
      self.gender = .unkown
    }
  }
  
  init(_ item: QQUserItem?, _ message: String?) {
    
    self.type = .qq
    self.message = message
    
    self.id = item?.id
    self.nickname = item?.nickname
    self.avatar = item?.avatar
    self.phone = item?.phone
    
    if item?.gender == 1 {
      
      self.gender = .male
      
    } else if item?.gender == 2 {
      
      self.gender = .female
      
    } else {
      
      self.gender = .unkown
    }
  }
  
}














