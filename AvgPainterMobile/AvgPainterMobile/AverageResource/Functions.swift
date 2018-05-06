//
//  Functions.swift
//  avgStrokeMobile_v1
//
//  Created by 新納真次郎 on 2017/05/20.
//  Copyright © 2017年 nshhhin. All rights reserved.
//

import Foundation
import UIKit

var g_fThresholdToRemove: CGFloat = 0.05;

func dist( x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat {
  let square1 = (abs(x2-x1) * abs(x2-x1))
  let square2 = (abs(y2-y1) * abs(y2-y1))
  let squareSum = square1 + square2
  return sqrt( squareSum )
}

var g_listCharStrokes: Array<CharStroke> = []
var g_iMaxDegreeOfFourier: Int = 50
var g_fThresholdOfCoefficient: CGFloat = 0.001
var g_iMultiple = 100
var g_avgCharStroke = CharStroke()
var averaged = false

func getAverageCharStroke() -> CharStroke {
  let avgCharStroke = CharStroke()
  if ( g_listCharStrokes.count > 0  ) {
    let objCharStroke : CharStroke = g_listCharStrokes[0]
    let iNumOfStroke = objCharStroke.m_Strokes.count;
    for j in 0..<iNumOfStroke {
      var iTotalPoints = 0;
      for i in 0..<g_listCharStrokes.count {
        var charstroke :CharStroke = g_listCharStrokes[i]
        var st :Stroke  = charstroke.m_Strokes[j]
        iTotalPoints = iTotalPoints + st.m_SplinePt.count
      }
      print( "total \(iTotalPoints)" );
      print( " list \(g_listCharStrokes.count)" );
      var avgStroke : Stroke = Stroke(_iSize: iTotalPoints/g_listCharStrokes.count);
      for k in 0..<g_iMaxDegreeOfFourier+1 {
        avgStroke.m_Fourier.m_aX[k] = 0
        avgStroke.m_Fourier.m_bX[k] = 0
        avgStroke.m_Fourier.m_aY[k] = 0
        avgStroke.m_Fourier.m_bY[k] = 0
        
        for i in 0..<g_listCharStrokes.count {
          var charstroke : CharStroke = g_listCharStrokes[i];
          var st = charstroke.m_Strokes[j];
          avgStroke.m_Fourier.m_aX[k] = avgStroke.m_Fourier.m_aX[k] + st.m_Fourier.m_aX[k];
          avgStroke.m_Fourier.m_aY[k] = avgStroke.m_Fourier.m_aY[k] + st.m_Fourier.m_aY[k];
          avgStroke.m_Fourier.m_bX[k] = avgStroke.m_Fourier.m_bX[k] + st.m_Fourier.m_bX[k];
          avgStroke.m_Fourier.m_bY[k] = avgStroke.m_Fourier.m_bY[k] + st.m_Fourier.m_bY[k];
        }
        avgStroke.m_Fourier.m_aX[k] = avgStroke.m_Fourier.m_aX[k]/CGFloat(g_listCharStrokes.count);
        avgStroke.m_Fourier.m_aY[k] = avgStroke.m_Fourier.m_aY[k]/CGFloat(g_listCharStrokes.count);
        avgStroke.m_Fourier.m_bX[k] = avgStroke.m_Fourier.m_bX[k]/CGFloat(g_listCharStrokes.count);
        avgStroke.m_Fourier.m_bY[k] = avgStroke.m_Fourier.m_bY[k]/CGFloat(g_listCharStrokes.count);
      }
      avgCharStroke.AddStroke( st:avgStroke );
    }
  }
  return avgCharStroke;
}

func CGFloatBack( _points:[CGPoint] ) -> [CGPoint] {
  var _retPoints : [CGPoint] = [CGPoint]( repeating: CGPoint(x:0.0, y: 0.0), count: _points.count*2-1 );
  for i in 0..<_points.count {
    _retPoints[i] = CGPoint( x:_points[i].x, y:_points[i].y );
    _retPoints[_retPoints.count-i-1] = CGPoint( x:_points[i].x, y:_points[i].y );
  }
  return _retPoints;
}


