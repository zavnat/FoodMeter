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

  private let pickerController = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    
    tableView.rowHeight = 310
    tableView.delegate = self
    tableView.dataSource = self
    pickerController.delegate = self
    pickerController.sourceType = .camera // Then camera
    pickerController.allowsEditing = true
  
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      fotoImage.append(pickedImage)
      
      
      let date = Date()
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
      let fotoName = formatter.string(from: date)
      saveImage(imageName: fotoName, image: pickedImage)
      
      
      
      guard let ciimage = CIImage(image: pickedImage) else {fatalError("Could not convert to CIImage")
      }
      let phrase = detectFood(with: ciimage)
      
      let myPhotoWithPhrase = PhotoImage(context: context)
      myPhotoWithPhrase.phrase = phrase
      myPhotoWithPhrase.name = fotoName
      save()
    }
    pickerController.dismiss(animated: true, completion: nil)
    tableView.reloadData()
  }
  
  
  
  func detectFood (with image: CIImage) -> String {
    
    var funPhrase = ""
    
    guard let model = try? VNCoreMLModel(for: MealClassifier().model) else {fatalError("Loading CoreML Model Failed")}
    
    let request = VNCoreMLRequest(model: model) { (request, error) in
      guard let result = request.results?.first as? VNClassificationObservation else {fatalError("Model failed to process image ")}
      //      print(result.confidence)
      //      print(result.identifier)
      
      funPhrase = result.identifier
      
    }
    DispatchQueue.global(qos: .userInitiated).async{
      let handler = VNImageRequestHandler(ciImage: image)
      
      do {
        try handler.perform([request])
      } catch {
        print(error)
      }
    }
    return funPhrase
  }
  
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
      present(pickerController, animated: true, completion: nil)
    }
  
  
  func saveImage(imageName: String, image: UIImage) {
    
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    
    let fileName = imageName
    let fileURL = documentsDirectory.appendingPathComponent(fileName)
    guard let data = image.jpegData(compressionQuality: 1) else { return }
    
    //Checks if file exists, removes it if so.
    if FileManager.default.fileExists(atPath: fileURL.path) {
      do {
        try FileManager.default.removeItem(atPath: fileURL.path)
        print("Removed old image")
      } catch let removeError {
        print("couldn't remove file at path", removeError)
      }
    }
    
    do {
      try data.write(to: fileURL)
      print("Successs write image to file")
    } catch let error {
      print("error saving file with error", error)
    }
    
  }

  
  
  func loadImageFromDiskWith(fileName: String) -> UIImage? {
    
    let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
    
    let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
    
    if let dirPath = paths.first {
      let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
      let image = UIImage(contentsOfFile: imageUrl.path)
      return image
      
    }
    
    return nil
  }
  
  
  func save (){
    do{
     try  context.save()
      print("Success save data to database")
      //tableView.reloadData()
    }catch{
      
    }
  }
  
  
  func load (){
    let request: NSFetchRequest<PhotoImage> = PhotoImage.fetchRequest()
    do{
      dataToUI = try context.fetch(request)
      print("Success load data from database")
      
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }catch {

    }
  }
  
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fotoImage.count
   
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
    cell.photoImage.image = fotoImage[indexPath.row]
    //cell.label.text = ""
    return cell
  }
}

