//
//  TableViewCell.swift
//  FoodMeter
//
//  Created by admin on 01.07.2020.
//  Copyright © 2020 Natali. All rights reserved.
//

import UIKit

protocol TableViewCell {
  func sharePhoto(photo: UIImage)
}

class Cell: UITableViewCell {

  var cellDelegate: TableViewCell?
  var imageToShare: UIImage?

  @IBOutlet weak var photoImage: UIImageView!
  @IBOutlet weak var label: UILabel!
  
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  @IBAction func shareButtonPressed(_ sender: UIButton) {
     cellDelegate?.sharePhoto(photo: imageToShare!)
  }
  
  }

