//
//  TableViewCell.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/13/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postContent: UILabel!
    @IBOutlet weak var lastModified: UILabel!
    @IBOutlet weak var postOwner: UILabel!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
