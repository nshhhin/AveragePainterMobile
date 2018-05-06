import UIKit
import Foundation

func dist(fisrtPoint a:CGPoint, secondPoint b:CGPoint) -> CGFloat {
  // 2点間の距離を求める関数
  let d = sqrt(pow((a.x-a.y),2)+pow((b.x-b.y),2));
  return d;
}

class Fourier {
  var m_aX : [CGFloat]! = [];   //xについてFourierSeriesの実部
  var m_bX : [CGFloat]! = [];   //xについてFourierSeriesの虚部
  var m_aY : [CGFloat]! = [];   //yについてFourierSeriesの実部
  var m_bY : [CGFloat]! = [];   //yについてFourierSeriesの虚部
  
  init() {
    m_aX = nil
    m_bX = nil
    m_aY = nil
    m_bY = nil
  }
  
  init( _iDegree : Int ) {
    Init( _iDegree: _iDegree )
  }
  
  // 初期化
  func Init( _iDegree : Int ) {
    m_aX = [CGFloat](repeating: 0.0, count: _iDegree+1)
    m_bX = [CGFloat](repeating: 0.0, count: _iDegree+1)
    m_aY = [CGFloat](repeating: 0.0, count: _iDegree+1)
    m_bY = [CGFloat](repeating: 0.0, count: _iDegree+1)
  }
  
  // フーリエ級数展開
  func ExpansionFourierSeries(  _arrayPt :[CGPoint], _iMaxDegree : Int ) {
    var k=0
    var n=0
    var _iNumOfUnit = _arrayPt.count
    
    m_aX = [CGFloat](repeating: 0.0, count: _iMaxDegree+1) // FourierSeriesの実部
    m_bX = [CGFloat](repeating: 0.0, count: _iMaxDegree+1) // FourierSeriesの虚部
    m_aY = [CGFloat](repeating: 0.0, count: _iMaxDegree+1) // FourierSeriesの実部
    m_bY = [CGFloat](repeating: 0.0, count: _iMaxDegree+1) // FourierSeriesの虚部
    print("num of unit" + String(_iNumOfUnit) + "\n" )
    
    
    // フーリエ級数展開の主たる部分
    for k in k..<min(_iMaxDegree, _iNumOfUnit/2)+1 {
      
      
      // xのk次についてフーリエ級数展開
      m_aX[k] = 0.0; // a_xk
      m_bX[k] = 0.0; // b_xk
      
      // yのk次についてフーリエ級数展開
      m_aY[k] = 0.0;
      m_bY[k] = 0.0;
      
      // -PI -> PI
      let pi = CGFloat.pi
      
      for n in 0..<_iNumOfUnit {
        var t : CGFloat
        t = ( 2.0 * pi * CGFloat(n) ) / ( CGFloat( _iNumOfUnit ) ) - pi
        m_aX[k] += (_arrayPt[n].x * cos( (CGFloat(k)) * (CGFloat(t)) ));
        m_bX[k] += _arrayPt[n].x * sin( (CGFloat(k)) * (CGFloat(t)) );
        
        m_aY[k] += _arrayPt[n].y * cos( (CGFloat(k)) * (CGFloat(t)) );
        m_bY[k] += _arrayPt[n].y * sin( (CGFloat(k)) * (CGFloat(t)) );
      }
      
      m_aX[k] = m_aX[k] * (2.0/(CGFloat(_iNumOfUnit)));
      m_bX[k] = m_bX[k] * (2.0/(CGFloat(_iNumOfUnit)));
      m_aY[k] = m_aY[k] * (2.0/(CGFloat(_iNumOfUnit)));
      m_bY[k] = m_bY[k] * (2.0/(CGFloat(_iNumOfUnit)));
    }
    m_aX[0] = m_aX[0]/2;
    m_aY[0] = m_aY[0]/2;
    m_bX[0] = m_bX[0]/2;
    m_bY[0] = m_bY[0]/2;
  }
  
  // 係数をまとめて設定する
  func SetCoefficientValue(  _faX :[CGFloat], _fbX :[CGFloat], _faY :[CGFloat], _fbY :[CGFloat] ) {
    m_aX = _faX;
    m_bX = _fbX;
    m_aY = _faY;
    m_bY = _fbY;
  }
  
