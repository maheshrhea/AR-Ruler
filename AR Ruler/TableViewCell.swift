//
//  TableViewCell.swift
//  AR Ruler
//
//  Created by Rhea Mahesh on 7/17/18.
//  Copyright © 2018 Rhea Mahesh. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var result: UILabel!

    var uid: String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
