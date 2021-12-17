//
//  SampleCell.swift
//  AirplaneLookUpper
//
//  Created by Minori Manabe on 2021/12/17.
//

import Foundation
import UIKit

class SampleCell: UICollectionViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  //@IBOutlet weak var badgeImageView: UIImageView!
  
  var representedIdentifier: String = ""
  
  var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
  var image: UIImage? {
    didSet {
      imageView.image = image
        print("image set as \(String(describing: image))")
    }
  }
  
  //var badge: UIImage? {
//    didSet {
//      badgeImageView.image = badge
//    }
//  }
}
