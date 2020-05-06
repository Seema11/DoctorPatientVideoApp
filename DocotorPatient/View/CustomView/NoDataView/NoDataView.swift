//
//  NoDataView.swift
//  circles
//
//  Created by Mac22 on 11/04/19.
//  Copyright © 2019 NP. All rights reserved.
//

import UIKit

//@IBDesignable
class NoDataView: UIView {
    
    @IBOutlet var viewMainContent: UIView!
    @IBOutlet weak var viewMainContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
  //  @IBOutlet weak var gradientButtonView: GradientButtonView!
    
    @IBInspectable
    var title: String? {
        didSet {
            self.labelTitle.text = self.title
        }
    }
    
    @IBInspectable
    var message: String? {
        didSet {
            self.labelMessage.text = self.message
        }
    }
    
    @IBInspectable
    var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }
    
    @IBInspectable
//    var buttonTitle: String? {
//        didSet {
//            self.gradientButtonView.buttonTitle = self.buttonTitle
//        }
//    }
    
    var buttonTapped: (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    fileprivate func commonInit() {
        let bundle = Bundle(for: NoDataView.self)
        bundle.loadNibNamed(String(describing: NoDataView.self), owner: self, options: nil)
        self.addSubview(self.viewMainContent)
        self.viewMainContent.frame = self.bounds
        self.viewMainContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        self.gradientButtonView.buttonTapped = { (_) in
//            self.buttonTapped?()
//        }
    }

}
