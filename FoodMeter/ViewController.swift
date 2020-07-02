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
import CoreData


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  var dataToUI = [PhotoImage]()
  
  @IBOutlet weak var startTextLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  var fotoImage = [UIImage]()
  var stringFunAnswer = ""
  private let pickerController = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    
    tableView.rowHeight = 310
    tableView.delegate = self
    tableView.dataSource = self
    pickerController.delegate = self
    pickerController.sourceType = .photoLibrary // Then camera
    pickerController.allowsEditing = true
  
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      fotoImage.append(pickedImage)
      //startTextLabel.text = ""
      
      guard let ciimage = CIImage(image: pickedImage) else {fatalError("Could not convert to CIImage")
      }
      detectFood(with: ciimage)
      
      let myPhotoWithPhrase = PhotoImage()
      myPhotoWithPhrase.phrase = ""
      myPhotoWithPhrase.name = ""
    }
    pickerController.dismiss(animated: true, completion: nil)
    tableView.reloadData()
  }
  
  
  
  func detectFood (with image: CIImage) {
    
    guard let model = try? VNCoreMLModel(for: MealClassifier().model) else {fatalError("Loading CoreML Model Failed")}
    
    let request = VNCoreMLRequest(model: model) { (request, error) in
      guard let result = request.results?.first as? VNClassificationObservation else {fatalError("Model failed to process image ")}
      print(result.confidence)
      print(result.identifier)
      self.stringFunAnswer = result.identifier
      
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



extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fotoImage.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
    cell.photoImage.image = fotoImage[indexPath.row]
    cell.label.text = stringFunAnswer
    return cell
  }
}
