//
//  DetailCell.swift
//  FoodMeter
//
//  Created by admin on 12.07.2020.
//  Copyright © 2020 Natali. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {

  @IBOutlet weak var expensiveFoodLabel: UILabel!
  @IBOutlet weak var notFoodLabel: UILabel!
  @IBOutlet weak var cheapFoodLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
