//
//  TableViewCell.swift
//  FoodMeter
//
//  Created by admin on 01.07.2020.
//  Copyright © 2020 Natali. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate {
  func sharePhoto(name: String, phrase: String, comment: String)
  func deleteImage(name: String)
}

class Cell: UITableViewCell {
  var cellDelegate: TableViewCellDelegate?
  var itemData: PhotoImage?
  
  @IBOutlet weak var photoImage: UIImageView!
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var commentLabel: UILabel!
  @IBOutlet weak var view: UIView!
  
  
  @IBAction func shareButtonPressed(_ sender: UIButton) {
    print("share pressed")
    cellDelegate?.sharePhoto(name: (itemData?.name)!, phrase: (itemData?.phrase)!, comment: itemData?.comment ?? "")
  }
  
  @IBAction func deleteButtonPressed(_ sender: UIButton) {
    print("delete pressed")
    cellDelegate?.deleteImage(name: (itemData?.name)!)
  }
}

