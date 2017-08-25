//
//  ViewController.swift
//  ToDoListCoreData
//
//  Created by Chris Pickett on 2017-07-27.
//  Copyright © 2017 Chris Pickett. All rights reserved.
//

import UIKit

var tasks : [Task] = []
var myIndex = 0
var log : [String] = []

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Challenges"
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(ViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
    }
    
    func refresh(){

        self.tableView.reloadData()
        self.refresher.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //  Get the data from core data
        getData()
        
        tableView.reloadData()
        
    }
    
    // Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    // Define content in each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let task = tasks[indexPath.row]
        
        cell.textLabel?.text = "\(task.emoji!) \(task.name!)"
        
        if task.isDoneToday {
            //tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            cell.backgroundColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
            
        } else {
            cell.backgroundColor = UIColor(red:0.18, green:0.80, blue:0.44, alpha:1.0)
        }
        
        return cell
    }
    
    func getData() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            tasks = try context.fetch(Task.fetchRequest())
        }
        catch {
            print("Fetching Failed")
        }
    }
    
    func calcuateDaysBetweenTwoDates(start: Date, end: Date) -> Int {
        
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }
    
    
    // Cell that user tapped on
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        myIndex = indexPath.row
        //print(tasks[myIndex])
        performSegue(withIdentifier: "segue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let task = tasks[indexPath.row]
            
            let alert = UIAlertController(title: "Delete: ", message: task.name, preferredStyle: UIAlertControllerStyle.alert)
            
            // Button
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action)  in
                
                alert.dismiss(animated: true, completion: nil)
                context.delete(task)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                do {
                    tasks = try context.fetch(Task.fetchRequest())
                }
                catch {
                    print("Fetching Failed")
                }
                tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (action)  in
                
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
            
        }
        
        delete.backgroundColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        
        let done = UITableViewRowAction(style: .normal, title: "Done") { action, index in
            
            let task = tasks[indexPath.row]
            
            if !task.isDoneToday {
            
                let alert = UIAlertController(title: "Confirm", message: "You have completed this task?", preferredStyle: UIAlertControllerStyle.alert)
                
                // Button
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action)  in
                    
                    alert.dismiss(animated: true, completion: nil)
                    
                    
                    task.setValue(true, forKey: "isDoneToday")
                    
                    //task.setValue(NSDate(), forKey: "lastVisitDate")
                    
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    
                    do {
                        tasks = try context.fetch(Task.fetchRequest())

                        // Difference between now and last time visited
                        //let timeDiff = CFDateGetTimeIntervalSinceDate(NSDate(), task.lastVisitDate) / 3600
                        
                        let dayDiff = self.calcuateDaysBetweenTwoDates(start: task.lastVisitDate! as Date, end: NSDate() as Date)
                        
                        // Occurs if the difference in time between last visited is over 24 hours but less than 48 hours
                        if dayDiff == 1 || task.streak < 1{
                            let newVal = (task.streak) + 1
                            task.setValue(newVal, forKey: "streak")
                            task.setValue(task.lastVisitDate, forKey: "prevLastVisitDate")
                            task.setValue(NSDate(), forKey: "lastVisitDate")

                        }
                            
                            // Occurs if the difference in time between last visited is less than 24 hours "Same day as completion"
                        else if dayDiff < 1 {
                            
                            print("Nothing changes same day")
                            
                            // Occurs if the difference in time between last visited is greater than 48 hours "Streak has been broken"
                        } else {
                            task.setValue(NSDate(), forKey: "lastVisitDate")
                            task.setValue(1, forKey: "streak")
                            task.setValue([], forKey: "logArr")

                        }
                        
                    } catch {
                        print("Fetching Failed")
                    }
                    
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    
                    tableView.reloadData()
                    
                    let logAlert = UIAlertController(title: "Daily Log", message: "What did you accomplish today?", preferredStyle: UIAlertControllerStyle.alert)
                    
                    // Text field
                    logAlert.addTextField(configurationHandler: { (textField) in
                        textField.text = "Your Log"
                    })
                    
                    // Button
                    logAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action)  in
                        let textField = logAlert.textFields![0].text
                        let textFieldText = "\(textField ?? "No Log Today")"
                        
                        
                        log = task.logArr as! [String]
                        log.append(textFieldText)
                        
                        //print(log)
                        task.setValue(log, forKey: "logArr")

                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        
                        
                        logAlert.dismiss(animated: true, completion: nil)

                    }))
                    
                    
                    self.present(logAlert, animated: true, completion: nil)
                    
                    
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (action)  in
                    
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
            
            }
            
            
        }
        
        done.backgroundColor = UIColor(red:0.18, green:0.80, blue:0.44, alpha:1.0)
        
        
        return [delete, done]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    

}

