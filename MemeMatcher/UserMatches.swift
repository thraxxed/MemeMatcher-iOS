//
//  UserMatches.swift
//  MemeMatcher
//
//  Created by Zach Smith on 2/21/18.
//  Copyright © 2018 Seth Little. All rights reserved.
//

import UIKit

class UserMatches: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet weak var userMatcherinos: UILabel!
    @IBOutlet weak var userMatches: UIView!
    
    @IBOutlet weak var userAgerino: UILabel!
    
    @IBOutlet weak var userImagerino: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
