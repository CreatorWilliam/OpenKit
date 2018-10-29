//
//  OpenShareItem.swift
//  OpenKit
//
//  Created by William Lee on 09/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

public struct OpenShareItem {
  
  public var title: String?
  public var content: String?
  public var link: String?
  public var imageURL: URL?
  public var imageData: Data?
  public var image: UIImage?
  
  
  /// 初始化一个分享实体
  ///
  /// - Parameters:
  ///   - title: 分享的标题
  ///   - content: 分享的内容
  ///   - link: 链接
  ///   - image: 缩略图
  public init(_ title: String?, content: String?, link: String?, image: Any?) {
    
    self.update(title: title, content: content, link: link, image: image)
  }
  
  /// 更新一个分享实体的部分属性
  ///
  /// - Parameters:
  ///   - title: 分享的标题
  ///   - content: 分享的内容
  ///   - link: 链接
  ///   - image: 缩略图
  public mutating func update(title: String?, content: String?, link: String?, image: Any?) {
    
    if let title = title { self.title = title }
    
    if let content = content { self.content = content }
    
    if let link = link { self.link = link.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) }
    
    if let image = image as? UIImage {
      
      self.image = image
      self.redrawImage()
      
    } else if let data = image as? Data {
      
      self.convertToImage(with: data)
      
    } else if let url = image as? URL {
      
      self.convertToImage(with: url)
      
    } else if let urlString = image as? String {
      
      self.convertToImage(with: urlString)
      
    } else {
      
      return
    }
    
  }
  
}

public extension OpenShareItem {
  
  enum ShareType: String {
    
    /// 分享到微信朋友圈
    case wechatTimeline
    /// 分享给微信好友
    case wechatSession
    
    /// 分享给QQ好友
    case qqFriends
    
    /// 新浪微博
    case sinaWeibo
  }
  
}


internal extension OpenShareItem {
  
  func prepareForWeChat() -> WeChatShareItem {
    
    var item = WeChatShareItem()
    
    if let title = self.title {
      
      item.title = title
      
    } else {
      
      #if DEBUG
        print("标题为空")
      #endif
    }
    
    if let content = self.content {
      
      item.content = content
      
    } else {
      
      #if DEBUG
        print("描述为空")
      #endif
    }
    
    if let link = self.link {
      
      item.link = link
      
    } else {
      
      #if DEBUG
        print("链接为空")
      #endif
    }
    
    if let image = self.image {
      
      item.image = image
      
    } else {
      
      #if DEBUG
      print("缩略图为空")
      #endif
    }
    
    return item
  }
  
  func prepareForSinaWeibo() -> SinaWeiboShareItem {
    
    var item = SinaWeiboShareItem()
    
    if let title = self.title {
      
      item.title = title
      
    } else {
      
      #if DEBUG
        print("标题为空")
      #endif
    }
    
    if let content = self.content {
      
      item.content = content
      
    } else {
      
      #if DEBUG
        print("描述为空")
      #endif
    }
    
    if let link = self.link {
      
      item.link = link
      
    } else {
      
      #if DEBUG
        print("链接为空")
      #endif
    }
    
    item.image = self.imageData ?? Data()
    
    return item
  }
  
  func prepareForQQ() -> QQShareItem {
    
    var item = QQShareItem()
    
    if let title = self.title {
      
      item.title = title
      
    } else {
      
      #if DEBUG
        print("标题为空")
      #endif
    }
    
    if let content = self.content {
      
      item.content = content
      
    } else {
      
      #if DEBUG
        print("描述为空")
      #endif
    }
    
    if let link = self.link {
      
      item.link = link
      
    } else {
      
      #if DEBUG
        print("链接为空")
      #endif
    }
    
    item.image = self.imageData ?? Data()
    
    return item
  }
  
}

private extension OpenShareItem {
  
  /// String -> UIImage
  mutating func convertToImage(with string: String) {
    
    guard let url = URL(string: string) else { return }
    self.convertToImage(with: url)
  }
  
  /// URL -> UIImage
  mutating func convertToImage(with url: URL) {
    
    self.imageURL = url
    guard let data = try? Data(contentsOf: url) else { return }
    self.convertToImage(with: data)
  }
  
  /// Data -> UIImage
  mutating func convertToImage(with data: Data) {

    self.imageData = data
    self.image = UIImage(data: data)
    self.redrawImage()
  }
  
  /// Any Size -> 100 * 100
  mutating func redrawImage() {
    
    let rect: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)
    
    UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
    self.image?.draw(in: rect)
    self.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    if let image = self.image {
      
      self.imageData = image.jpegData(compressionQuality: 0.9)
    }
  }
  
}









