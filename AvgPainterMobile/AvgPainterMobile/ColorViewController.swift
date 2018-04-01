
import UIKit
import ChromaColorPicker


class ColorViewController: UIViewController, ChromaColorPickerDelegate {
  
  let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    let centerX = self.view.bounds.size.width/2
    let centerY = self.view.bounds.size.height/2
    
    let neatColorPicker = ChromaColorPicker(frame: CGRect(x: centerX-150, y: centerY-150, width: 300, height: 300))
    neatColorPicker.delegate = self
    neatColorPicker.padding = 5
    neatColorPicker.stroke = 3
    neatColorPicker.hexLabel.textColor = UIColor.white
    neatColorPicker.adjustToColor( appDelegate.selectedColor )
    
    view.addSubview(neatColorPicker)
  }
  
  func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
    
    // グローバルなselectedColorを更新
    appDelegate.selectedColor = color
    
    // canvasViewの選択色を更新
    let canvasView = self.presentingViewController as! CanvasViewController
    canvasView.selectedColorView.backgroundColor = color
    
    dismiss(animated: true, completion: nil)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    dismiss(animated: true, completion: nil)
  }
  
  
}
