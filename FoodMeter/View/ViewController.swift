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
  
  var dataToUI = Item()
  
  @IBOutlet weak var startTextLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  var pickerController = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  //    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    tableView.delegate = self
    tableView.dataSource = self
    pickerController.delegate = self
    pickerController.sourceType = .camera// Then camera
    pickerController.allowsEditing = true
    overrideUserInterfaceStyle = .light
    setupViewModel()
    NotificationCenter.default.addObserver(self, selector: #selector(reactToNotification(_:)), name: .QuickActionCamera, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      viewModel.fetch()
  }
  
  @objc func reactToNotification(_ sender: Notification) {
    present(pickerController, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      viewModel.didGetPhoto(pickedImage)
      }
    pickerController.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func cameraPressed(_ sender: UIButton) {
    present(pickerController, animated: true, completion: nil)
  }
  
  private func setupViewModel() {
    viewModel.didUpdateDataToUI = { [weak self] data in
      guard let self = self else { return }
      self.dataToUI = data
      if self.dataToUI.items.count == 0 {
        self.tableView.isHidden = true
      } else {
        DispatchQueue.main.async {
          self.tableView.isHidden = false
          self.tableView.reloadData()
        }
      }
    }
  }
}

//MARK: - TableView Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return dataToUI.items.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.notFoodLabel.text = String(dataToUI.noFoodCount)
      cell.cheapFoodLabel.text = String(dataToUI.cheapFoodCount)
      cell.expensiveFoodLabel.text = String(dataToUI.expensiveFoodCount)
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
      cell.itemData = dataToUI.items[indexPath.row]
      cell.cellDelegate = self
      cell.view.layer.cornerRadius = 15
      cell.photoImage.layer.cornerRadius = 15
      cell.photoImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
      if let name = dataToUI.items[indexPath.row].name {
        //      let starttime = Date().millisecondsSince1970
        let url = viewModel.getImageURL(fileName: name)
        if(url != nil){
          let processor = RoundCornerImageProcessor(cornerRadius: 20)
          cell.photoImage.kf.setImage(with: url, options: [.processor(processor)])
        }
      }
      cell.label.text = dataToUI.items[indexPath.row].phrase
      cell.commentLabel.text = dataToUI.items[indexPath.row].comment
      return cell
    }
  }
 
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      cell.backgroundColor = UIColor.clear
  }
}

//MARK: - Extension Date
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
  func sharePhoto(name: String, phrase: String, comment: String) {
    let photo = viewModel.getImageURL(fileName: name)
    if let imagePhoto = photo {
      let activityController = UIActivityViewController(activityItems: [imagePhoto, phrase, comment], applicationActivities: nil)
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
  
  func deleteImage(name: String) {
    let alert = UIAlertController(title: "Удалить это фото?", message: "", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
    let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
      guard let self = self else { return }
      self.viewModel.delete(name: name)
    }
    alert.addAction(cancelAction)
    alert.addAction(deleteAction)
    present(alert, animated: true, completion: nil)
  }
  
  
  
}


