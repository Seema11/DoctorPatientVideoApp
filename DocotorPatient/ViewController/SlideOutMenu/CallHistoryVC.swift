//
//  CallHistoryVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 02/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

class CallHistoryVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func didTapButtonSideMenu(_ sender: Any) {
        sideMenuController()?.openDrawer()
    }
    @IBAction func didTapButtonSearch(_ sender: Any) {
    }
    @IBAction func didTapButtonCall(_ sender: Any) {
        if #available(iOS 13.0, *) {
                let videoCallVC = self.storyboard?.instantiateViewController(identifier: "VideoCallVC") as! VideoCallVC
                self.navigationController?.pushViewController(videoCallVC, animated: true)
            } else {
                let videoCallVC = UIViewController.instantiateFrom("Menu", "VideoCallVC") as! VideoCallVC
                self.navigationController?.pushViewController(videoCallVC, animated: true)
            }
    }
    
}
extension CallHistoryVC : UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CallHistoryCell") as! CallHistoryCell
        return cell
    }
}
