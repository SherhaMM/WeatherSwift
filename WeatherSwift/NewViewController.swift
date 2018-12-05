//
//  NewViewController.swift
//  WeatherSwift
//
//  Created by Makcim Mikhailov on 20.11.18.
//  Copyright © 2018 Makcim Mikhailov. All rights reserved.
//

import UIKit
import SQLite3
import Foundation

protocol DataEnteredDelegate: class {
    func userDidEnterInformation(info: String)
}
 class NewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  /*  func openDatabase() -> OpaquePointer? {
        var db: OpaquePointer? = nil
        if sqlite3_open(part1dbPath, &db) == SQLITE_OK {
            print("Database Opened")
            return db
        } else {
            print("db problems")
            return nil
        }
    }
    let db = openDatabase()
 */
    var cities: [String] = ["Odessa Ua", "Moscow", "Kiev", "Minsk" ]
    let cellReuseIdentifier = "cell"
    
    weak var delegate: DataEnteredDelegate? = nil
    var tappedCityName: String?
    
    @IBOutlet weak var cityListLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
   

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        cell.textLabel?.text = self.cities[indexPath.row]
        return cell
    }

    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cityListLabel.text = "\(self.cities[indexPath.row])"
       tappedCityName = "\(self.cities[indexPath.row])"
        let vc = storyboard?.instantiateViewController(withIdentifier: "mainPage") as! ViewController
        vc.seguedCity = "\(self.cities[indexPath.row])"
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title : "Edit" , handler: { (action,indexPath) in
            
            let alert = UIAlertController(title: "Edit this column", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"Cancel",style: .cancel, handler: nil))
            alert.addTextField(configurationHandler: { textField in
                textField.text = "\(self.cities[indexPath.row])"
                
            })
            alert.addAction(UIAlertAction(title:"Ok", style: .default, handler: {action in
                
                if let name = alert.textFields?.first?.text {
                    self.cities[indexPath.row] = "\(name)"
                    tableView.reloadData()
                    
                }
            }))
            self.present(alert, animated: true)
        })
        editAction.backgroundColor = UIColor.blue
        
        let deleteAction = UITableViewRowAction( style: .default, title:"Delete" , handler: { (action,indexPath) in
           self.cities.remove(at: indexPath.row)
             tableView.deleteRows(at: [indexPath], with: .fade)
        })
        deleteAction.backgroundColor = UIColor.red
        
        return [deleteAction,editAction]
    }
    
    @IBAction func addButton(_ sender: Any) {
        
        let alert1 = UIAlertController(title: "Add new city", message: nil, preferredStyle: .alert)
        alert1.addAction(UIAlertAction(title:"Cancel",style: .cancel, handler: nil))
        alert1.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your city"
        })
          alert1.addAction(UIAlertAction(title:"Ok", style: .default, handler: {action in
        if let cityToAdd = alert1.textFields?.first?.text , cityToAdd != "" {
           self.cities.append("\(cityToAdd)")
           self.tableView.reloadData()
          //  self.cities.insert("\(cityToAdd)", at: self.cities.count)
            }
          }))
        self.present(alert1, animated: true)
    }
    
    
    
    @IBAction func popLastView(_ sender: Any) {
        delegate?.userDidEnterInformation(info: tappedCityName!)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(self.cities,forKey: "mainKey")
    }
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if let array = defaults.array(forKey: "mainKey") {
            self.cities = array as! [String]
        }
    }
    
}

