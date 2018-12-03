// Celldrive code 7 march 2018
//  ViewController.swift
//  Celldrive
//
//  Created by ramya  on 16/02/18./Users/venkatakrishnan/Desktop/CellDriveIOS/CellDriveIOS/ViewController.swift
//  Copyright © 2018 ramya . All rights reserved.
//

import UIKit
import CoreLocation
import CoreTelephony
import CallKit
import UserNotifications

class ViewController: UIViewController {
   
    let sharedPref = UserDefaults.standard
    var currentLocation: CLLocation!
    var locManager = CLLocationManager()
    @IBOutlet var mts_txt: UITextField!
    var callObs : CXCallObserver!
    var callObserver: CXCallObserver!
    @IBOutlet var txt_meters: UILabel!
    var bgTask = UIBackgroundTaskIdentifier()
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var registered : Bool = false
    @IBOutlet var stackOTP: UIStackView!
    @IBOutlet var stackSuccess: UIStackView!
    @IBOutlet var phone_txt: UITextField!
    @IBOutlet var email_txt: UITextField!
    @IBOutlet var stackRegister: UIStackView!
    @IBOutlet var name_txt: UITextField!
    
    @IBOutlet var txt_log: UILabel!
    @IBOutlet weak var otp_txt: UITextField!
    
    @IBOutlet var txtcallstatus: UILabel!
    @IBOutlet var txtmapping: UILabel!
    @IBOutlet var txtspeedcondition: UILabel!
    @IBOutlet var txtbuildversion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let versionNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        let versionAndBuildNumber: String = "\(versionNumber) (\(buildNumber))"

        txtbuildversion.text="Build Version:\(versionAndBuildNumber)"
        
