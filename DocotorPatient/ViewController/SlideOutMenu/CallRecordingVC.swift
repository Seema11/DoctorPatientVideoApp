//
//  CallRecordingVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 02/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

class CallRecordingVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelNoData: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelNoData.isHidden = true
    }

    @IBAction func didTapButtonSideMenu(_ sender: Any) {
        sideMenuController()?.openDrawer()
    }
    @IBAction func didTapButtonSearch(_ sender: Any) {
    }
    
    
    
}
extension CallRecordingVC : UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CallRecordingCell") as! CallRecordingCell
        return cell
    }
}

