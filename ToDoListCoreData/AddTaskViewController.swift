//
//  AddTaskViewController.swift
//  ToDoListCoreData
//
//  Created by Chris Pickett on 2017-07-27.
//  Copyright © 2017 Chris Pickett. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var descField: UITextField!
    @IBOutlet weak var emojiField: UITextField!
    
    @IBAction func btnTapped(_ sender: Any) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Object Referencing to entity
        let task = Task(context: context)
        task.name = textField.text
        task.isDoneToday = false
        task.lastVisitDate = NSDate()
        task.prevLastVisitDate = NSDate()
        task.firstVisitDate = NSDate()
        task.desc = descField.text
        task.emoji = emojiField.text
        task.streak = 0
        task.logArr = []
        
        // Save the data to coredata
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        navigationController!.popViewController(animated: true)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        descField.delegate = self
        emojiField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    


}
