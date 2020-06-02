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
    @IBOutlet weak var buttonImage: UIImageView!
    @IBOutlet weak var buttonNotes: UIButton!
    @IBOutlet weak var viewNotes: UIView!
    @IBOutlet weak var layooyConstarintWidthNotes: NSLayoutConstraint!
    
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
        if response.calltype == "video"{
            self.viewNotes.isHidden = false
            self.layooyConstarintWidthNotes.constant = 44
            self.buttonImage.image = UIImage.init(named: "video-call 50-30")
        } else {
             self.viewNotes.isHidden = true
            self.buttonImage.image = UIImage.init(named: "audio-call 50-50")
        }
        self.labelPatientName.text = response.username
        self.labelPatientTime.text = "Last call on \(response.endtime ?? "0")"
        if let str = response.profileimage {
        if str.contains("http") {
            self.imageViewProfile.downloadImage(fromURL: "\(response.profileimage ?? "")", placeHolderImage: UIImage.init(named: "man"), completion: nil)
        } else {
            self.imageViewProfile.downloadImage(fromURL: "http://yashikainfotech.website/doctorapi/api/\(response.profileimage ?? "")", placeHolderImage: UIImage.init(named: "man"), completion: nil)
                         }
               }
      }

}
