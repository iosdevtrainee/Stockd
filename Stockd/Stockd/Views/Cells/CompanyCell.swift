//
//  CompanyCell.swift
//  Stockd
//
//  Created by J on 1/1/19.
//  Copyright © 2019 J. All rights reserved.
//

import UIKit

class CompanyCell: UITableViewCell {
  @IBOutlet weak var companyNameLabel: UILabel!
  @IBOutlet weak var companyTickerLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
