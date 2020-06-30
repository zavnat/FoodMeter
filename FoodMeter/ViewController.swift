//
//  ViewController.swift
//  FoodMeter
//
//  Created by admin on 30.06.2020.
//  Copyright © 2020 Natali. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @IBOutlet weak var startTextLabel: UILabel!
  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var label: UILabel!
  
  private let pickerController = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pickerController.delegate = self
    pickerController.sourceType = .photoLibrary // Then camera
    pickerController.allowsEditing = true
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      startTextLabel.text = ""
      image.image = pickedImage
      guard let ciimage = CIImage(image: pickedImage) else {fatalError("Could not convert to CIImage")
      }
      detectFood(with: ciimage)
    }
    pickerController.dismiss(animated: true, completion: nil)
  }
  
  
  
  func detectFood (with image: CIImage){
    guard let model = try? VNCoreMLModel(for: MealClassifier().model) else {fatalError("Loading CoreML Model Failed")}
    
    let request = VNCoreMLRequest(model: model) { (request, error) in
      guard let result = request.results?.first as? VNClassificationObservation else {fatalError("Model failed to process image ")}
      print(result.confidence)
      print(result.identifier)
      DispatchQueue.main.async {
        self.label.text = result.identifier
      }
      
      
      
    }
    DispatchQueue.global(qos: .userInitiated).async{
      let handler = VNImageRequestHandler(ciImage: image)
      
      do {
        try handler.perform([request])
      } catch {
        print(error)
      }
    }
    
  }
  
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
      present(pickerController, animated: true, completion: nil)
    }
    
}
