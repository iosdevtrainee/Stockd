//
//  WatchListCell.swift
//  Stockd
//
//  Created by J on 1/7/19.
//  Copyright © 2019 J. All rights reserved.
//

import UIKit

class WatchListCell: UITableViewCell {

  @IBOutlet weak var tickerNameLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
