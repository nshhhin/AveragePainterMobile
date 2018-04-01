//
//  SubModule.swift
//  AvgPainterMobile
//
//  Created by 新納真次郎 on 2018/04/01.
//  Copyright © 2018年 nshhhin. All rights reserved.
//

import Foundation
import UIKit


// UIViewに親のVCを呼ぶための機能をつける
// 参考: https://qiita.com/k-yamada-github/items/5c5fe08717251481e91b
extension UIView {
  func parentViewController() -> UIViewController? {
    var parentResponder: UIResponder? = self
    while true {
      guard let nextResponder = parentResponder?.next else { return nil }
      if let viewController = nextResponder as? UIViewController {
        return viewController
      }
      parentResponder = nextResponder
    }
  }
}
