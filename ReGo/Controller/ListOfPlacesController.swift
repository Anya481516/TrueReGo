//
//  ListOfPlacesController.swift
//  ReGo
//
//  Created by Анна Мельхова on 27.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import CoreLocation

class ListOfPlacesController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
      
        
        cell.addressLabel.text = places[indexPath.row].address
        cell.titleLabel.text = places[indexPath.row].title
        var distance = places[indexPath.row].distance
        var km = Int(distance / 1000)
        var meters = Int(distance - Double(km * 1000))
        var zeros = ""
        if (meters < 10){
            zeros = "00"
        }
        else if (meters < 100){
            zeros = "0"
        }
        cell.disanceLabel.text = String("\(km).\(zeros)\(meters)")
        
        if places[indexPath.row].subtitle == "Bottles"{
            cell.avatarImageView.image = UIImage(named: "Bottle")
        }
        else if places[indexPath.row].subtitle == "Batteries"{
            cell.avatarImageView.image = UIImage(named: "Battery")
        }
        else if places[indexPath.row].subtitle == "Bulbs"{
            cell.avatarImageView.image = UIImage(named: "Bulb")
        }
        else if places[indexPath.row].subtitle == "BatteriesAndBulbs"{
            cell.avatarImageView.image = UIImage(named: "BatteryBulb")
        }
        else if places[indexPath.row].subtitle == "Other"{
            cell.avatarImageView.image = UIImage(named: "IconOtherFoAdding")
        }
        
        return cell
    }
    
    
    //MARK:_variables:
    
    // MARK:- IBOutlets:
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bottlesButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var batteriesButton: UIButton!
    @IBOutlet weak var bulbsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLang()
        
        print(places.count)
        
        countDistanes(list: places)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        self.configureTableView()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLang()
        countDistanes(list: places)
        self.tableView.reloadData()
    }
    
    //MARK:- IBActions:
    @IBAction func allButtonPressed(_ sender: Any) {
        countDistanes(list: places)
    }
    @IBAction func bottlesButtonPressed(_ sender: Any) {
        countDistanes(list: bottlePlaces)
    }
    @IBAction func batteriesButtonPressed(_ sender: Any) {
        countDistanes(list: batteryPlaces)
    }
    @IBAction func bulbsButtonPressed(_ sender: Any) {
        countDistanes(list: bulbPlaces)
    }
    
    
    // MARK:-METHODS:
    func updateLang(){
        titleLabel.text = myKeys.list.listOfPlacesTitle
        allButton.setTitle(myKeys.list.all, for: .normal)
        bottlesButton.setTitle(myKeys.list.bottles, for: .normal)
        batteriesButton.setTitle(myKeys.list.batteries, for: .normal)
        bulbsButton.setTitle(myKeys.list.bulbs, for: .normal)
        
    }
    
    func countDistanes(list: [Place]){
        for place in list {
            place.distance = Double(CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude).distance(from: currectLocation))
        }
    }
    
    func configureTableView() {
        tableView.rowHeight = 90
        tableView.estimatedRowHeight = 120
    }
    
}
