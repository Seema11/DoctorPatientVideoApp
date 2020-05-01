//
//  PatientListVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 01/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

class PatientListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func didTapButtonMenu(_ sender: Any) {
        sideMenuController()?.openDrawer()
    }
    @IBAction func didTapButtonSearch(_ sender: Any) {
    }
    @IBAction func didTapButtonAudoiCall(_ sender: Any) {
    }
    @IBAction func didTapButtonVideoCall(_ sender: Any) {
    }
}
extension PatientListVC : UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PatientListCell") as! PatientListCell
        return cell
    }
}
