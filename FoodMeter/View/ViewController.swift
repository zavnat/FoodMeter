//
//  ViewController.swift
//  FoodMeter
//
//  Created by admin on 30.06.2020.
//  Copyright © 2020 Natali. All rights reserved.
//

import UIKit
import Kingfisher


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  var viewModel: ViewModel = ViewModel()
  
  var dataToUI = [PhotoImage]()
  
  @IBOutlet weak var startTextLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  var fotoImage = [UIImage]()
  
  var pickerController = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    
    tableView.rowHeight = 360
//    tableView.backgroundColor = UIColor.lightGray
    tableView.delegate = self
    tableView.dataSource = self
    pickerController.delegate = self
    pickerController.sourceType = .camera// Then camera
    pickerController.allowsEditing = true
    setupViewModel()
    viewModel.load()
    
    NotificationCenter.default.addObserver(self, selector: #selector(reactToNotification(_:)), name: .QuickActionCamera, object: nil)
  }
  
  
  
  
  @objc func reactToNotification(_ sender: Notification) {
    openCamera()
  }
  
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      
      let date = viewModel.getDate
      
      viewModel.saveImage(date: date, image: pickedImage)
      
      viewModel.detectFood(photoDate: date, with: pickedImage)
    }
    pickerController.dismiss(animated: true, completion: nil)
  }
  
  
  @IBAction func cameraPressed(_ sender: UIButton) {
    present(pickerController, animated: true, completion: nil)
  }
  
  func openCamera(){
    present(pickerController, animated: true, completion: nil)
  }
 
  
  private func setupViewModel() {
    
    viewModel.didUpdateDataToUI = { [weak self] data in
      guard let strongSelf = self else { return }
      strongSelf.dataToUI = data
      if data.count == 0 {
        strongSelf.tableView.isHidden = true
      } else {
        DispatchQueue.main.async {
          strongSelf.tableView.isHidden = false
          strongSelf.tableView.reloadData()
        }
        
      }
    }
  }
}


//MARK: - TableView Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataToUI.count
    
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
    
    cell.itemData = dataToUI[indexPath.row]
    cell.cellDelegate = self
    
    
    if let name = dataToUI[indexPath.row].name {
      //      let starttime = Date().millisecondsSince1970
      let url = viewModel.loadImageFromFile(fileName: name)
      
      if(url != nil){
        
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        cell.photoImage.kf.setImage(with: url, options: [.processor(processor)])
      }
    }
    cell.label.text = dataToUI[indexPath.row].phrase
    //    print(dataToUI[indexPath.row].phrase!)
    
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      cell.backgroundColor = UIColor.clear
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


//MARK: - TableViewCellDelegate Methods
extension ViewController: TableViewCellDelegate {
  func deleteImage(name: String) {
    viewModel.delete(name: name)
  }
  
  func sharePhoto(photoUrl: String) {
    print("share photo")
    let photo = viewModel.loadImageFromFile(fileName: photoUrl)
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
