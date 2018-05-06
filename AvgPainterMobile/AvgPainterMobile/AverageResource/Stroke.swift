

import UIKit
import Foundation

class Stroke {
  var m_orgPt : [CGPoint]
  var m_SplinePt: [CGPoint]
  var m_FourierSeriesPt : [CGPoint]
  var m_Fourier : Fourier
  var m_bFourier : Bool
  var m_colorR = 0, m_colorG = 0, m_colorB = 0;
  var m_weight = 5;
  var m_iAppropriateDegreeOfFourier: Int
  
  init(m_orgPt _point: [CGPoint]){
    m_orgPt = []
    m_SplinePt = []
    for i in 0..<_point.count {
      m_orgPt.append( CGPoint(x: _point[i].x, y: _point[i].y) )
      m_SplinePt.append( CGPoint(x: _point[i].x, y: _point[i].y) )
    }
    m_FourierSeriesPt = []
    m_Fourier = Fourier()
    m_iAppropriateDegreeOfFourier = 0
    m_bFourier = false
  }
  
  init( _iSize: Int ) {
    m_orgPt = [CGPoint](repeating: CGPoint(x:0.0, y:0.0), count: _iSize)
    m_SplinePt = [CGPoint](repeating: CGPoint(x:0.0, y:0.0), count: _iSize)
    m_FourierSeriesPt = []
    m_Fourier = Fourier( _iDegree: min(_iSize/2, g_iMaxDegreeOfFourier) )
    m_iAppropriateDegreeOfFourier = 0
    m_bFourier = false
  }
  
  func setColor(_r : Int, _g : Int, _b : Int){
    m_colorR = _r
    m_colorG = _g
    m_colorB = _b
  }
  
  func setWeight( _w : Int ){
    m_weight = _w
  }
  
  func printXY(){
    for i in 0..<m_orgPt.count {
      print(m_orgPt[i])
    }
  }
  
  func displayStroke(context: CGContext){
    UIGraphicsPushContext(context)
    for t in 0..<m_orgPt.count-1  {
      context.move(to: CGPoint(x: m_orgPt[t].x, y: m_orgPt[t].y))
      context.addLine(to: CGPoint(x: m_orgPt[t+1].x, y: m_orgPt[t+1].y))
    }
    
    context.setStrokeColor(red: CGFloat(m_colorR), green: CGFloat(m_colorG), blue: CGFloat(m_colorB), alpha: 1) //線の色
    context.setLineWidth(CGFloat(m_weight) )  //線の太さ
    context.setLineCap( CGLineCap.round )   //線を滑らかに
    context.strokePath()
    UIGraphicsPopContext()
  }
  
  func doSpline(){
    var arrayT :[CGFloat] = [CGFloat](repeating: 0.0, count: m_orgPt.count)
    for j in 0..<m_orgPt.count {
      arrayT[j] = CGFloat(CGFloat(j)*CGFloat(M_PI)/CGFloat(m_orgPt.count-1))
    }
  }
  
  func doFourier(){
    if( m_bFourier ){
      
    }
  }
  
  func displayAverage(context: CGContext) {
    UIGraphicsPushContext(context)
    m_iAppropriateDegreeOfFourier = m_Fourier.GetAppropriateDegree( _iMaxDegree: g_iMaxDegreeOfFourier, _iNumOfP: m_SplinePt.count, _fThresholdF: g_fThresholdOfCoefficient );
    //print( "appropriate degree \(m_iAppropriateDegreeOfFourier)" );
    m_FourierSeriesPt = m_Fourier.GetFourierSeries( _iDegree: m_iAppropriateDegreeOfFourier, _iNumOfPoints: m_SplinePt.count, _fThresholdForCals: g_fThresholdOfCoefficient );
    context.setStrokeColor(red: CGFloat(m_colorR), green: CGFloat(m_colorG), blue: CGFloat(m_colorB), alpha: 1) //線の色
    context.setLineWidth(CGFloat(m_weight) )  //線の太さ
    context.setLineCap( CGLineCap.round )   //線を滑らかに
    var lx = 0.0;
    var ly = 0.0;
    for num in 0..<m_FourierSeriesPt.count/2-1 {
      context.move(to: CGPoint(x:m_FourierSeriesPt[num].x+0.5, y:m_FourierSeriesPt[num].y+0.5))
      context.addLine(to: CGPoint(x:m_FourierSeriesPt[num+1].x+0.5, y:m_FourierSeriesPt[num+1].y+0.5))
    }
    m_Fourier.ShowEquations(_iNumOfDegree: m_iAppropriateDegreeOfFourier, _fThreshold: g_fThresholdOfCoefficient);
    context.strokePath()
    UIGraphicsPopContext()
  }
  
  
}


