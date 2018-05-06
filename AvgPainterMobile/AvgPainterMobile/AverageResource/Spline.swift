//
//  Spline.swift
//  drawingSystem
//
//  Created by 新納真次郎 on 2015/11/14.
//  Copyright (c) 2015年 nshhhin. All rights reserved.
//

import Foundation
import UIKit


class Spline {
  
  init() {
  }
  
  let PI = CGFloat.pi
  let TWO_PI = 2*CGFloat.pi
  
  func GetSpline( _arrayPt :[CGPoint], _multiple :Int ) -> [CGPoint]{
    var _arrayT :[CGFloat] = [CGFloat](repeating: 0.0, count: _arrayPt.count)
    for i in 0..<_arrayPt.count {
      _arrayT[i] = CGFloat(( CGFloat(i)*PI )/( CGFloat(_arrayPt.count-1) )-PI)
    }
    
    var _points :[CGPoint] = GetSplineSeries( _t: _arrayT, _arrayPt: _arrayPt, _multiple: _multiple );
    var _retPoints = [CGPoint](repeating: CGPoint(x: 0.0, y: 0.0), count: _points.count*2-1 )
    for i in 0..<_points.count {
      _retPoints[i] = _points[i];
      _retPoints[_retPoints.count-i-1]  = _points[i];
    }
    return _retPoints;
  }
  
  func GetInterXYSeries( _t: [CGFloat], _arrayPt: [CGPoint], _multiple: Int ) -> [CGPoint]{
    
    var _retPoints  = [CGPoint](repeating: CGPoint(x:0.0, y:0.0), count:_arrayPt.count*_multiple)
    _retPoints[0] = CGPoint( x:_arrayPt[0].x, y:_arrayPt[0].y );
    _retPoints[_arrayPt.count*_multiple-1] = CGPoint( x:_arrayPt[_arrayPt.count-1].x, y:_arrayPt[_arrayPt.count-1].y )
    for i in 1..<_arrayPt.count*_multiple {
      var rx = CGFloat(i)*(_arrayPt[0].x+_arrayPt[_arrayPt.count-1].x)/(CGFloat(_arrayPt.count*_multiple-1))
      var ry = CGFloat(i)*(_arrayPt[0].x+_arrayPt[_arrayPt.count-1].x)/(CGFloat(_arrayPt.count*_multiple-1))
      _retPoints[i] = CGPoint(x:rx, y:ry)
    }
    return _retPoints;
  }
  
  func GetSplineSeries( _t: [CGFloat], _arrayPt: [CGPoint], _multiple: Int ) -> [CGPoint]{
    if ( _arrayPt.count == 2 ) {
      return GetInterXYSeries( _t: _t, _arrayPt: _arrayPt, _multiple: _multiple );
    }
    
    var _arrayX = [CGFloat](repeating:0.0, count:_arrayPt.count)
    var _arrayY = [CGFloat](repeating:0.0, count:_arrayPt.count)
    for i in 0..<_arrayPt.count {
      _arrayX[i] = _arrayPt[i].x;
      _arrayY[i] = _arrayPt[i].y;
    }
    
    // multi倍の点を取る
    var _interX:[CGFloat] = GetSplineValues( _t: _t, _value: _arrayX, _multiple: _multiple );
    var _interY:[CGFloat] = GetSplineValues( _t: _t, _value: _arrayY, _multiple: _multiple );
    
    // Remove duplicate points
    var number = 1;
    var skipFrom = 1;
    for i in 1..<_interX.count {
      if ( dist( x1:CGFloat(_interX[i]), y1:CGFloat(_interY[i]), x2:CGFloat(_interX[skipFrom]), y2:CGFloat(_interY[skipFrom]))<g_fThresholdToRemove ) {
        // 何もしない
      }
      else if ( _interX[i] == -1 && _interY[i] == -1 ) {
        //何もしない
      } else {
        skipFrom = i;
        number = number + 1;
      }
    }
    
    var _retPoints:[CGPoint] = [CGPoint](repeating: CGPoint(x:0.0, y:0.0), count: number)
    _retPoints[0] = CGPoint( x:_interX[0], y:_interY[0] );
    number = 1;
    skipFrom = 1;
    for i in 1..<_interX.count {
      if ( dist( x1:CGFloat(_interX[i]), y1:CGFloat(_interY[i]), x2:CGFloat(_interX[skipFrom]), y2:CGFloat(_interY[skipFrom]) ) < g_fThresholdToRemove) {
      } else if ( _interX[i] == -1 && _interY[i] == -1 ) {
      } else {
        skipFrom = i;
        _retPoints[number] = CGPoint( x: _interX[i], y: _interY[i] );
        number = number + 1
      }
    }
    
    print( "original array size = \(String(_interX.count))" );
    print( "         array size = \(String( _retPoints.count))" );
    return _retPoints;
  }
  
