//
//  PostItemViewCell.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/19/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import UIKit

class PostItemViewCell: UITableViewCell {

    static let identifier = "\(PostItemViewCell.self)"
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(model: PostListItemViewModel) {
        if !model.readed {
            self.statusLabel.text = "🔹"
        } else if model.starred {
            self.statusLabel.text = "⭐️"
        } else {
            self.statusLabel.text = ""
        }
        self.titleLabel.text = model.title
    }

}
