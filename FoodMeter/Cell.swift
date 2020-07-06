//
//  TableViewCell.swift
//  FoodMeter
//
//  Created by admin on 01.07.2020.
//  Copyright © 2020 Natali. All rights reserved.
//

import UIKit

protocol TableViewCell {
  func sharePhoto(photoUrl: String)
  func deleteImage(name: String)
}

class Cell: UITableViewCell {

  var cellDelegate: TableViewCell?
  var itemData: PhotoImage?

  @IBOutlet weak var photoImage: UIImageView!
  @IBOutlet weak var label: UILabel!
  
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  @IBAction func shareButtonPressed(_ sender: UIButton) {
    print("share pressed")
    cellDelegate?.sharePhoto(photoUrl: (itemData?.name)!)
  }
  
  @IBAction func deleteButtonPressed(_ sender: UIButton) {
    print("delete pressed")
    cellDelegate?.deleteImage(name: (itemData?.name)!)
  }
}

