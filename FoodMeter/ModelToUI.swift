//
//  ModelToUI.swift
//  FoodMeter
//
//  Created by admin on 02.07.2020.
//  Copyright © 2020 Natali. All rights reserved.
//

import Foundation
import UIKit

class ModelToUI {
  let textToImage: PhotoImage?
  let image: UIImage?
  
  init(image: UIImage, string: PhotoImage) {
    self.image = image
    textToImage = string
  }
}
