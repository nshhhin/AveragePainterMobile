//
//  DrawingViewController.swift
//  AvgPainterMobile
//
//  Created by 新納真次郎 on 2018/03/05.
//  Copyright © 2018年 nshhhin. All rights reserved.
//

import UIKit

class DrawingView: UIImageView {
  
  let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
  
  var penColor: UIColor! = UIColor.black
  var penSize: CGFloat = 6
  private var path: UIBezierPath!
  private var lastDrawImage: UIImage?
  
  private var temporaryPath: UIBezierPath!
  private var points = [CGPoint]() // ベジェーの時に必要なポイント(動的に変更を行なっている)
  private var orgPts = [CGPoint]() // シンプルな点列のみを格納するポイント(静的)
  
  private var pointCount = 0
  private var snapshotImage: UIImage?
  
  private var isCallTouchMoved = false
  
  private var images: [UIImage?] = []
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    isUserInteractionEnabled = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    isUserInteractionEnabled = true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    let bEraserMode = appDelegate.bEraserMode
    penSize = appDelegate.selectedStrokeWeight
    
    if( !bEraserMode ){
      penColor = appDelegate.selectedColor
      
      let currentPoint = touches.first!.location(in: self)
      path = UIBezierPath()
      path?.lineWidth = penSize
      path?.lineCapStyle = CGLineCap.round
      path?.lineJoinStyle = CGLineJoin.round
      path?.move(to: currentPoint)
      points = [currentPoint]
      orgPts = [currentPoint]
      pointCount = 0
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    let bEraserMode = appDelegate.bEraserMode
    
    if( !bEraserMode ){
      isCallTouchMoved = true
      pointCount += 1
      let currentPoint = touches.first!.location(in: self)
      points.append(currentPoint)
      orgPts.append(currentPoint)
      print(pointCount, currentPoint)
      
      if points.count == 2 {
        temporaryPath = UIBezierPath()
        temporaryPath?.lineWidth = penSize
        temporaryPath?.lineCapStyle = .round
        temporaryPath?.lineJoinStyle = .round
        temporaryPath?.move(to: points[0])
        temporaryPath?.addLine(to: points[1])
        image = drawLine()
      }else if points.count == 3 {
        temporaryPath = UIBezierPath()
        temporaryPath?.lineWidth = penSize
        temporaryPath?.lineCapStyle = .round
        temporaryPath?.lineJoinStyle = .round
        temporaryPath?.move(to: points[0])
        temporaryPath?.addQuadCurve(to: points[2], controlPoint: points[1])
        image = drawLine()
      }else if points.count == 4 {
        temporaryPath = UIBezierPath()
        temporaryPath?.lineWidth = penSize
        temporaryPath?.lineCapStyle = .round
        temporaryPath?.lineJoinStyle = .round
        temporaryPath?.move(to: points[0])
        temporaryPath?.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
        image = drawLine()
      }else if points.count == 5 {
        points[3] = CGPoint(x: (points[2].x + points[4].x) * 0.5, y: (points[2].y + points[4].y) * 0.5)
        if points[4] != points[3] {
          let length = hypot(points[4].x - points[3].x, points[4].y - points[3].y) / 2.0
          let angle = atan2(points[3].y - points[2].y, points[4].x - points[3].x)
          let controlPoint = CGPoint(x: points[3].x + cos(angle) * length, y: points[3].y + sin(angle) * length)
          temporaryPath = UIBezierPath()
          temporaryPath?.move(to: points[3])
          temporaryPath?.lineWidth = penSize
          temporaryPath?.lineCapStyle = .round
          temporaryPath?.lineJoinStyle = .round
          temporaryPath?.addQuadCurve(to: points[4], controlPoint: controlPoint)
        } else {
          temporaryPath = nil
        }
        path?.move(to: points[0])
        path?.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
        points = [points[3], points[4]]
        image = drawLine()
      }
      if pointCount > 50 {
        temporaryPath = nil
        snapshotImage = drawLine()
        path.removeAllPoints()
        pointCount = 0
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    let bEraserMode = appDelegate.bEraserMode
    
    if( !bEraserMode ){
      let currentPoint = touches.first!.location(in: self)
      orgPts.append( currentPoint )
      print( type(of: currentPoint) )
      if !isCallTouchMoved { path?.addLine(to: currentPoint) }
      image = drawLine()
      images.append( image )
      lastDrawImage = image
      temporaryPath = nil
      snapshotImage = nil
      isCallTouchMoved = false
    }
    
    print("=============")
    let st = Stroke(m_orgPt: orgPts)
    displayStroke( st )
    print("おわたよ")
  }
  
  func drawLine() -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
    if snapshotImage != nil {
      snapshotImage?.draw(at: CGPoint.zero)
    }else {
      lastDrawImage?.draw(at: CGPoint.zero)
    }
    penColor.setStroke()
    path?.stroke()
    temporaryPath?.stroke()
    let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return capturedImage
  }
  
  func clear(){
    image = nil
    path = nil
    images = []
    lastDrawImage = nil
    temporaryPath = nil
    points = []
    pointCount = 0
    snapshotImage = nil
    isCallTouchMoved = false
  }
  
  func undo(){
    if( images.count > 1 ){
      images.removeLast()
      image = images[images.count-1]
      lastDrawImage = image
    }
    else{
      clear()
    }
  }
  
  func save(){
    // キャンバスを画像化して保存
    // 参考: https://joyplot.com/documents/2016/08/19/swiftでimageviewの画像をカメラロールに保存する/
    
    if( self.image != nil ){
      UIImageWriteToSavedPhotosAlbum( self.image!, self, #selector(self.showResultOfSaveImage(_:didFinishSavingWithError:contextInfo:)), nil)
      
      // 「保存しました」のダイアログ表示
      let alertController = UIAlertController(title: "保存しました", message: "Saved a picture.", preferredStyle: .alert)
      
      let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(defaultAction)
    }
  }
  
  // 保存を試みた結果をダイアログで表示
  @objc func showResultOfSaveImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
    
    var title = "保存完了"
    var message = "カメラロールに保存しました"
    
    if error != nil {
      title = "エラー"
      message = "保存に失敗しました"
    }
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    // OKボタンを追加
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    
    // 親ビューでUIAlertController を表示
    let canvasViewController = self.parentViewController()
    canvasViewController?.present(alert, animated: true, completion: nil)
    
  }
  
  func displayImage(_ img: UIImage){
    self.image = img
    self.images.append(img)
    self.lastDrawImage = img
    
  }
  
  func displayStroke(_ st: Stroke){
    let points: [CGPoint] = st.m_orgPt
    var bezierPts: [CGPoint] = []
    var tmp_pointCount = 0
    var tmp_isCallTouchMoved = false
    var tmp_snapShotImage: UIImage?
    var tmp_image: UIImage?
    
    // begin
    let _path = UIBezierPath()
    _path.lineWidth = penSize
    _path.lineCapStyle = CGLineCap.round
    _path.lineJoinStyle = CGLineJoin.round
    _path.move(to: points[0])
    bezierPts = [points[0]]
    
    // move
    
    for i in 1..<points.count-1 {
      tmp_isCallTouchMoved = true
      tmp_pointCount += 1
      bezierPts.append(points[i])
    
      if bezierPts.count == 2 {
        let _temporaryPath = UIBezierPath()
        _temporaryPath.lineWidth = penSize
        _temporaryPath.lineCapStyle = .round
        _temporaryPath.lineJoinStyle = .round
        _temporaryPath.move(to: bezierPts[0])
        _temporaryPath.addLine(to: bezierPts[1])
        tmp_image = drawLine()
      }else if bezierPts.count == 3 {
        let _temporaryPath = UIBezierPath()
        _temporaryPath.lineWidth = penSize
        _temporaryPath.lineCapStyle = .round
        _temporaryPath.lineJoinStyle = .round
        _temporaryPath.move(to: bezierPts[0])
        _temporaryPath.addQuadCurve(to: bezierPts[2], controlPoint: bezierPts[1])
        tmp_image = drawLine()
      }else if bezierPts.count == 4 {
        let _temporaryPath = UIBezierPath()
        _temporaryPath.lineWidth = penSize
        _temporaryPath.lineCapStyle = .round
        _temporaryPath.lineJoinStyle = .round
        _temporaryPath.move(to: bezierPts[0])
        _temporaryPath.addCurve(to: bezierPts[3], controlPoint1: bezierPts[1], controlPoint2: bezierPts[2])
        tmp_image = drawLine()
      }else if bezierPts.count == 5 {
        bezierPts[3] = CGPoint(x: (bezierPts[2].x + bezierPts[4].x) * 0.5, y: (bezierPts[2].y + bezierPts[4].y) * 0.5)
        if bezierPts[4] != bezierPts[3] {
          let length = hypot(bezierPts[4].x - bezierPts[3].x, bezierPts[4].y - bezierPts[3].y) / 2.0
          let angle = atan2(bezierPts[3].y - bezierPts[2].y, bezierPts[4].x - bezierPts[3].x)
          let controlPoint = CGPoint(x: bezierPts[3].x + cos(angle) * length, y: bezierPts[3].y + sin(angle) * length)
          let _temporaryPath = UIBezierPath()
          _temporaryPath.move(to: bezierPts[3])
          _temporaryPath.lineWidth = penSize
          _temporaryPath.lineCapStyle = .round
          _temporaryPath.lineJoinStyle = .round
          _temporaryPath.addQuadCurve(to: bezierPts[4], controlPoint: controlPoint)
        } else {
          temporaryPath = nil
        }
        _path.move(to: bezierPts[0])
        _path.addCurve(to: points[3], controlPoint1: bezierPts[1], controlPoint2: bezierPts[2])
        bezierPts = [bezierPts[3], bezierPts[4]]
        tmp_image = drawLine()
      }
      if tmp_pointCount > 50 {
        temporaryPath = nil
        tmp_snapShotImage = drawLine()
        _path.removeAllPoints()
        tmp_pointCount = 0
      }
    }
    
    // end
    if !tmp_isCallTouchMoved { _path.addLine(to: points.last!) }
    tmp_image = drawLine()
    temporaryPath = nil
    snapshotImage = nil
    isCallTouchMoved = false
    
    
    for point in points {
      print( point )
    }
  }
  
}
