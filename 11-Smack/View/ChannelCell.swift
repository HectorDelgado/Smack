//
//  ChannelCellTableViewCell.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/28/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//
//  Custom UITableViewCell that is used to display a Channel.

import UIKit

class ChannelCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var channelLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            self.layer.backgroundColor = UIColor(white: 1, alpha: 0.2).cgColor
        } else {
            self.layer.backgroundColor = UIColor.clear.cgColor
        }
    }
    
    func configureCell(channel: Channel) {
        let title = channel.channelName ?? ""
        channelLbl.text = "#\(title)"
        channelLbl.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        
        for id in MessageService.instance.unreadChannels {
            if id == channel.channelID {
                channelLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
            }
        }
    }
}
