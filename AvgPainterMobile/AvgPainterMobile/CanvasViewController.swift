//
//  ViewController.swift
//  AvgPainterMobile
//
//  Created by 新納真次郎 on 2018/03/05.
//  Copyright © 2018年 nshhhin. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet weak var drawingView: DrawingView!
  @IBOutlet weak var selectedColorView: UIView!
  @IBOutlet weak var eraserBtn: UIButton!
  var bEraserMode = false
   let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    selectedColorView.backgroundColor = appDelegate.selectedColor
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear( animated )
    print("CanvasViewController is will Appear" )
  }
  
  override func viewDidAppear(_ animated: Bool) {
    print("CanvasViewController is did Appear")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func pushColorBtn(_ sender: Any) {
    let storyboard: UIStoryboard = self.storyboard!
    let nextView = storyboard.instantiateViewController(withIdentifier: "ColorView")
    nextView.modalTransitionStyle = .crossDissolve
    present(nextView, animated: true, completion: nil)
  }
  
  @IBAction func pushClearBtn(_ sender: Any) {
    drawingView.clear()
  }
  
  @IBAction func pushUndoBtn(_ sender: Any) {
    drawingView.undo()
  }
  
  @IBAction func pushEraserBtn(_ sender: Any) {
    let bEraserMode = appDelegate.bEraserMode
    if( bEraserMode ){
      let image = UIImage( named: "EraserBtn" )
      eraserBtn.setImage(image, for: .normal)
    }
    else{
      let image = UIImage( named: "EraserPushedBtn" )
      eraserBtn.setImage(image, for: .normal)
    }
    appDelegate.bEraserMode = !bEraserMode
  }
  
  @IBAction func pushSaveBtn(_ sender: Any) {
    drawingView.save()
  }
  
  @IBAction func pushOpenBtn(_ sender: Any) {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
      
      let picker = UIImagePickerController()
      picker.modalPresentationStyle = UIModalPresentationStyle.popover
      picker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
      picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
      
      if let popover = picker.popoverPresentationController {
        popover.sourceView = self.view
        popover.permittedArrowDirections = UIPopoverArrowDirection.any
      }
      self.present(picker, animated: true, completion: nil)
    }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      drawingView.displayImage(pickedImage)
    }
    picker.dismiss(animated: true, completion: nil)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
  }
  
  @IBAction func pushStrokeWeightBtn(_ sender: Any) {
    let next = storyboard!.instantiateViewController(withIdentifier: "StrokeWeightView")
    next.modalTransitionStyle = .crossDissolve
    self.present(next, animated: true, completion: nil)
  }
}

