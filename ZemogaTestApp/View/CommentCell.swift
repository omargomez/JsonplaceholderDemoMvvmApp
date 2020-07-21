//
//  CommentCell.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/20/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    static let identifier = "\(CommentCell.self)"
    
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(model: CommentViewModel) {
        self.commentLabel.text = model.body
    }
}
