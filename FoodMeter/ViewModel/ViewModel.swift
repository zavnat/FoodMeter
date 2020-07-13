//
//  ViewModel.swift
//  FoodMeter
//
//  Created by admin on 08.07.2020.
//  Copyright © 2020 Natali. All rights reserved.
//

import Foundation
import CoreML
import Vision
import CoreData
import UIKit

class ViewModel {
  
  var repository = Repository()
  
  var didUpdateDataToUI: (([PhotoImage]) -> Void)?
  
  
  private(set) var dataToUI: [PhotoImage] = [PhotoImage]() {
    didSet {
      didUpdateDataToUI?(dataToUI)
    }
  }
  
  var getDate: String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    let fotoName = formatter.string(from: date)
    return fotoName
  }
  
  func saveImage(date: String, image: UIImage){
    repository.saveImageToFile(photoDate: date, image: image)
  }
  
  func load(){
    repository.loadFromDatabase { [weak self] data in
      guard let self = self else { return }
      self.updateData(with: data)
    }
  }
  
  private func updateData (with data: [PhotoImage]) {
    self.dataToUI = data
  }
  
  
  
  func delete(name: String) {
    
    print("delete image")
    
    repository.deleteFromDatabase(name: name)
    repository.deleteFromFile(fileName: name)
    load()
  }
  
  
  func loadImageFromFile(fileName: String) -> URL? {
    
    let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
    
    let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
    
    if let dirPath = paths.first {
      let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
      return imageUrl
    }
    
    return nil
  }
  
  
  func detectFood (photoDate: String, with image: UIImage) {
    
    guard let ciimage = CIImage(image: image) else {fatalError("Could not convert to CIImage")
    }
    
    guard let model = try? VNCoreMLModel(for: MealClassifier().model) else {fatalError("Loading CoreML Model Failed")}
    
    let request = VNCoreMLRequest(model: model) { (request, error) in
      guard let result = request.results?.first as? VNClassificationObservation else {fatalError("Model failed to process image ")}
      
      
      let phrase = result.identifier
      self.repository.saveDataToDatabase(with: phrase, date: photoDate)
      self.load()
    }
    DispatchQueue.global(qos: .userInitiated).async{
      let handler = VNImageRequestHandler(ciImage: ciimage)
      do {
        try handler.perform([request])
      } catch {
        print(error)
      }
    }
  }

}
