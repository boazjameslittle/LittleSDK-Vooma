//
//  TripRatingVC.swift
//  Little Redo
//
//  Created by Gabriel John on 14/05/2018.
//  Copyright © 2018 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class TripRatingVC: UIViewController, SDKRatingViewDelegate {
    
    var sdkBundle: Bundle?
    
    var popToRestorationID: UIViewController?
    var navShown: Bool?
    
    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    
    var rate = 0.0
    var vehicle = ""
    var selectedFeedbackId = ""
    var mainViewController: UIViewController!
    var feedbackArr: [String] = []
    var feedbackIdArr: [String] = []
    
    @IBOutlet weak var driverIm: UIImageView!
    @IBOutlet weak var driverRateLbl: UILabel!
    @IBOutlet weak var driverNameLbl: UILabel!
    @IBOutlet weak var impressionFeedBackLbl: UILabel!
    @IBOutlet weak var ratingNoLbl: UILabel!
    @IBOutlet weak var commentsTxt: UITextField!
    @IBOutlet var floatRatingView: SDKRatingView!
    
    @IBOutlet weak var feedbackConst: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle(for: Self.self)
        
        // Required float rating view params
        self.floatRatingView.emptyImage = getImage(named: "Star_Empty", bundle: sdkBundle!)
        self.floatRatingView.fullImage = getImage(named: "Star_Full", bundle: sdkBundle!)
        // Optional params
        self.floatRatingView.delegate = self
        self.floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        self.floatRatingView.maxRating = 5
        self.floatRatingView.minRating = 0
        self.floatRatingView.rating = 0
        self.floatRatingView.editable = true
        self.floatRatingView.halfRatings = true
        self.floatRatingView.floatRatings = false
        
        
        driverIm.sd_setImage(with: URL(string: am.getDRIVERPICTURE()), placeholderImage: getImage(named: "default", bundle: sdkBundle!))
        driverNameLbl.text = "Rate \(am.getDRIVERNAME()!.capitalized)"
        vehicle = am.getVEHICLETYPE().capitalized
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc func postBackHome() {
        
        var isPopped = true
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller == popToRestorationID {
                printVal(object: "ToView")
                if self.navShown ?? false {
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                } else {
                    self.navigationController?.setNavigationBarHidden(true, animated: false)
                }
                self.navigationController!.popToViewController(controller, animated: true)
                break
            } else {
                isPopped = false
            }
        }
        
        if !isPopped {
            printVal(object: "ToRoot")
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    func commonCallParams() -> String {
        
        let version = getAppVersion()
        
        let str = ",\"SessionID\":\"\(am.getMyUniqueID()!)\",\"MobileNumber\":\"\(am.getSDKMobileNumber()!)\",\"IMEI\":\"\(am.getIMEI()!)\",\"CodeBase\":\"\(am.getMyCodeBase()!)\",\"PackageName\":\"\(am.getSDKPackageName()!)\",\"DeviceName\":\"\(getPhoneType())\",\"SOFTWAREVERSION\":\"\(version)\",\"RiderLL\":\"\(am.getCurrentLocation()!)\",\"LatLong\":\"\(am.getCurrentLocation()!)\",\"TripID\":\"\(am.getTRIPID()!)\",\"City\":\"\(am.getCity()!)\",\"RegisteredCountry\":\"\(am.getCountry()!)\",\"Country\":\"\(am.getCountry()!)\",\"UniqueID\":\"\(am.getMyUniqueID()!)\",\"CarrierName\":\"\(getCarrierName()!)\""
        
        return str
    }
    
    func submitDriverRate() {
    
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadRate),name:NSNotification.Name(rawValue: "RATEJSONData"), object: nil)
        
        let dataToSend = "{\"FormID\":\"RATE\"\(commonCallParams()),\"RateAgent\":{\"DriverEmail\":\"\(am.getDRIVEREMAIL()!)\",\"DriverMobileNumber\":\"\(am.getDRIVERMOBILE()!)\",\"Rating\":\"\(rate)\",\"TripID\":\"\(am.getTRIPID()!)\",\"Comments\":\"\(commentsTxt.text!)\"}}"
        
        printVal(object: dataToSend)
        
        hc.makeServerCall(sb: dataToSend, method: "RATEJSONData", switchnum: 0)
        
    }
    
    @objc func loadRate(_ notification: NSNotification) {
       
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name(rawValue: "RATEJSONData"), object: nil)
        self.view.removeAnimation()
        am.saveTRIPID(data: "")
        postBackHome()
    }
    
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(_ ratingView: SDKRatingView, isUpdating rating:Float) {
        // printVal(object: NSString(format: "%.1f", self.floatRatingView.rating) as String)
        self.ratingNoLbl.text = NSString(format: "%.1f", self.floatRatingView.rating) as String
    }
    
    func floatRatingView(_ ratingView: SDKRatingView, didUpdate rating: Float) {
        // printVal(object: NSString(format: "%.1f", self.floatRatingView.rating) as String)
        self.ratingNoLbl.text = NSString(format: "%.1f", self.floatRatingView.rating) as String
        rate = Double(floatRatingView.rating)
        if floatRatingView.rating >= 0.0 && floatRatingView.rating <= 1.0 {
            
            commentsTxt.placeholder = "Tell us, what went wrong?"
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.impressionFeedBackLbl.text = "Terrible 😧"
            }, completion: nil)
            
        } else if floatRatingView.rating >= 1.0 && floatRatingView.rating <= 2.0 {
            
            commentsTxt.placeholder = "Tell us, what went wrong?"
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.impressionFeedBackLbl.text = "Bad 😐"
            }, completion: nil)
        } else if floatRatingView.rating >= 2.0 && floatRatingView.rating < 3.0 {
            
            commentsTxt.placeholder = "Tell us, what went wrong?"
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.impressionFeedBackLbl.text = "Okay 🙂"
            }, completion: nil)
        } else if floatRatingView.rating >= 3.0 && floatRatingView.rating < 4.0 {
            
            commentsTxt.placeholder = "Tell us, what went wrong?"
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.impressionFeedBackLbl.text = "Excellent 😁"
            }, completion: nil)
        } else if floatRatingView.rating >= 4.0 && floatRatingView.rating <= 5.0 {
           
            commentsTxt.placeholder = "Share your trip experience with us"
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.impressionFeedBackLbl.text = "Amazing! 🏆"
            }, completion: nil)
        }
    }
    
    @IBAction func submitRatePressed(_ sender: UIButton) {
        if rate == 0.0 {
            showAlerts(title: "", message: "Kindly rate your driver by moving the slider right for better, left for worse. But we hope right mostly :)")
        } else if rate < 4 && commentsTxt.text == "" {
            showAlerts(title: "", message: "Kindly leave us comment telling us why you think the Trip was less than perfect and what we should improve next time.")
        } else {
            submitDriverRate()
        }
    }
    
}
