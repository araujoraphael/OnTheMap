//
//  PlaceTableViewCell.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 10/01/18.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageView?.image = UIImage(named: "icon_pin")
    }

    var studentInformation: StudentInformation? {
        didSet {
            layoutSubviews()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var name = ""
        
        if let fn = self.studentInformation?.firstName {
            name = fn
        }
        if let ln = self.studentInformation?.lastName {
            name += " \(ln)"
        }
        
        self.textLabel?.text = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let url = self.studentInformation?.location?.mediaURL {
            self.detailTextLabel?.text = url
        }
    }
}
