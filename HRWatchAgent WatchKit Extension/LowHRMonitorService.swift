import Foundation
import HealthKit
import MediaPlayer
import UserNotifications
import CoreLocation

public class LowHRMonitorService: ObservableObject{
    @Published var latest:String;
    @Published var hkStatus:String;
    @Published var latestTimeStamp:String;
    
    public var alarmRate:String="50";
    public var phoneAgentUrl:String="http://172.16.0.239:8400/";
    var queryAnchor: HKQueryAnchor?=nil
    let healthStore = HKHealthStore()
    let dateFormatter = DateFormatter()
    let sortByDate = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
    var timer:Timer?;
    let typesToShare: Set = [HKObjectType.quantityType(forIdentifier: .heartRate)!];
    var monitorEnabled:Bool=false;
    let locationManager = CLLocationManager()
    var lastSampleTimeSample = Date()
   
    init(){
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        self.latest="Not refreshed"
        self.hkStatus="Not Initialized"
        self.timer=nil
        self.latestTimeStamp="Not refreshed"
        
    }
    
    func startObserverQuery(){
        let query = HKObserverQuery(sampleType: HKObjectType.quantityType(forIdentifier: .heartRate)!, predicate: nil) { (query, completionHandler, errorOrNil) in
            
            if let error = errorOrNil {
                print(error)
                return
            }
            print("new sample")
            self.runQuery()
            completionHandler()
        }
        self.healthStore.execute(query)
      
        print("setup")
    }
    
    func start(){
        self.healthStore.requestAuthorization(toShare: nil, read: self.typesToShare, completion: { (success,error) in
            self.startObserverQuery()
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.allowsBackgroundLocationUpdates=true
            self.hkStatus="Running"
          
        });
        
        
    }

    
    func runQuery(){
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: .heartRate)!,
                                          predicate: nil,
                                          anchor: self.queryAnchor,
                                          limit: HKObjectQueryNoLimit)
        { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            
            guard let samples = samplesOrNil else {
                print("Error in Anchored query")
                return
            }
            print("XX: \(samples.count)")
            self.queryAnchor = newAnchor
            if(samples.count>0){
                let sample = samples[samples.count-1] as! HKQuantitySample
                if(sample.endDate > self.lastSampleTimeSample){
                let bpm = sample.quantity.doubleValue(for: HKUnit.init(from: "count/min"))
                print("\(self.phoneAgentUrl)datapoint?key=heartrate&value=\(bpm)&timestamp=\(sample.endDate.timeIntervalSince1970)")
                let request = URLRequest(url: URL(string:"\(self.phoneAgentUrl)datapoint?key=heartrate&value=\(bpm)&timestamp=\(sample.endDate.timeIntervalSince1970)")!)
                let task = URLSession.shared.dataTask(with:request){(data,response,error) in
                    print("HTTP Error \(error.debugDescription)")
                }
                task.resume()
                self.lastSampleTimeSample=sample.endDate
                DispatchQueue.main.async {
                    self.latestTimeStamp = "\(self.dateFormatter.string(from: sample.endDate))"
                    self.latest = "\(sample.quantity)"
                }
                }
            }
        }
        print("running query")
        self.healthStore.execute(query)
        
    }
    
    
  
}



