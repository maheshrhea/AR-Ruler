//
//  MainViewController.swift
//  AR Ruler
//
//  Created by Rhea Mahesh on 7/16/18.
//  Copyright © 2018 Rhea Mahesh. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var messageTableView: UITableView!
    

    var objArray : [Name] = [Name]()
    
    var date = NSDate()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objArray.count
    }
    
    /*func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }*/
    /*func deleteDate(name: String){
        let nameDB = FIRDatabase.database().reference().child("Names")
        nameDB.child(name).setValue(nil)
    }*/
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
            
            objArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let nameDB = FIRDatabase.database().reference().child("Names").child(cell.uid!)
            nameDB.removeValue()
        }
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableViewCell
        
        cell.name.text = objArray[indexPath.row].savedName
        cell.result.text = objArray[indexPath.row].savedResult
        cell.date.text = objArray[indexPath.row].savedDate
        cell.uid = objArray[indexPath.row].uid
        
        //Removes the selection option for users
        tableView.allowsSelection = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 1{
            cell.backgroundColor = UIColor.lightGray
        }
    }
    
   

    override func viewDidLoad() {
        super.viewDidLoad()

        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTableView.register(UINib(nibName: "nameCell", bundle: nil), forCellReuseIdentifier: "tableCell")
        
        configureTableView()
        
        retrieveNames()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveNames(){
        let nameDB = FIRDatabase.database().reference().child("Names")
        nameDB.observe(.childAdded, with: { (snapshot) in
            let snapshotVal = snapshot.value as! Dictionary<String, String>
            let text = snapshotVal["Name"]!
            let result = snapshotVal["Result"]!
            
            let name = Name()
            name.savedName = text
            name.savedResult = result
            name.uid = snapshot.key
            
            let dateFormmater = DateFormatter()
            dateFormmater.dateFormat = "MMMM yyyy"
            name.savedDate = dateFormmater.string(from: Date())
                
            self.objArray.append(name)
            self.configureTableView()
            self.messageTableView.reloadData()
        })
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
