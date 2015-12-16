//
//  CoreLocationViewController.swift
//  CoreLocationDemo
//
//  Created by Teng on 11/26/15.
//  Copyright © 2015 Teng. All rights reserved.
//

import UIKit
import CoreLocation

class CoreLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager? = nil
    var pointLocation:CLLocation? = nil
    
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startLocate(sender: AnyObject) {
        let authorityStatus = CLLocationManager.authorizationStatus()
        if getAuthorizationFromUser(authorityStatus) {
            startStandardUpdates()
        }
    }
    func startStandardUpdates() {
        if (locationManager == nil) {
            locationManager = CLLocationManager()
        }
        
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
//        locationManager!.distanceFilter = 500   //500米
        
        locationManager!.startUpdatingLocation()
    }
    
    
    func getAuthorizationFromUser(status: CLAuthorizationStatus) -> Bool {
        
        var userIsAgreeUseLocaiton = false
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            //允许使用定位
            userIsAgreeUseLocaiton = true
        case .Denied, .Restricted:
            //没有获得授权，不允许使用定位
            //给用户提示，请求获得授权
            let alertController = UIAlertController(
                title: "定位权限被禁用",
                message: "请打开app的定位权限以获得当前位置信息",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "设置", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        case .NotDetermined:
            //向用户申请授权
            locationManager = CLLocationManager()
            self.locationManager!.requestWhenInUseAuthorization()
            
            userIsAgreeUseLocaiton = true
        }
        return userIsAgreeUseLocaiton
    }
    
    //locationManager定位失败时delegate会调用该函数通知App
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        if let locationError = CLError(rawValue: error.code) {

            switch locationError {
            case .LocationUnknown:
                print("无法获得当前定位")
            case .Network:
                print("网络异常，无法获得当前定位")
            case .Denied:
                print("用户拒绝App使用定位服务")
            default:
                print("其他原因导致无法使用定位服务")
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        //停止定位定位更新以降低能耗
        locationManager?.stopUpdatingLocation()
        
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            self.pointLocation = currentLocation
            
            self.longitudeLabel.text = "\(currentLocation.coordinate.longitude)"
            self.latitudeLabel.text = "\(currentLocation.coordinate.latitude)"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapView" {
            
            if let location = self.pointLocation {
                let nextController = segue.destinationViewController as! MapViewController
                nextController.coreLocatinPoint = location
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        //当用户修改定位权限时给用户提示申请定位权限
        if getAuthorizationFromUser(status) {
            startStandardUpdates()
        }
    }
}
