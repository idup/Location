//
//  ViewController.swift
//  CoreLocationDemo
//
//  Created by Teng on 11/26/15.
//  Copyright © 2015 Teng. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, SetPointDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapType: UISegmentedControl!
    
    var pointItem:MKMapItem?
    var coreLocatinPoint:CLLocation?
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.zoomEnabled = true
        mapView.showsCompass = true
        mapView.showsScale = true
        
        if let location = coreLocatinPoint {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)

            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = "你的位置"
            annotation.subtitle = "CoreLocation获得的定位"
            mapView.addAnnotation(annotation)
        }
        
        self.mapView.userTrackingMode = .Follow
        self.mapView.mapType = .Standard
        
        let locationAuthorization = CLLocationManager.authorizationStatus()
        CoreLocationViewController().getAuthorizationFromUser(locationAuthorization)
    }
    
    func setPointInMap(point: MKMapItem) {
        pointItem = point
        self.navigationController?.title = point.name
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mapType.selectedSegmentIndex = 0
        
        if let item = self.pointItem {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: item.placemark.location!.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = item.placemark.location!.coordinate
            annotation.title = item.name
            annotation.subtitle = item.placemark.name
            mapView.addAnnotation(annotation)
        }
        
        
        
    }
    
    @IBAction func searchPlace(sender: AnyObject) {
        //地图查找，用一个AlertView来获得要查找的信息，然后在tableView中显示查找到的内容，点击cell可以在地图上显示该点（放置一个大头针）
        
        //弹出Alert
        let alertVC = UIAlertController(title: "查找", message: "请输入你想要查找的地点", preferredStyle: .Alert)
        
        var searchContentField:UITextField?
        alertVC.addTextFieldWithConfigurationHandler(){ (textField) in
            searchContentField = textField
            searchContentField?.placeholder = "想要查找的地点"
        }
        
        alertVC.addAction(UIAlertAction(title: "确认", style: .Default, handler: { (alert:UIAlertAction) in
            
            let searchContent = searchContentField!.text
            //开始查找
            
            if let content = searchContent {
                let request = MKLocalSearchRequest()
                request.naturalLanguageQuery = content
                request.region = self.mapView.region
                
                let search = MKLocalSearch(request: request)
                search.startWithCompletionHandler { (response, error) in
                    //需要显示个正在查找的图标
                    
                    
                    guard let response = response else {
                        print("Search error: \(error)")
                        return
                    }
                    
                    //将查找结果显示在TableView中
                    let resultTableView = self.storyboard!.instantiateViewControllerWithIdentifier("SearchResultTableViewController") as! MapSearchReusltTableViewController
                    resultTableView.resultArray = response.mapItems
                    resultTableView.setPointDelegate = self
                    
                    self.navigationController?.pushViewController(resultTableView, animated: true)
                }
            }
            
        }))
        alertVC.addAction(UIAlertAction(title: "取消", style: .Default, handler: nil))
        
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func changeMapType(sender: UISegmentedControl) {
        switch mapType.selectedSegmentIndex {
        case 0:
            mapView.mapType = .Standard
        case 1:
            mapView.mapType = .Satellite
        default:
            mapView.mapType = .Hybrid
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(userLocation.location!) { (placemarks, error) -> Void in
            if (placemarks?.count == 0 || error == nil) {
                print("Can't find place")
                return
            }
            
            let pm = placemarks?.first
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: (pm!.location?.coordinate)!, span: span)
            self.mapView.setRegion(region, animated: true)
            userLocation.title = "MapKit获得的定位"
            userLocation.subtitle = "你的当前位置"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
