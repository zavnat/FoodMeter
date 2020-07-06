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
import Kingfisher


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  var dataToUI = [PhotoImage]()
  
  
  
  @IBOutlet weak var startTextLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  var fotoImage = [UIImage]()

  private let pickerController = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    
    tableView.rowHeight = 360
    tableView.delegate = self
    tableView.dataSource = self
    pickerController.delegate = self
    pickerController.sourceType = .camera// Then camera
    pickerController.allowsEditing = true
   
    load()
  
  }
  
  var getDate: String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    let fotoName = formatter.string(from: date)
    return fotoName
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      fotoImage.append(pickedImage)
      
      let date = getDate
      
      saveImage(photoDate: date, image: pickedImage)
      
      detectFood(photoDate: date, with: pickedImage)
      
    }
    pickerController.dismiss(animated: true, completion: nil)
    
    
  }
  
  func saveToDatabase(with text: String, date: String){
    let myPhotoWithPhrase = PhotoImage(context: context)
    myPhotoWithPhrase.phrase = text
    myPhotoWithPhrase.name = date
    
    save()
    load()
    
  }
  
  func detectFood (photoDate: String, with image: UIImage) {
    
    guard let ciimage = CIImage(image: image) else {fatalError("Could not convert to CIImage")
    }
 
    guard let model = try? VNCoreMLModel(for: MealClassifier().model) else {fatalError("Loading CoreML Model Failed")}
//    print("1")
    let request = VNCoreMLRequest(model: model) { (request, error) in
      guard let result = request.results?.first as? VNClassificationObservation else {fatalError("Model failed to process image ")}
      //      print(result.confidence)
      //      print(result.identifier)
      
      let phrase = result.identifier
      self.saveToDatabase(with: phrase, date: photoDate)
      
      //print(result.identifier)
//      print("3")
    }
    DispatchQueue.global(qos: .userInitiated).async{
      let handler = VNImageRequestHandler(ciImage: ciimage)
//      print("2")
      do {
        try handler.perform([request])
      } catch {
        print(error)
      }
    }
//    print("4")
    
  }
  
  
  
  
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
      present(pickerController, animated: true, completion: nil)
    }
  
  
  func saveImage(photoDate: String, image: UIImage) {
    
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    
    let fileURL = documentsDirectory.appendingPathComponent(photoDate)
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

  
  
  func loadImageFromDiskWithNew(fileName: String) -> URL? {
    
    let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
    
    let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
    
    if let dirPath = paths.first {
      let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
      return imageUrl
    }
    
    return nil
  }
  
  
  func deleteFromFile(fileName: String) {
    print("delete from file")
      let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
      
      let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
      let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
      
      if let dirPath = paths.first {
        let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
       
        do {
            try FileManager.default.removeItem(at: imageUrl)
            print("File deleted")
        }
        catch {
            print("Error")
        }
      }
   
      
      
  }
  
  
  func loadImageFromDiskWithOld(fileName: String) -> UIImage? {
    
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
      
//      let starttime = Date().millisecondsSince1970
//      print(starttime)
      try  context.save()
//      let endtime = Date().millisecondsSince1970
//      print("\(endtime - starttime)")
//      DispatchQueue.main.async {
//        self.tableView.reloadData()
//      }
    }catch{
      
    }
  }
  
  
  func load (){
    let request: NSFetchRequest<PhotoImage> = PhotoImage.fetchRequest()
    let sort = NSSortDescriptor(key: "name", ascending: false)
    request.sortDescriptors = [sort]
    do{
      let data = try context.fetch(request)
      print("Success load data from database")
      dataToUI = data
//      var photo = [ModelToUI]()
//      for item in data {
//        if let name = item.name {
//          print(name)
//          guard let loadPhoto = loadImageFromDiskWith(fileName: name) else { return }
//          let model = ModelToUI(image: loadPhoto, string: item)
//          photo.append(model)
//        }
//        dataToUI = photo
        
      //}
     
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }catch {

    }
  }
  
  
  func deleteImage(name: String) {
   
    print("deete image")
      let fetchRequest: NSFetchRequest<PhotoImage> = PhotoImage.fetchRequest()
      fetchRequest.predicate = NSPredicate(format: "name = %@", name)
      let request = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)

      do {
          try context.execute(request)
          try context.save()
        print("delete success")
      } catch {
          print ("There was an error")
      }
    deleteFromFile(fileName: name)
     load()
     tableView.reloadData()
  }
  
  
  
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //return fotoImage.count
    return dataToUI.count
   
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
    //    cell.photoImage.image = dataToUI[indexPath.row].image
    //    cell.label.text = dataToUI[indexPath.row].textToImage?.phrase
    //    cell.cellDelegate = self
    cell.itemData = dataToUI[indexPath.row]
    cell.cellDelegate = self
   
    
    if let name = dataToUI[indexPath.row].name {
      let starttime = Date().millisecondsSince1970
      let url = loadImageFromDiskWithNew(fileName: name)
      
      if(url != nil){
         cell.photoImage.kf.setImage(with: url)
      }
//
//      cell.photoImage.image = loadImageFromDiskWithOld(fileName: name)
      let endtime = Date().millisecondsSince1970
      print("Time for loading image -  \(endtime - starttime)")
    }
    cell.label.text = dataToUI[indexPath.row].phrase
//    print(dataToUI[indexPath.row].phrase!)
    
    
    return cell
  }
}




extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension ViewController: TableViewCell {
  func sharePhoto(photoUrl: String) {
    print("share photo")
    let photo = loadImageFromDiskWithNew(fileName: photoUrl)
    if let imagePhoto = photo {
      let activityController = UIActivityViewController(activityItems: [imagePhoto], applicationActivities: nil)
      activityController.completionWithItemsHandler = {(nil,completed,_,error) in
        if completed {
          print("completed")
        }else {
          print("cancled")
        }
      }
      present(activityController, animated: true)
    }
  }
  
  
}
