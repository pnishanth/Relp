//
//  RestaurantList.swift
//  Relp
//
//  Created by Nishanth P on 2/23/17.
//  Copyright © 2017 Nishapp. All rights reserved.
//

import UIKit

class RestaurantList: UITableViewController {


    let identifer : String = "relpCell"
    let API : String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=40.7589,-73.9851&radius=500&types=food&name=restaurant&key=AIzaSyAZzPfNO8KSatKBRCYaFUjL8WwdcX-ugbk"
    
    var restaurants:[Restaurant] = [Restaurant]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "Rest2.jpg"))
        self.title = "Relp"
        restaurantAPI(API) { (array) in
            
            self.restaurants = array
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }

        }
        
    
        
    }
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return restaurants.count
    }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifer , for: indexPath) as! RestTableCell
        
        let restaurant = restaurants[indexPath.row]
        //let red = UIColor(red: 100.0/255.0, green: 130.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        cell.tabAlterView?.backgroundColor = UIColor(red: 138.0/255.0, green: 215.0/255.0, blue: 203.0/255.0, alpha: 1.0)
            
        let url = NSURL(string: "\(restaurant.icon)")
        let data = NSData(contentsOf: url as! URL)
            
        cell.relpImage.image = UIImage(data: data as! Data)
        cell.name.text = restaurant.name!
        cell.price.text = price(price:restaurant.price!)
    

        return cell
            
    }
    
    
    func price(price:Int) -> String {
        
        var priceStr:String?
        
        switch price{
            
        case 0:
            priceStr = "free"
        case 1:
            priceStr = "$"
        case 2:
            priceStr = "$$"
        case 3:
            priceStr = "$$$"
        case 4:
            priceStr = "$$$$"
        case 5:
            priceStr = "N/A"
        
        default:
            priceStr = ""
        }
        return priceStr!
        
    }
    

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "details" {
            
            let viewVC = segue.destination as! ViewController
            let indexPath = tableView.indexPathForSelectedRow
            let index = indexPath!.row
            let restaurantSelected = restaurants[index]
            
            viewVC.restaurant = restaurantSelected
            
        }
        
    }
    

}



extension RestaurantList{
    
    func restaurantAPI(_ urlString:String, completion:@escaping (_ array:[Restaurant]) ->()){
        
        
        var restArray : [Restaurant] = [Restaurant]()
        var openNow:Bool = false
        
        let url = URL(string:urlString)
        let urlSessionTask = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error == nil{
                
                if let validData = data{
                    
                    do {
                        
                        let jsonDict = try JSONSerialization.jsonObject(with: validData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            let reslist = jsonDict["results"] as! NSArray
                        for restaurantType in reslist{
                            
                            let restaurant = restaurantType as! NSDictionary
                            let icon = restaurant["icon"] as! String
                            let name = restaurant["name"] as! String
                            let geometry = restaurant["geometry"] as! NSDictionary
                            
                            if let openingHours = restaurant["opening_hours"] as? NSDictionary {
                                openNow = openingHours["open_now"] as! Bool
                            }
            
                            let location = geometry["location"] as! NSDictionary
                            let latitude = location["lat"] as! Double
                            let longitude = location["lng"] as! Double
                            
                            let address = restaurant["vicinity"] as! String
                            let rating = restaurant["rating"] as? Int ?? 0
                            let price = restaurant["price_level"] as? Int ?? 5
                            
                            DispatchQueue.main.async {
                                let newRestaurant = Restaurant(name:name, lat:latitude, long:longitude, address:address, open:openNow, rating:rating, price:price,icon:icon)
                                restArray.append(newRestaurant)
                                
                                completion(restArray)
                                
                            }
                            
                           
                        }

                    }
                    catch {
                        print(error.localizedDescription)
                    }//do
                    
                }//if
                
                
            }//if
            
        }//task
        
        urlSessionTask.resume()
        
        
    }
    
   
}
