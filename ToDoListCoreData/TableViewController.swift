//
//  TableViewController.swift
//  ToDoListCoreData
//
//  Created by Chris Pickett on 2017-07-31.
//  Copyright © 2017 Chris Pickett. All rights reserved.
//

import UIKit



class TableViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!

    @IBOutlet weak var myCollectionView: UICollectionView!
    var timer = Timer()
    var isRunning = false
    var calendarLength = 21
    
    let array: [String] = ["check", "empty"]
    var checkNum = Int(tasks[myIndex].streak)
    
    
    @IBAction func DescBtn(_ sender: Any) {
    
        let alert = UIAlertController(title: "Description", message: tasks[myIndex].desc, preferredStyle: UIAlertControllerStyle.alert)
        
        // Button
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: { (action)  in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = tasks[myIndex].name
        streakLabel.text = "Streak: " + String(tasks[myIndex].streak)

        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        let itemSize = UIScreen.main.bounds.width / 6 - 3
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        
        layout.scrollDirection = .vertical
        
        myCollectionView.collectionViewLayout = layout
        
        setTimeLeft()
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
    
    
    // Number of views
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarLength
    }
    
    // Populate view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! myCell
        
        if checkNum > 0 {
            cell.myImageView.image = UIImage(named: "check.png")
            cell.isChecked = true
            checkNum -= 1
            
        } else {
            cell.myImageView.image = UIImage(named: "empty.png")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let isIndexValid = (tasks[myIndex].logArr as! [String]).indices.contains(indexPath.row)
        
        if isIndexValid {
            //print(tasks[myIndex].logArr![indexPath.row])
            let dailyLog = "\(tasks[myIndex].logArr![indexPath.row])"
            
            let logAlert = UIAlertController(title: "Day \(indexPath.row + 1)", message: dailyLog, preferredStyle: UIAlertControllerStyle.alert)

            
            // Button
            logAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action)  in
                
                logAlert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(logAlert, animated: true, completion: nil)
            
            
        } else {
            //print("Does not exist")
            let dailyLog = "COMING UP"
            
            let logAlert = UIAlertController(title: "Day \(indexPath.row + 1)", message: dailyLog, preferredStyle: UIAlertControllerStyle.alert)
            
            
            // Button
            logAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action)  in
                
                logAlert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(logAlert, animated: true, completion: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isRunning {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TableViewController.setTimeLeft), userInfo: nil, repeats: true)
            isRunning = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
        isRunning = false
    }
    
    func setTimeLeft() {
        
        var tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        let gregorian = Calendar(identifier: .gregorian)
        var tComponents =  gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: tomorrow)
        tComponents.hour = 0
        tComponents.minute = 0
        tComponents.second = 0
        
        tomorrow = gregorian.date(from: tComponents)!

        let timeEnd = tomorrow
        let timeNow = Date()
        
        
        // Only keep counting if timeEnd is bigger than timeNow
        if timeEnd.compare(timeNow) == ComparisonResult.orderedDescending && tasks[myIndex].streak > 0 {
            let calendar = NSCalendar.current
            
            let unitFlags = Set<Calendar.Component>([.day, .hour, .minute, .second])
            let components = calendar.dateComponents(unitFlags, from: timeNow, to: timeEnd as Date)

            var hourText = "\(components.hour ?? 0) h "
            let minuteText = "\(components.minute ?? 0) m "
            let secondText = "\(components.second ?? 0) s "
            
            // Hide hour if they are zero
            if components.hour! <= 0 {
                hourText = ""
            }
            
            timerLabel.text = "\(hourText) \(minuteText) \(secondText)"
            timerLabel.textColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
            
        } else {
            timerLabel.text = "NOT STARTED"
            timerLabel.textColor = UIColor(red:0.95, green:0.77, blue:0.06, alpha:1.0)
            timer.invalidate()
            isRunning = false
        }
        
        if tasks[myIndex].isDoneToday {
            timerLabel.text = "COMPLETED"
            timerLabel.textColor = UIColor(red:0.18, green:0.80, blue:0.44, alpha:1.0)
        }
    }
    
    func hourToString(hour:Double) -> String {
        let hours = Int(floor(hour))
        //let mins = Int(round(hour * 60) % 60)
        let mins = Int((hour * 60).truncatingRemainder(dividingBy: 60))
        //let secs = Int(round(hour * 3600) % 60)
        let secs = Int((hour * 3600).truncatingRemainder(dividingBy: 60))
        
        return String(format:"%d:%02d:%02d", hours, mins, secs)
    }
    

}
