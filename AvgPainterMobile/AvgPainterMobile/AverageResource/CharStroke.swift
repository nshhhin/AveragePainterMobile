//
//  CharStroke.swift
//  drawingSystem
//
//  Created by 新納真次郎 on 2017/05/16.
//  Copyright (c) 2017年 nshhhin. All rights reserved.
//

import UIKit
import Foundation

class CharStroke {
  var m_Strokes : [Stroke]
  
  init(){
    m_Strokes = []
  }
  
  init(m_Strokes _stroke: [Stroke]){
    m_Strokes = []
    for i in 0..<_stroke.count {
      m_Strokes.append( _stroke[i] );
    }
  }
  
  func AddStroke( st : Stroke ){
    m_Strokes.append( st )
  }
  
  func displayStroke(context: CGContext){
    for i in 0..<m_Strokes.count {
      let st = m_Strokes[i]
      st.displayStroke(context: context)
    }
  }
  
  func displayAverage(context: CGContext) {
    for i in 0..<m_Strokes.count {
      let st = m_Strokes[i]
      st.displayAverage(context: context)
    }
  }
  
  
  func printXY(){
    for i in 0..<m_Strokes.count {
      m_Strokes[i].printXY()
    }
  }
  
  func GenerateEquationWithSpline( _iMultiple: Int ) {
    for i in 0..<m_Strokes.count {
      var stroke = m_Strokes[i]
      // 0 ～ PI で t を作成する
      var _arrayT:[CGFloat] = [CGFloat](repeating: 0.0, count:stroke.m_orgPt.count)
      for j in 0..<stroke.m_orgPt.count {
        _arrayT[j] = (CGFloat(j)*CGFloat.pi)/(CGFloat(stroke.m_orgPt.count-1))
      }
      
      var sp: Spline = Spline();
      stroke.m_SplinePt = sp.GetSplineSeries( _t: _arrayT, _arrayPt: stroke.m_orgPt, _multiple: _iMultiple );
      
      // ストロークを折り返して2倍にする
      // フーリエ級数展開では始点終点が同じであることが理想であるため
      stroke.m_SplinePt = CGFloatBack( _points: stroke.m_SplinePt );
      stroke.m_Fourier.ExpansionFourierSeries( _arrayPt: stroke.m_SplinePt, _iMaxDegree: g_iMaxDegreeOfFourier );
      //print( "degree = ", stroke.m_Fourier.GetAppropriateDegree( g_iMaxDegreeOfFourier, stroke.m_SplinePt.length, g_fThresholdOfCoefficient ) );
    }
  }
  
}
