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
  var didUpdateDataToUI: ((Item) -> Void)?
  private(set) var dataToUI: Item = Item(){
    didSet {
      didUpdateDataToUI?(dataToUI)
    }
  }
  var getDate: String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    let string = formatter.string(from: date)
    return string
  }
  
  
  func fetch() {
    repository.fetchData() { [weak self] items in
      guard let self = self else { return }
      let expFood = self.repository.foodCount(1)
      let cheFood = self.repository.foodCount(2)
      let noFood = self.repository.foodCount(3)
      let item = Item(data: items, exCount: expFood, chCount: cheFood, noFoodCount: noFood)
      self.dataToUI = item
    }
  }
  
  func didGetPhoto(_ image: UIImage){
    let date = getDate
    saveImage(date: date, image: image)
    detectFood(photoDate: date, with: image)
  }
  
  
  
  func saveImage(date: String, image: UIImage){
    repository.saveImageToFile(photoDate: date, image: image)
  }
  
  func detectFood (photoDate: String, with image: UIImage) {
    guard let ciimage = CIImage(image: image) else {fatalError("Could not convert to CIImage")
    }
    guard let model = try? VNCoreMLModel(for: MealClassifier().model) else {fatalError("Loading CoreML Model Failed")}
    let request = VNCoreMLRequest(model: model) { (request, error) in
      guard let result = request.results?.first as? VNClassificationObservation else {fatalError("Model failed to process image ")}
      
      let phrase = result.identifier
      let type = self.getType(phrase)
      let comment = self.getComment(phrase)
      self.repository.saveDataToDatabase(with: phrase, date: photoDate, type: type, comment: comment)
      self.fetch()
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
  
  private func getType(_ phrase: String) -> String{
     switch phrase {
     case "Дорогая еда" : return "1"
     case "Дешевая еда" : return "2"
     case "Не еда" : return "3"
     case "Пища богов" : return "2"
     default:
       print("Other food, incorrect type")
       return ""
     }
   }
  
  private func getComment(_ string: String) -> String{
    let expensive = ["Просто восторг!", "Выглядит очень аппетитно)", "Пальчики оближешь", "Круто, как-будто я сам готовил", "Шикуешь!", "Я бы съел"]
    let cheap = ["Эмм...ну так", "Вполне вкусно", "Если закрыть глаза, выглядит аппетитно", "С пивком сойдет", "Как в столовке", "Неплохо"]
    let no = ["А где еда?", "Зубы не поломай", "Я б не съел", "Не надо, не ешь!", "Уж лучше камней поесть"]
    
    switch string {
    case "Дорогая еда" : return expensive.randomElement()!
    case "Дешевая еда" : return cheap.randomElement()!
    case "Не еда" : return no.randomElement()!
    case "Пища богов" : return "Не налегай на это"
    default:
      print("Other food, incorrect type")
      return ""
    }
  }
 
  func delete(name: String) {
    repository.deleteFromDatabase(name: name)
    repository.deleteFromFile(fileName: name)
    fetch()
  }
  
  func getImageURL(fileName: String) -> URL? {
    let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
    if let dirPath = paths.first {
      let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
      return imageUrl
    }
    return nil
  }
  
}

struct Item {
  let items: [PhotoImage]
  let expensiveFoodCount: Int
  let cheapFoodCount: Int
  let noFoodCount: Int
}

extension Item {
  init(data: [PhotoImage] = [PhotoImage](), exCount: Int = 0, chCount: Int = 0, noFoodCount: Int = 0) {
    self.items = data
    self.expensiveFoodCount = exCount
    self.cheapFoodCount = chCount
    self.noFoodCount = noFoodCount
  }
}


