//
//  ListOfPlacesController.swift
//  ReGo
//
//  Created by Анна Мельхова on 27.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class ListOfPlacesController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate {
    
    //MARK:_variables:
    
    // MARK:- IBOutlets:
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bottlesButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var batteriesButton: UIButton!
    @IBOutlet weak var bulbsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var type = "All"
    var refreshControl = UIRefreshControl()

    
    // MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        
        updateLang()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        self.configureTableView()
        //retrieveLists()
        
        tableView.separatorStyle = .none
        allButton.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
        allButton.setTitleColor(UIColor(named: "WhiteBlack"), for: .normal)
        
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        locationManager.startUpdatingLocation()
        
       retrieveLists()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLang()
        //retrieveLists()
    }
    
    //MARK:- IBActions:
    @IBAction func allButtonPressed(_ sender: Any) {
        type = "All"
        locationManager.startUpdatingLocation()
        retrieveLists()
        
        highlightSelectedButton(sender: sender as! UIButton)
    }
    @IBAction func bottlesButtonPressed(_ sender: Any) {
        type = "Bottles"
        locationManager.startUpdatingLocation()
        retrieveLists()
        
        highlightSelectedButton(sender: sender as! UIButton)
    }
    @IBAction func batteriesButtonPressed(_ sender: Any) {
        type = "Batteries"
        locationManager.startUpdatingLocation()
        retrieveLists()
        
        highlightSelectedButton(sender: sender as! UIButton)
    }
    @IBAction func bulbsButtonPressed(_ sender: Any) {
        type = "Bulbs"
        locationManager.startUpdatingLocation()
        retrieveLists()
        
        highlightSelectedButton(sender: sender as! UIButton)
    }
    
    
    // MARK:-METHODS:
    func updateLang(){
        titleLabel.text = myKeys.list.listOfPlacesTitle
        allButton.setTitle(myKeys.list.all, for: .normal)
        bottlesButton.setTitle(myKeys.list.bottles, for: .normal)
        batteriesButton.setTitle(myKeys.list.batteries, for: .normal)
        bulbsButton.setTitle(myKeys.list.bulbs, for: .normal)
        
    }
    
    // Location delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        currentLocation = locationManager.location!
        
