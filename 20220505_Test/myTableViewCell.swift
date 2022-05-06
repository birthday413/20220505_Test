//
//  myTableViewCell.swift
//  20220505_Test
//
//  Created by crawford on 2022/5/5.
//

import Foundation
import UIKit

class myTableViewCell: UITableViewCell {

    @IBOutlet weak var labelOfTime: UILabel!
    @IBOutlet weak var labelOfPrice: UILabel!
    @IBOutlet weak var labelOfAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
/*
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
*/
}