  func GetSplineValues(_t : [CGFloat], _value:[CGFloat], _multiple: Int) -> [CGFloat] {
    var retValue:[CGFloat] = [CGFloat](repeating: 0.0, count: (_value.count-1) * _multiple+1)
    
    let n = _t.count-1;
    var h: [CGFloat] = [CGFloat](repeating: 0.0, count: n)
    var b: [CGFloat] = [CGFloat](repeating: 0.0, count: n)
    var d: [CGFloat] = [CGFloat](repeating: 0.0, count: n)
    var g: [CGFloat] = [CGFloat](repeating: 0.0, count: n)
    var u: [CGFloat] = [CGFloat](repeating: 0.0, count: n)
    var r: [CGFloat] = [CGFloat](repeating: 0.0, count: n+1)
    let q: [CGFloat] = [CGFloat](repeating: 0.0, count: n)
    let s: [CGFloat] = [CGFloat](repeating: 0.0, count: n)
    
    let i1 = 0;
    
    for i1 in 0..<n {
      h[i1] = _t[i1+1] - _t[i1];
    }
    for i1 in 1..<n {
      b[i1] = CGFloat(2.0 * (h[i1] + h[i1-1]));
      d[i1] = CGFloat(3.0 * ((_value[i1+1] - _value[i1]) / h[i1] - (_value[i1] - _value[i1-1]) / h[i1-1]));
    }
    g[1] = h[1] / b[1];
    for i1 in 2..<n-1 {
      g[i1] = h[i1] / (b[i1] - h[i1-1] * g[i1-1]);
    }
    u[1] = d[1] / b[1];
    for i1 in 2..<n {
      u[i1] = (d[i1] - h[i1-1] * u[i1-1]) / (b[i1] - h[i1-1] * g[i1-1]);
    }
    
    r[0] = 0.0;
    r[n] = 0.0;
    r[n-1] = u[n-1];
    for i1 in (1..<n-1).reversed() {
      r[i1] = u[i1] - g[i1] * r[i1+1];
    }
    
    var num = 0;
    for i in 0..<_value.count-1 {
      let between = _t[i+1]-_t[i];
      let splineT :CGFloat = between/CGFloat(_multiple);
      for j in 0..<_multiple {
        let sp = CGFloat(j) * splineT;
        let qi1 = CGFloat((_value[i+1] - _value[i]) / h[i])
        let qi2 = CGFloat( h[i] * (r[i+1] + 2.0 * r[i]) / 3.0 )
        let qi = CGFloat(qi1 - qi2);
        let si = CGFloat((r[i+1] - r[i]) / (3.0 * h[i]));
        let y1 = CGFloat(_value[i] + sp * (qi + sp * (r[i]  + si * sp)));
        retValue[num] = y1;
        num = num + 1;
      }
    }
    retValue[retValue.count-1] = _value[_value.count-1];
    
    return retValue;
  }
  
}