//        if type == "Bottles"{
//            countDistanes(list: bottlePlaces)
//            bottlePlaces.sort(by: { $0.distance < $1.distance })
//        }
//        else if type == "Batteries"{
//            countDistanes(list: batteryPlaces)
//            batteryPlaces.sort(by: { $0.distance < $1.distance })
//        }
//        else if type == "Bulbs"{
//            countDistanes(list: bulbPlaces)
//            bulbPlaces.sort(by: { $0.distance < $1.distance })
//        }
//        else {
//            countDistanes(list: places)
//            places.sort(by: { $0.distance < $1.distance })
//        }
//
//        self.configureTableView()
//        self.tableView.reloadData()
    }
    
    // tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           
           if type == "Bottles"{
               return bottlePlaces.count
           }
           else if type == "Batteries"{
               return batteryPlaces.count
           }
           else if type == "Bulbs"{
               return bulbPlaces.count
           }
           else {
               return places.count
           }
           
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
           
           var distance = Double()
           if type == "Bottles"{
               distance = bottlePlaces[indexPath.row].distance
               cell.addressLabel.text = bottlePlaces[indexPath.row].address
               cell.titleLabel.text = bottlePlaces[indexPath.row].title
               
               if bottlePlaces[indexPath.row].subtitle == "Bottles"{
                   cell.avatarImageView.image = UIImage(named: "Bottle")
               }
               else if bottlePlaces[indexPath.row].subtitle == "Other"{
                   cell.avatarImageView.image = UIImage(named: "IconOtherFoAdding")
               }
           }
           else if type == "Batteries"{
               distance = batteryPlaces[indexPath.row].distance
               cell.addressLabel.text = batteryPlaces[indexPath.row].address
               cell.titleLabel.text = batteryPlaces[indexPath.row].title
               
               if batteryPlaces[indexPath.row].subtitle == "Batteries"{
                   cell.avatarImageView.image = UIImage(named: "Battery")
               }
               else if batteryPlaces[indexPath.row].subtitle == "BatteriesAndBulbs"{
                   cell.avatarImageView.image = UIImage(named: "BatteryBulb")
               }
               else if batteryPlaces[indexPath.row].subtitle == "Other"{
                   cell.avatarImageView.image = UIImage(named: "IconOtherFoAdding")
               }
           }
           else if type == "Bulbs"{
               distance = bulbPlaces[indexPath.row].distance
               cell.addressLabel.text = bulbPlaces[indexPath.row].address
               cell.titleLabel.text = bulbPlaces[indexPath.row].title
               
               if bulbPlaces[indexPath.row].subtitle == "Bulbs"{
                   cell.avatarImageView.image = UIImage(named: "Bulb")
               }
               else if bulbPlaces[indexPath.row].subtitle == "BatteriesAndBulbs"{
                   cell.avatarImageView.image = UIImage(named: "BatteryBulb")
               }
               else if bulbPlaces[indexPath.row].subtitle == "Other"{
                   cell.avatarImageView.image = UIImage(named: "IconOtherFoAdding")
               }
           }
           else {
               distance = places[indexPath.row].distance
               cell.addressLabel.text = places[indexPath.row].address
               cell.titleLabel.text = places[indexPath.row].title
               
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
           }
           
           let km = Int(distance / 1000)
           let meters = Int(distance - Double(km * 1000))
           var zeros = ""
           if (meters < 10){
               zeros = "00"
           }
           else if (meters < 100){
               zeros = "0"
           }
           cell.disanceLabel.text = String("\(km).\(zeros)\(meters) \(myKeys.list.km)")
           
           // картинки исправить йоу
           
           
           return cell
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var coordinates = CLLocationCoordinate2D()
        if type == "Bottles"{
            coordinates = bottlePlaces[indexPath.row].coordinate
        }
        else if type == "Batteries"{
            coordinates = batteryPlaces[indexPath.row].coordinate
        }
        else if type == "Bulbs"{
            coordinates = bulbPlaces[indexPath.row].coordinate
        }
        else {
            coordinates = places[indexPath.row].coordinate
        }
        
        selectedCoordinatesFromList = coordinates
        wasSelectedFromList = true
        tabBarController?.selectedIndex = 0;
    }
    
    func countDistanes(list: [Place]){
        for place in list {
            place.distance = Double(CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude).distance(from: currentLocation))
        }
    }
    
    func configureTableView() {
        tableView.rowHeight = 90
        tableView.estimatedRowHeight = 120
    }
    
    func highlightSelectedButton(sender: UIButton){
        allButton.backgroundColor = UIColor(named: "LightDarkGreen")
        allButton.setTitleColor(UIColor(named: "BlackWhite"), for: .normal)
        bottlesButton.backgroundColor = UIColor(named: "LightDarkGreen")
        bottlesButton.setTitleColor(UIColor(named: "BlackWhite"), for: .normal)
        batteriesButton.backgroundColor = UIColor(named: "LightDarkGreen")
        batteriesButton.setTitleColor(UIColor(named: "BlackWhite"), for: .normal)
        bulbsButton.backgroundColor = UIColor(named: "LightDarkGreen")
        bulbsButton.setTitleColor(UIColor(named: "BlackWhite"), for: .normal)
        
        sender.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
        sender.setTitleColor(UIColor(named: "WhiteBlack"), for: .normal)
    }
    
    func retrieveLists() {
        places.removeAll()
        bottlePlaces.removeAll()
        batteryPlaces.removeAll()
        bulbPlaces.removeAll()
        
        let messageDB = Firebase.Database.database().reference().child("Places")
        
        // when a child added
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,Any>
        
            let title = snapshotValue["Title"] as! String
            let address = snapshotValue["Address"] as! String
            let hasImage = snapshotValue["HasImage"] as! Bool
            let imageURL = snapshotValue["ImageURL"] as! String
            let longitude = snapshotValue["Longitude"] as! CLLocationDegrees
            let latitude = snapshotValue["Latitude"] as! CLLocationDegrees
            let type = snapshotValue["Type"] as! String
            let bottles = snapshotValue["Bottles"] as! Bool
            let batteries = snapshotValue["Batteries"] as! Bool
            let bulbs = snapshotValue["Bulbs"] as! Bool
            let other = snapshotValue["Other"] as! String
            let userID = snapshotValue["UserID"] as! String
            let id = snapshotValue["ID"] as! String
        
            //print(title, address, hasImage, imageURL, latitude, longitude, bottles, batteries, bulbs, other, userID)
        
            let place = Place()
            place.title = title
            place.subtitle = type // type
            place.hasImage = hasImage
            place.imageURLString = imageURL
            place.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            place.bottles = bottles
            place.batteries = batteries
            place.bulbs = bulbs
            place.other = other
            place.userId = userID
            place.address = address
            place.id = id
        
            places.append(place)
            self.countDistanes(list: places)
            places.sort(by: { $0.distance < $1.distance })
            
            if bottles {
                bottlePlaces.append(place)
                self.countDistanes(list: bottlePlaces)
                bottlePlaces.sort(by: { $0.distance < $1.distance })
            }
            if batteries {
                batteryPlaces.append(place)
                self.countDistanes(list: batteryPlaces)
                batteryPlaces.sort(by: { $0.distance < $1.distance })
            }
            if bulbs {
                bulbPlaces.append(place)
                self.countDistanes(list: bulbPlaces)
                bulbPlaces.sort(by: { $0.distance < $1.distance })
            }
            
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        messageDB.observe(.childChanged) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,Any>
            
            let title = snapshotValue["Title"] as! String
            let address = snapshotValue["Address"] as! String
            let hasImage = snapshotValue["HasImage"] as! Bool
            let imageURL = snapshotValue["ImageURL"] as! String
            let longitude = snapshotValue["Longitude"] as! CLLocationDegrees
            let latitude = snapshotValue["Latitude"] as! CLLocationDegrees
            let type = snapshotValue["Type"] as! String
            let bottles = snapshotValue["Bottles"] as! Bool
            let batteries = snapshotValue["Batteries"] as! Bool
            let bulbs = snapshotValue["Bulbs"] as! Bool
            let other = snapshotValue["Other"] as! String
            let userID = snapshotValue["UserID"] as! String
            let id = snapshotValue["ID"] as! String
            
            for place in places {
                if place.id == id {
                    place.title = title
                    place.subtitle = type
                    place.address = address
                    place.hasImage = hasImage
                    place.imageURLString = imageURL
                    place.coordinate.latitude = latitude
                    place.coordinate.longitude = longitude
                    place.bottles = bottles
                    place.batteries = batteries
                    place.bulbs = bulbs
                    place.other = other
                    place.userId = userID
                    place.address = address
                }
            }
            self.countDistanes(list: places)
            places.sort(by: { $0.distance < $1.distance })
            
            if bottles {
                for place in bottlePlaces {
                    if place.id == id {
                        place.title = title
                        place.subtitle = type
                        place.address = address
                        place.hasImage = hasImage
                        place.imageURLString = imageURL
                        place.coordinate.latitude = latitude
                        place.coordinate.longitude = longitude
                        place.bottles = bottles
                        place.batteries = batteries
                        place.bulbs = bulbs
                        place.other = other
                        place.userId = userID
                        place.address = address
                    }
                }
                self.countDistanes(list: bottlePlaces)
                bottlePlaces.sort(by: { $0.distance < $1.distance })
            }
            if batteries {
                for place in batteryPlaces {
                    if place.id == id {
                        place.title = title
                        place.subtitle = type
                        place.address = address
                        place.hasImage = hasImage
                        place.imageURLString = imageURL
                        place.coordinate.latitude = latitude
                        place.coordinate.longitude = longitude
                        place.bottles = bottles
                        place.batteries = batteries
                        place.bulbs = bulbs
                        place.other = other
                        place.userId = userID
                        place.address = address
                    }
                }
                self.countDistanes(list: batteryPlaces)
                batteryPlaces.sort(by: { $0.distance < $1.distance })
            }
            if bulbs {
                for place in bulbPlaces {
                    if place.id == id {
                        place.title = title
                        place.subtitle = type
                        place.address = address
                        place.hasImage = hasImage
                        place.imageURLString = imageURL
                        place.coordinate.latitude = latitude
                        place.coordinate.longitude = longitude
                        place.bottles = bottles
                        place.batteries = batteries
                        place.bulbs = bulbs
                        place.other = other
                        place.userId = userID
                        place.address = address
                    }
                    self.countDistanes(list: bulbPlaces)
                    bulbPlaces.sort(by: { $0.distance < $1.distance })
                }
            }
            
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}