  /************/
  // 適切な次数を求める（次数を上げ過ぎると拡大した時にウネウネするため）
  func GetAppropriateDegree( _iMaxDegree :Int , _iNumOfP :Int , _fThresholdF :CGFloat) -> Int {
    var now : [CGPoint]!
    var pre : [CGPoint]!
    
    
    let _start = 2;
    var iRetDegree = _start;
    
    // 次数を上げた時の変化を見ることで適切な次数を求める
    for l in _start..<_iMaxDegree+1 {
      var sumBetween :CGFloat = 0;
      now = GetFourierSeries( _iDegree: l , _iNumOfPoints: _iNumOfP, _fThresholdForCals: _fThresholdF );
      if ( pre != nil ) {
        for t in 0..<now!.count {
          let distance = dist(fisrtPoint: now![t], secondPoint: pre![t])
          sumBetween = sumBetween + distance
        }
        
        if ( 1 > (sumBetween / CGFloat(now!.count) )) {
          iRetDegree = l;
          break;
        }
        iRetDegree = l;
      }
      pre = now;
      now = nil;
    }
    return iRetDegree;
  }
  
  func GetFourierSeries( _iDegree : Int, _iNumOfPoints : Int, _fThresholdForCals : CGFloat ) -> [CGPoint] {
    // フーリエ級数展開を利用して求めた点列を取得する
    // ここに問題あり
    var _retPoints : [CGPoint] = []
    _retPoints = [CGPoint](repeating: CGPoint(x:0.0 , y:0.0), count: _iNumOfPoints)
    
    for i in 0..<_iNumOfPoints {
      var x :CGFloat = m_aX[0]
      var y :CGFloat = m_aY[0]
      let pi = CGFloat.pi
      
      for k in 1..<_iDegree+1 {
        let t = pi * CGFloat(i/_iNumOfPoints);
        if ( abs(m_aX[k]) > _fThresholdForCals ){ x = x + (m_aX[k] * cos( (CGFloat(k)) * (CGFloat(t)) )) }
        if ( abs(m_bX[k]) > _fThresholdForCals ){ x = x + (m_bX[k] * sin( (CGFloat(k)) * (CGFloat(t)) )) }
        if ( abs(m_aY[k]) > _fThresholdForCals ){ y = y + (m_aY[k] * cos( (CGFloat(k)) * (CGFloat(t)) )) }
        if ( abs(m_bY[k]) > _fThresholdForCals ){ y = y + (m_bY[k] * sin( (CGFloat(k)) * (CGFloat(t)) )) }
      }
      print( "\(x) , \(y)" )
      _retPoints[i] = CGPoint(x: x, y: y)
    }
    return _retPoints
  }
  
  func ShowEquations(  _iNumOfDegree : Int, _fThreshold : CGFloat) {
    
    // 単に数式を表示する
    print( "f(x,t) = " + "\n");
    
    let CGFloatValue: CGFloat = 32.642
    let strValue1: String = "\(CGFloatValue)" // "32.642"
    
    for i in 0..<_iNumOfDegree+1 {
      var s_aX : String = "\(m_aX[i])"
      var s_bX : String = "\(m_bX[i])"
      var s_aY : String = "\(m_aY[i])"
      var s_bY : String = "\(m_bY[i])"
      if ( abs(m_aX[i]) > _fThreshold ){ print( " + " + s_aX + " * Cos[" + String(i) + "t]" ) }
      if ( abs(m_bX[i]) > _fThreshold ){ print( " + " + s_bX + " * Sin[" + String(i) + "t]" ) }
      print();
    }
    print("\n");
    
    print( "f(y,t) = " + "\n");
    for i in 0..<_iNumOfDegree+1 {
      var s_aX : String = "\(m_aX[i])"
      var s_bX : String = "\(m_bX[i])"
      var s_aY : String = "\(m_aY[i])"
      var s_bY : String = "\(m_bY[i])"
      
      if ( abs(m_aY[i]) > _fThreshold ){ print( " + " + s_aY + " * Cos[" + String(i) + "t]" ) }
      if ( abs(m_bY[i]) > _fThreshold ){ print( " + " + s_bY + " * Sin[" + String(i) + "t]" ) }
      print("\n");
    }
    print("\n");
  }
}

