//
//  TableViewCell.swift
//  FoodMeter
//
//  Created by admin on 01.07.2020.
//  Copyright © 2020 Natali. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {


  @IBOutlet weak var photoImage: UIImageView!
  @IBOutlet weak var label: UILabel!
  
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  }

