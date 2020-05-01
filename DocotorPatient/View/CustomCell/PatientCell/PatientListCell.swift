//
//  PatientListCell.swift
//  DocotorPatient
//
//  Created by Bhavesh on 01/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

class PatientListCell: UITableViewCell {

    @IBOutlet weak var cellBackView: UIView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelPatientName: UILabel!
    @IBOutlet weak var labelPatientTime: UILabel!
    @IBOutlet weak var buttonAudioCall: UIButton!
    
    @IBOutlet weak var buttonVideoCall: UIButton!
    
    @IBOutlet weak var constaintHeightLayoutTime: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
