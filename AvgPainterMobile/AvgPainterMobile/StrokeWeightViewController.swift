//
//  StrokeWeightViewController.swift
//  
//
//  Created by 新納真次郎 on 2018/04/01.
//

import UIKit

class StrokeWeightViewController: UIViewController {
  
  let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
  
  @IBOutlet weak var circleView: UIView!
  @IBOutlet weak var strokeWeightSlider: UISlider!
  var weight:Float = 100
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let realWeight =  CGFloat( strokeWeightSlider.value * weight )
    print(realWeight)
    circleView.layer.masksToBounds = true
    circleView.layer.cornerRadius = realWeight/2
    print(circleView.layer.cornerRadius)
    circleView.bounds.size = CGSize(width: realWeight, height: realWeight)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func changedSlider(_ sender: Any) {
    //print(strokeWeightSlider.value)
    
    let realWeight = CGFloat( strokeWeightSlider.value * weight )
    circleView.layer.cornerRadius = realWeight/2
    circleView.bounds.size = CGSize(width: realWeight, height: realWeight)
    appDelegate.selectedStrokeWeight = realWeight
    
    let preView = self.presentingViewController as! CanvasViewController
    preView.selectedColorView.layer.cornerRadius = realWeight/4
    preView.selectedColorView.bounds.size = CGSize(width: realWeight/2, height: realWeight/2)
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // このビューが最表面じゃない時は無効化する
    if let topController = UIApplication.topViewController() {
      if( topController != self ){
        return
      }
    }
    
    for touch: UITouch in touches {
      let tag = touch.view!.tag
      if tag == 1 {
        dismiss(animated: true, completion: nil)
      }
    }
  }
}
