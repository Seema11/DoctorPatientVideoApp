//
//  CallHistoryCell.swift
//  DocotorPatient
//
//  Created by Bhavesh on 02/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

class CallHistoryCell: UITableViewCell {

    @IBOutlet weak var cellBackView: UIView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelPatientName: UILabel!
    @IBOutlet weak var labelPatientTime: UILabel!
    @IBOutlet weak var buttonCall: UIButton!
    
     static var nib:UINib {
           return UINib(nibName: identifier, bundle: nil)
       }
       
       static var identifier: String {
           return String(describing: self)
       }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setUpData(response : HistoryModel) {
        self.labelPatientName.text = response.username
        self.labelPatientTime.text = "\(response.starttime ?? "0:0") - \(response.endtime ?? "0"))"
      }

}
