//
//   Repository.swift
//  FoodMeter
//
//  Created by admin on 08.07.2020.
//  Copyright © 2020 Natali. All rights reserved.
//


import UIKit
import CoreData


protocol RepositoryService {
  func loadFromDatabase(completion: @escaping ([PhotoImage]) -> ())
}



class Repository: RepositoryService {
  
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  func saveDataToDatabase(with text: String, date: String){
    let myPhotoWithPhrase = PhotoImage(context: context)
    myPhotoWithPhrase.phrase = text
    myPhotoWithPhrase.name = date
    
    saveToDatabase()
  }
  
  
  //MARK:- Work with Database
  func saveToDatabase (){
    do{
      try  context.save()
    }catch{
      
    }
  }
  
  func loadFromDatabase (completion: @escaping ([PhotoImage]) -> ()) {
    let request: NSFetchRequest<PhotoImage> = PhotoImage.fetchRequest()
    let sort = NSSortDescriptor(key: "name", ascending: false)
    request.sortDescriptors = [sort]
    do{
      let data = try context.fetch(request)
      print("Success load data from database")
      completion(data)
      
    }catch {
      print("Error context fetch data")
    }
  }
  
  
  func deleteFromDatabase(name: String){
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
  }
  
  
  //MARK:- Work with local folder
  
  func saveImageToFile(photoDate: String, image: UIImage) {
    
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
}
