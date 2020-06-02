//
//  NotesViewController.swift
//  DocotorPatient
//
//  Created by Bhavesh on 30/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {

    @IBOutlet weak var notesLabel: PaddingLabel!
    @IBOutlet weak var buttonCancel: UIButton!
    var notesStr : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notesLabel.text = notesStr
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapBurttonCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