        txtmapping.text="Mapped to: Production"
        if(self.sharedPref.double(forKey: "mts") == 0){
        let mts = 250
        self.sharedPref.setValue(mts, forKey: "mts")
        }
        txtcallstatus.text="Call status: Not Initiated"
        self.sharedPref.setValue(false, forKey: "clstate")//flag for call state setting false as default
     //   print("token:\(self.sharedPref.string(forKey: "token"))")
    //    print("mts 1:\( self.sharedPref.double(forKey: "mts"))")
        txt_meters.text = "saved Mts successfully :\( self.sharedPref.double(forKey: "mts"))"
        // Get User Authorization to use send/receive Notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound], completionHandler: {didallow, error in })
        // Get User Authorization to use Location Services
        self.locManager.requestAlwaysAuthorization()
        if(self.sharedPref.string(forKey: "token") != nil){
            registerBackgroundTask()//to start background task
            startTask()//to start the task which should be loaded when user enters app
        //runs if already registered user
        self.stackRegister.isHidden = true
        self.stackOTP.isHidden = true
        self.stackSuccess.isHidden = false
    }
    else{
    //for new user
    self.stackRegister.isHidden = false
    self.stackOTP.isHidden = true
    self.stackSuccess.isHidden = true
    }
        
    }

    func startTask(){
        self.locManager.requestAlwaysAuthorization()
        if self.sharedPref.string(forKey: "token") != nil{//checks if the user is registered or not
    //        print("mts 2:\( self.sharedPref.double(forKey: "mts"))")
            txt_meters.text = "Saved Mts :\( self.sharedPref.double(forKey: "mts"))"
            //checks for authorization for location service
            let authorizationStatus = CLLocationManager.authorizationStatus()
            if authorizationStatus != .authorizedAlways {
                // User has not authorized access to location information.
                return
            }
            //checks the location service is enabled or not
            
            if CLLocationManager.locationServicesEnabled() {
                locManager.delegate = self as CLLocationManagerDelegate

                //added new on 31-5-2018
                locManager.startMonitoringSignificantLocationChanges()
                // locationManager.allowsBackgroundLocationUpdates = true
                locManager.pausesLocationUpdatesAutomatically = true
      //          print("pause: true")
             
            }
            if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
                // The service is not available.
                return
            }
        }
          
    }
    func registerBackgroundTask() {
        //registering background task
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
        self.locManager.requestAlwaysAuthorization()
        //print("mts 3:\( self.sharedPref.double(forKey: "mts"))")
        txt_meters.text = "Saved Mts :\( self.sharedPref.double(forKey: "mts"))"
        //print("bg task started")
        if self.sharedPref.string(forKey: "token") != nil{//checks for token exits in shared preference
            let authorizationStatus = CLLocationManager.authorizationStatus()
            if authorizationStatus != .authorizedAlways {
                // User has not authorized access to location information.
                return
            }
            if CLLocationManager.locationServicesEnabled() {
                locManager.delegate = self as CLLocationManagerDelegate

                //added new on 31-5-2018
                locManager.startMonitoringSignificantLocationChanges()
                // locationManager.allowsBackgroundLocationUpdates = true
                locManager.pausesLocationUpdatesAutomatically = false
          //      print("pause: false")
     
            }
            if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
                // The service is not available.
                return
            }
            
        }
    }
    
    @IBAction func SaveMts(_ sender: Any) {
        self.locManager.requestAlwaysAuthorization()
        let mts = mts_txt.text
        self.sharedPref.setValue(mts, forKey: "mts")
        //print("mts 0:\( self.sharedPref.double(forKey: "mts"))")
        mts_txt.text = ""
        txt_meters.text = "saved Mts successfully :\( self.sharedPref.double(forKey: "mts"))"
        registerBackgroundTask()//to start background task
        startTask()//to start the task which should be loaded when user enters app
    }
    func endBackgroundTask() {
        //end background task
       // print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func receivedType2() {
        //print("called function receivedType2")
        self.sharedPref.setValue(0, forKey: "parent")
        let  parent = self.sharedPref.integer(forKey: "parent")
        //print("inc_parent receivedType2: \(parent)")
        self.sharedPref.setValue(false, forKey: "clstate")
        //print("call state flag receivedType2:\(self.sharedPref.bool(forKey: "clstate"))")

    }
    
    //button click event for user registration
    @IBAction func RegisterBtn(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let fcmtokenvalue = delegate.fc
        //print("app delegate var fc:\(fcmtokenvalue)")
        
        let name = name_txt.text
        let email = email_txt.text
        let phone = phone_txt.text
        let parameters = ["name": String(name!),"email": String(email!),"phone":String(phone!),"fcm_token":String(fcmtokenvalue!)]
        //for testing
        guard let url = URL (string: "http://ec2-54-191-172-248.us-west-2.compute.amazonaws.com/sandbox/v1/user/") else{ return}
        
        //for production
        //guard let url = URL (string: "http://ec2-54-191-172-248.us-west-2.compute.amazonaws.com/api/v1/user/") else{ return}
       // print("Parameters:\(parameters)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])else{ return}
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response{
         //       print("Response:\(response)")
                
            }
            if let data = data{
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    if let token = json!["token"]{
                        self.sharedPref.setValue(token, forKey: "token")
           //             print("TOKEN VALUE 1 : \(String(describing: self.sharedPref.string(forKey: "token")))")
                    }
                    
                }catch{
                    print(error)
                }
            }
            }.resume()
        
        self.stackOTP.isHidden = false
        self.stackRegister.isHidden = true
        self.stackSuccess.isHidden = true
    }
    //button click event for user verification
    @IBAction func VerifyBtn(_ sender: Any) {
        
        if let token = self.sharedPref.string(forKey: "token"){
            self.stackOTP.isHidden = true
            self.stackRegister.isHidden = true
            self.stackSuccess.isHidden = false
            print("TOKEN VALUE 2 : \(token)")
            let otp = otp_txt.text

            let parameters = ["otp": otp]
            let auth = "JWT \(token)"
            //for testing
           guard let url = URL (string: "http://ec2-54-191-172-248.us-west-2.compute.amazonaws.com/sandbox/v1/user/verify/") else{ return}
            //for production
          // guard let url = URL (string: "http://ec2-54-191-172-248.us-west-2.compute.amazonaws.com/api/v1/user/verify/") else{ return}

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])else{ return}
            request.httpBody = httpBody
            request.addValue(auth, forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let response = response{
                    print("Response:\(response)")
                    self.registerBackgroundTask()
                    self.startTask()
                }
                if let error = error{
                    print("Error:\(error)")
                }
                if let data = data{
                    print("Data:\(data)")
                }
                
                }.resume()
            
        }
        
    }
    
}
//delegate function for notification handling
extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        // some other way of handling notification
        completionHandler([.alert, .sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        
        completionHandler()
        
    }
    
}
//delegate function for location changes
extension ViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        // Do something with the location.

        let actualspeed="Speed: "+String(location.speed)
        txt_log.text=actualspeed
        print(actualspeed)
        
        //added new on 31-5-2018
        locManager.pausesLocationUpdatesAutomatically = false
        print("pause: false")
        for currentLocation in locations{
            print("\(index): \(currentLocation)")
        }
        //locManager.activityType = CLActivityType.automotiveNavigation
     
        print("call state flag:\(self.sharedPref.bool(forKey: "clstate"))")
        txtspeedcondition.text="SpeedCondition: 2"

        //checks if user speed exceeds 2 miles/sec
        if(Double((locManager.location?.speed)!) >= 2){
            //starting call observer to check user is in call or not
            self.callObs = CXCallObserver()
            self.callObs.setDelegate(self as CXCallObserverDelegate, queue: nil)
            print("Monitoring Calls")
            txtcallstatus.text="Call status: Monitoring Calls"
            
            //check for call state flag
        if self.sharedPref.bool(forKey: "clstate") == true {
            //checks for token is valid
            if let token = self.sharedPref.string(forKey: "token"){
                //first time parent value is 0, after 1st incident save in server its value increases by the value returned as response string
                let  parent = self.sharedPref.integer(forKey: "parent")
                print("inc_parent 1: \(parent)")
                
                //getting user location parameters
                let inc_lng = locManager.location?.coordinate.longitude
                let inc_lat = locManager.location?.coordinate.latitude
                let inc_speed = locManager.location?.speed

                //starting async task for incident reporting to server
                DispatchQueue.main.async(execute:{
                    let auth = "JWT \(token)"
                    let parameters = ["inc_lat": Float(inc_lat!),"inc_lng": Float(inc_lng!),"inc_speed":Float(inc_speed!),"inc_summary":"from ios - testing","inc_parent":parent] as [String : Any]
                    print("inc_parent 2: \(parent)")
                    print("parameter:\(parameters)")
                    //for testing
                    guard let url = URL (string: "http://ec2-54-191-172-248.us-west-2.compute.amazonaws.com/sandbox/v1/user/incident") else{ return}
                    //for production
               // guard let url = URL (string: "http://ec2-54-191-172-248.us-west-2.compute.amazonaws.com/api/v1/user/incident") else{ return}

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])else{ return}
                    request.httpBody = httpBody
                    request.addValue(auth, forHTTPHeaderField: "Authorization")
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    let session = URLSession.shared
                    session.dataTask(with: request) { (data, response, error) in
                        if let response = response{
                            print("Response:\(response)")
                        }
                        if let data = data{
                            do{
                                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                                if let parent_id = json!["parent_id"]{
                                    print("parent id : \(parent_id)")

                                    self.sharedPref.setValue(parent_id, forKey: "parent")
                                    let  parent = self.sharedPref.integer(forKey: "parent")
                                    print("parent: \(parent)")
                                }
                                
                            }catch{
                                print(error)
                            }
                        }
                        
                        }.resume()
                })
                
            }
        } else{}
        
         }
        
    }
    
}
//call observer delegate fired when started monitoring calls
extension ViewController : CXCallObserverDelegate
{
    func callObserver(_: CXCallObserver, callChanged: CXCall)
    {
        //Check if callObserver has fired...
        print("callObserver has fired...")
        
        //fired when user call state ended
        if(callChanged.hasEnded)
        {
            txtcallstatus.text="Call status: call ended"
            print("Call Ended")
            self.sharedPref.setValue(0, forKey: "parent")
            let  parent = self.sharedPref.integer(forKey: "parent")
            print("inc_parent 4: \(parent)")
            self.sharedPref.setValue(false, forKey: "clstate")

        }
            //fired when user call state dialing

        else if callChanged.isOutgoing == true && callChanged.hasConnected == false {
            txtcallstatus.text="Call status: call dialing"

            print("Dialing")
        }
            //fired when user call state incoming

        else if callChanged.isOutgoing == false && callChanged.hasConnected == false && callChanged.hasEnded == false {
            print("Incoming")
            txtcallstatus.text="Call status: call incoming"

        }
            //fired when user call state connected

        else if callChanged.hasConnected == true && callChanged.hasEnded == false {
            print("Connected")
            txtcallstatus.text="Call status: call connected"
            //set flag for call state
            self.sharedPref.setValue(true, forKey: "clstate")

        }
        
    }
    
}



