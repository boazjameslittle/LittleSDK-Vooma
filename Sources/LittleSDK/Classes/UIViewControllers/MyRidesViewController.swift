//
//  File.swift
//  
//
//  Created by Little Developers on 17/11/2022.
//

import UIKit
import MessageUI
import SwiftMessages

class MyRidesViewController: UIViewController {
    
    // Constants
    
    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    
    // Variables
    
    var HISTORYDATE=[String]()
    var PICKUPADDRESS=[String]()
    var DROPOFFADDRESS=[String]()
    var AMOUNT=[String]()
    var TIP=[String]()
    var FULLNAME=[String]()
    var DRIVERIMAGE=[String]()
    var VEHICLEICON=[String]()
    var MODE=[String]()
    var TRIPID=[String]()
    var MOBILENUMBER=[String]()
    var RATING=[String]()
    var BLOCKED=[String]()
    var EMAIL=[String]()
    var CURRENCY=[String]()
    var RIDETYPE=[String]()
    
    var TRIPIDSHUTTLE=[String]()
    var SHUTTLETIMESHUTTLE=[String]()
    var PICKUPTIMESHUTTLE=[String]()
    var DROPOFFTIMESHUTTLE=[String]()
    var PICKUPLLSHUTTLE=[String]()
    var DROPOFFLLSHUTTLE=[String]()
    var AMOUNTSHUTTLE=[String]()
    var DRIVEREMAILIDSHUTTLE=[String]()
    var DRIVERMOBILESHUTTLE=[String]()
    var DRIVERNAMESHUTTLE=[String]()
    var COLORSHUTTLE=[String]()
    var NUMBERSHUTTLE=[String]()
    var MODELSHUTTLE=[String]()
    var MODESHUTTLE=[String]()
    var DRIVERIMAGESHUTTLE=[String]()
    var DROPOFFADDRESSSHUTTLE=[String]()
    var PICKUPADDRESSSHUTTLE=[String]()
    
   
    var which=""
    var dtfromdate=Date()
    var dttodate=Date()
    var dtyearmonth=Date()
    var fromdate:String = ""
    var todate:String = ""
    var yearmonth:String = ""
    var cancelReason = ""
    var dateTag:Int = 0
    var CorpIndivState: String = "All".localized
    
    var selectedTripIndex:Int = 0
    
    var isShuttle: Bool = false
    
    var reasonsArr: [String] = ["I was not ready".localized, "Driver took too long".localized, "Driver asked me to cancel".localized, "Other".localized]
    
    private var finishedLoadingInitialTableCells = false
    
    // IBOutlets
    

    @IBOutlet weak var historyTable: UITableView!
    
    @IBOutlet weak var noHistoryView: UIView!
    @IBOutlet weak var noHistoryLbl: UILabel!
    
    @IBOutlet weak var sendingEmailView: UIView!
    @IBOutlet weak var sendingEmailText: UILabel!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var upcomingShuttleRidesView: UIView!
    @IBOutlet weak var lblUpcomingShuttleRides: UILabel!
    
    private var trips = [TripItem]()
    
    var popToRestorationID: UIViewController?
    var navShown: Bool?
    
    private var sdkBundle: Bundle!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle.module
        
        let nib = UINib.init(nibName: "NewTripCell", bundle: sdkBundle)
        historyTable.register(nib, forCellReuseIdentifier: "newCell")
        
        self.title = "History".localized
        
        let backButton = UIBarButtonItem(image: getImage(named: "backios", bundle: sdkBundle)?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backHome))
        backButton.imageInsets = UIEdgeInsets(top: 1, left: -8, bottom: 1, right: 10)
        
        
        self.navigationItem.leftBarButtonItem = backButton
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let originalImage = getImage(named: "search_black", bundle: sdkBundle)?.withRenderingMode(.alwaysTemplate)
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: originalImage?.renderResizedImage(25), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.pickMonth))
        navigationItem.rightBarButtonItem = rightButton
        
        let today = NSDate()
        printVal(object: "\(today)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Locale.current.languageCode ?? "en")
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateFormatter2 = DateFormatter()
        dateFormatter2.locale = Locale(identifier: Locale.current.languageCode ?? "en")
        dateFormatter2.dateFormat = "MMMM, yyyy"
        let dateFormatter3 = DateFormatter()
        dateFormatter3.locale = Locale(identifier: Locale.current.languageCode ?? "en")
        dateFormatter3.dateFormat = "yyyy-MM"
        let strDate = dateFormatter3.string(from: today as Date)
        dttodate=today as Date
        dtyearmonth=today as Date
        todate = strDate
        yearmonth = strDate
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let offsetComponents = NSDateComponents()
        offsetComponents.month = -1
        let minusmonth = gregorian!.date(byAdding: offsetComponents as DateComponents, to: today as Date, options: [])!
        printVal(object: "\(minusmonth)")
        let strLastMonth = dateFormatter.string(from: minusmonth)
        dtfromdate = (minusmonth as NSDate) as Date
        fromdate = strLastMonth
        
        noHistoryLbl.text = "No trips taken in the month of".localized + " \(dateFormatter2.string(from: today as Date))."
        noHistoryView.alpha = 0
        noHistoryView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.noHistoryView.alpha = 1
        }
        
        topConstraint.constant = 0
        
        historyTable.tag = 0
        
        getHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // Functions
    
    @objc func btnMonthPicked() {
        DispatchQueue.main.async {
            if let view = self.view.viewWithTag(101010) {
                view.removeFromSuperview()
            }
        }
        getHistory()
    }
    
    @objc func backHome() {
        var isPopped = true
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller == popToRestorationID {
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
    
    func getHistory() {
        topConstraint.constant = 0
        
        self.view.createLoadingNormal()
        
        noHistoryView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadHistoryDetails),name:NSNotification.Name(rawValue: "GetTripsJSONData"), object: nil)
        
        var params = SDKUtils.commonJsonTags(formId: "GETTRIPS")
        params["ReportFilters"] = [
            "YearMonth": yearmonth
        ]
        
        let dataToSend = (try? SDKUtils.dictionaryToJson(from: params)) ?? ""
        
        hc.makeServerCall(sb: dataToSend, method: "GetTripsJSONData", switchnum: 0)
        
    }
    
    func blockDriver(index: Int, action: String, remarks: String) {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadBlockDriver),name:NSNotification.Name(rawValue: "BLOCKDRIVER"), object: nil)
        
        noHistoryView.isHidden = true
        
        let datatosend:String="FORMID|BLOCKDRIVER|BLOCKORUNBLOCK|\(action)|TRIPID|\(trips[index].tripID ?? "")|EMAILID|\(trips[index].driverEmail ?? "")|REMARKS|\(remarks)|"
        
        hc.makeServerCall(sb: datatosend, method: "BLOCKDRIVER", switchnum: 0)
        
    }
        
    @objc func loadHistoryDetails(_ notification: NSNotification) {
                
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "GetTripsJSONData"), object: nil)
        
        self.view.removeAnimation()
        
//        allIndivCorpSC.selectedSegmentIndex = 0
        
        self.trips.removeAll()
        
        if let userInfo = notification.userInfo, let data = userInfo["data"] as? Data {
            do {
                let response = try JSONDecoder().decode(TripHistoryResponse.self, from: data)
                if let details = response.first {
                    self.trips.append(contentsOf: details.trips ?? [])
                    
                } else {
                    showGeneralErrorAlert()
                }

            } catch (let error) {
                showGeneralErrorAlert()
                printVal(object: "error: \(error.localizedDescription)")
            }
            
            if trips.isEmpty {
                finishedLoadingInitialTableCells = false
                historyTable.reloadData()
                
                let dateFormatter2 = DateFormatter()
                dateFormatter2.locale = Locale(identifier: Locale.current.languageCode ?? "en")
                dateFormatter2.dateFormat = "MMMM, yyyy"
                noHistoryLbl.text = "No trips taken in the month of".localized + " \(dateFormatter2.string(from: dtyearmonth))."
                noHistoryView.alpha = 0
                noHistoryView.alpha = 0
                noHistoryView.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    self.noHistoryView.alpha = 1
                }
                UIView.animate(withDuration: 0.3) {
                    self.noHistoryView.alpha = 1
                }
            } else {
                noHistoryLbl.text = ""
                noHistoryView.isHidden = true
                finishedLoadingInitialTableCells = false
                historyTable.reloadData()
                historyTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
        
    @objc func cancelTrip(index: Int) {
    
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadCancelRequest(_:)),name:NSNotification.Name(rawValue: "CANCELREQUEST"), object: nil)
        
        let datatosend="FORMID|CANCELSHUTTLETRIP|REASON|\(cancelReason)|TRIPID|\(trips[index].tripID ?? "")|"
        
        hc.makeServerCall(sb: datatosend, method: "CANCELREQUEST", switchnum: 0)
        
    }
    
    @objc func loadCancelRequest(_ notification: NSNotification) {
        self.view.removeAnimation()
        let data = notification.userInfo!["data"] as! Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CANCELREQUEST"), object: nil)
        
        do {
            
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
            let status = jsonResponse?["Status"] as? String
            let message = jsonResponse?["Message"] as? String
            if status != nil {
                if status == "000" {
                    getHistory()
                } else {
                    showAlerts(title: "", message: message ?? "An unknown error occured.".localized)
                }
            }
            
        } catch{
            showAlerts(title: "", message: "An unknown error occured.".localized)
        }
    }
    
    @objc func loadCancelRate(_ notification: Notification) {
        let data = notification.userInfo!["data"] as! String
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "RATECANCEL"), object: nil)
        
        if data.components(separatedBy: ":::").count > 1 {
            let message = data.components(separatedBy: ":::")[1]
            let rating = data.components(separatedBy: ":::")[0]
            submitDriverRate(message: message, rating: rating)
        }
    }
    
    func submitDriverRate(message: String, rating: String) {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadRate),name:NSNotification.Name(rawValue: "RATE"), object: nil)
        
        let datatosend:String="FORMID|RATE|DRIVEREMAIL|\(am.getDRIVEREMAIL()!)|DRIVERMOBILENUMBER|\(am.getDRIVERMOBILE()!)|COMMENT|\(message)|FEEDBACKID||WRONGCOMMENTS||RATING|\(rating)|TRIPID|\(trips[selectedTripIndex].tripID ?? "")|"
                
        hc.makeServerCall(sb: datatosend, method: "RATE", switchnum: 0)
    }
    
    @objc func loadRate(_ notification: NSNotification) {
        self.view.removeAnimation()
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name(rawValue: "RATE"), object: nil)
        showAlerts(title: "", message: "Rating successfully done.".localized)
    }
    
    func cancelRide(index: Int) {
        let cancelOptions = UIAlertController(title: nil, message: "Reason for cancelling".localized, preferredStyle: .actionSheet)
        
        for reason in reasonsArr {
            let reasonBtn = UIAlertAction(title: reason, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                if reason != "Other".localized {
                    self.cancelReason = reason
                    self.cancelTrip(index: index)
                } else {
                    self.enterOtherReason(index: index)
                }
            })
            cancelOptions.addAction(reasonBtn)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.cancelReason = ""
        })
        
        cancelOptions.addAction(cancelAction)
        if UIDevice.current.userInterfaceIdiom == .pad {
            cancelOptions.popoverPresentationController?.sourceView = self.view
            cancelOptions.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        DispatchQueue.main.async {self.present(cancelOptions, animated: true, completion: nil)}
        
    }
    
    func enterOtherReason(index: Int) {
        
        let view: PopoverEnterText = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: "", message: "Type reason for cancelling trip.".localized, image: "", placeholderText: "Type Reason".localized, type: "")
        view.proceedAction = {
           SwiftMessages.hide()
            if view.txtPopupText.text != "" {
                self.cancelReason = view.txtPopupText.text!
                self.cancelTrip(index: index)
           } else {
               self.showAlerts(title: "",message: "Reason required.".localized)
           }
        }
        view.cancelAction = {
            SwiftMessages.hide()
            self.cancelReason = ""
        }
        view.btnProceed.setTitle("Cancel Trip".localized, for: .normal)
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
        
    }
    
    
    @objc func blockDriverPressed (_ sender: UIButton) {
        blockDriverTapped(index: sender.tag)
    }
    
    @objc func cancelTripPressed (_ sender: UIButton) {
        cancelRide(index: sender.tag)
    }
    
    @objc func trackTripPressed (_ sender: UIButton) {
        
        
    }
    
    @objc func btnMorePressed (_ sender: UIButton) {
        let index = sender.tag
        showNormalTripOptions(index: index)
    }
    
    func rateDriver(index: Int, type: String) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadCancelRate(_:)),name:NSNotification.Name(rawValue: "RATECANCEL"), object: nil)
        selectedTripIndex = index
        
        let popOverVC = UIStoryboard(name: "Trip", bundle: Bundle.module).instantiateViewController(withIdentifier: "NewRatingViewController") as! NewRatingViewController
        self.addChild(popOverVC)
        popOverVC.driverName = trips[index].driverDetails?.first?.fullName ?? ""
        popOverVC.driverImage = trips[index].driverDetails?.first?.profilePicture ?? ""
        popOverVC.view.frame = UIScreen.main.bounds
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
        
    }
        
    func showNormalTripOptions(index: Int) {
        let callColor = SDKConstants.littleGreen
        let normalColor = SDKConstants.littleSDKThemeColor
        
        var blockcolor = UIColor()
        var blocktitle = ""
        
        if trips[index].blocked?.localized == "B" {
            blockcolor = SDKConstants.littleRed
            blocktitle = String(format: "Block %1$@".localized, trips[index].driverDetails?.first?.fullName?.capitalized ?? "")
        } else {
            blockcolor = SDKConstants.littleRed
            blocktitle = String(format: "Block %1$@".localized, trips[index].driverDetails?.first?.fullName?.capitalized ?? "")
        }
        
        var ratingMessage = ""
        let rating = trips[index].rating ?? 0
        if rating == 0 {
            ratingMessage = "Rate your trip".localized
        } else {
            ratingMessage = String(format: "Re-submit rating (Current: ★%1$d)".localized, Int(rating))
        }
        
        let options = UIAlertController(title: nil, message: String(format: "Trip options (%1$@ by %2$@)".localized, trips[index].createdOn ?? "", trips[index].driverDetails?.first?.fullName?.capitalized ?? ""), preferredStyle: .actionSheet)
        let btnRating = UIAlertAction(title: ratingMessage, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.rateDriver(index: index, type: "TRIP")
        })
        btnRating.setValue(normalColor, forKey: "titleTextColor")
        options.addAction(btnRating)
        let btnInvoice = UIAlertAction(title: "Resend invoice".localized, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.emailClientTapped(index: index)
        })
        btnInvoice.setValue(normalColor, forKey: "titleTextColor")
        options.addAction(btnInvoice)
        let btnCallDriver = UIAlertAction(title: String(format: "Call %1$@".localized, trips[index].driverDetails?.first?.fullName?.capitalized ?? ""), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.callDriverTapped(index: index)
        })
        btnCallDriver.setValue(callColor, forKey: "titleTextColor")
        options.addAction(btnCallDriver)
        let btnBlockDriver = UIAlertAction(title: blocktitle, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.blockDriverTapped(index: index)
        })
        btnBlockDriver.setValue(blockcolor, forKey: "titleTextColor")
        options.addAction(btnBlockDriver)
        let btnReport = UIAlertAction(title: "Report a problem".localized, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.reportAProblemTapped(index: index)
        })
        btnReport.setValue(normalColor, forKey: "titleTextColor")
        options.addAction(btnReport)
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        options.addAction(cancelAction)
        if UIDevice.current.userInterfaceIdiom == .pad {
            options.popoverPresentationController?.sourceView = historyTable.cellForRow(at: IndexPath(item: index, section: 0))
            options.popoverPresentationController?.sourceRect = CGRect(x: (historyTable.cellForRow(at: IndexPath(item: index, section: 0))?.bounds.size.width)! / 2.0, y: (historyTable.cellForRow(at: IndexPath(item: index, section: 0))?.bounds.size.height)! / 2.0, width: 1.0, height: 1.0)
        }
        DispatchQueue.main.async {
            self.present(options, animated: true, completion: nil)
        }
    }
        
    func getRemarks(indexs: Int, actions: String) {
        
        let view: PopoverEnterText = try! SwiftMessages.viewFromNib()
        view.loadPopup(title: "Block \(trips[indexs].driverDetails?.first?.fullName?.capitalized ?? "")?", message: "\nAdd a reason for blocking \(trips[indexs].driverDetails?.first?.fullName?.capitalized ?? "") \("(Optional)".localized).\n", image: "", placeholderText: "Reason (Optional)".localized, type: "")
        view.proceedAction = {
            SwiftMessages.hide()
            self.blockDriver(index: indexs, action: actions, remarks: view.txtPopupText.text ?? "")
        }
        view.cancelAction = {
            SwiftMessages.hide()
        }
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
    }
    
    @objc func callDriver(_ tapGesture: UITapGestureRecognizer) {
        
        let ind = Int(tapGesture.accessibilityHint!)
        callDriverTapped(index: ind!)
        
    }
    
    @objc func emailClient(_ tapGesture: UITapGestureRecognizer) {
        
        let ind = Int(tapGesture.accessibilityHint!)!
        emailClientTapped(index: ind)
        
    }
    
    func reportAProblemTapped(index: Int) {
        
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: "", message: "\nProceed to report a problem/issue with the selected Trip?\n", image: "", action: "")
        view.proceedAction = {
            SwiftMessages.hide()
            let subject = "Reporting a Problem on Trip: \(self.trips[index].tripID ?? "")"
            let body = ""
            let email = "operations@little.africa"
            let recipients = [email]
            
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(subject)
            mc.setMessageBody(body, isHTML: false)
            mc.setToRecipients(recipients)
            
            if MFMailComposeViewController.canSendMail()
            {
                self.present(mc, animated: true, completion: nil)
            }
        }
        view.cancelAction = {
            SwiftMessages.hide()
        }
        view.btnProceed.setTitle("Report Issue", for: .normal)
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
        
    }
    
    func blockDriverTapped(index: Int) {
        
        var actionType = ""
        
        if trips[index].blocked?.localized == "B" {
            actionType = "Un-Block"
        } else {
            actionType = "Block"
        }
        
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: "\(actionType) \(trips[index].driverDetails?.first?.fullName?.capitalized ?? "")?", message: "\nWould you like to \(actionType.lowercased()) \(trips[index].driverDetails?.first?.fullName?.capitalized ?? "")?\n", image: "", action: "")
        view.proceedAction = {
            SwiftMessages.hide()
            if self.trips[index].blocked == "B" {
                self.getRemarks(indexs: index, actions: "U")
            } else {
                self.blockDriver(index: index, action: "B", remarks: "")
            }
        }
        view.cancelAction = {
            SwiftMessages.hide()
        }
        view.btnProceed.setTitle("\(actionType)", for: .normal)
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
        
    }
    
    func callDriverTapped(index: Int) {
        let number = trips[index].driverDetails?.first?.mobileNumber ?? ""
        
        proceedCall(phone: "+\(number)")
        
    }
    
    func emailClientTapped(index: Int) {
        
        if SDKUtils.isValidEmail(testStr: am.getEmail()) {
            
            let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
            view.loadPopup(title: "", message: "\nWould you like to receive a copy of this invoice?\n\nEmail will be sent to \(am.getEmail()!)\n", image: "", action: "")
            view.proceedAction = {
                SwiftMessages.hide()
                self.sendEmail(tripid: self.trips[index].tripID ?? "")
            }
            view.cancelAction = {
                SwiftMessages.hide()
            }
            view.btnProceed.setTitle("Email Invoice", for: .normal)
            view.configureDropShadow()
            var config = SwiftMessages.defaultConfig
            config.duration = .forever
            config.presentationStyle = .center
            config.dimMode = .gray(interactive: false)
            SwiftMessages.show(config: config, view: view)
          
        } else {
            showAlerts(title: "", message: "Kindly ensure you have set a valid email on your profile. Head over to the side menu, tap on your profile picture to access your profile settings.")
        }
        
    }
    
    func sendEmail(tripid: String) {
        
        showBottonBarInfo(text: "Sending invoice to \(am.getEmail()!)...")
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadEmailSuccess),name:NSNotification.Name(rawValue: "EMAILINVOICE"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadEmailFail),name:NSNotification.Name(rawValue: "EMAILINVOICEFail"), object: nil)
        
        let datatosend:String="FORMID|EMAILINVOICE|EMAIL|\(am.getEmail()!)|TRIPID|\(tripid)|"
        
        hc.makeServerCall(sb: datatosend, method: "EMAILINVOICE", switchnum: 0)
        
    }
    
    @objc func loadEmailSuccess(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "EMAILINVOICE"), object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "EMAILINVOICEFail"), object: nil)
        hideBottonBarInfo(text: "Invoice sent successfully.")
    }
    
    @objc func loadEmailFail(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "EMAILINVOICE"), object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "EMAILINVOICEFail"), object: nil)
        hideBottonBarInfo(text: "Invoice was not sent. Kindly Retry.")
    }
    
    @objc func loadBlockDriver(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "BLOCKDRIVER"), object: nil)
        getHistory()
    }
    
    @objc func pickMonth() {
        
        if let view = self.view.viewWithTag(101010) {
            view.removeFromSuperview()
        } else {
            let color = UIColor.littleElevatedViews
            let color2 = UIColor(hex: "#0074A6")
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.locale = Locale(identifier: Locale.current.languageCode ?? "en")
            dateFormatter2.dateFormat = "MMM yyyy"
            
            let searchBtn = UIButton(frame: CGRect(x: self.view.bounds.width-200, y: 0, width: 200, height: 40))
            searchBtn.setTitle("Get \(dateFormatter2.string(from: dtfromdate)) Trips", for: UIControl.State())
            searchBtn.titleLabel?.font =  .systemFont(ofSize: 18, weight: .bold)
            searchBtn.setTitleColor(color2, for: .normal)
            searchBtn.addTarget(self, action: #selector(self.btnMonthPicked), for: .touchUpInside)
            
            let pickerBackGround = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(UIScreen.main.bounds.size.width), height: CGFloat(UIScreen.main.bounds.size.height)))
            pickerBackGround.tag = 101010
            pickerBackGround.backgroundColor = UIColor.littleElevatedViews.withAlphaComponent(0.6)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeSearchTap(_:)))
            
            pickerBackGround.addGestureRecognizer(tap)
            
            let container = UIView()
            container.frame = CGRect(x: 0, y: view.bounds.height - 300, width: view.bounds.width, height: 300)
            container.backgroundColor = color
            
            let fromDatePicker = MonthYearPickerView()
            fromDatePicker.frame = CGRect(x: 0, y: 40, width: view.bounds.width, height: 260)
            fromDatePicker.onDateSelected = { (month: Int, year: Int) in
                let string = String(format: "%02d-%d", month, year)
                NSLog(string) // should show something like 05/2015
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: Locale.current.languageCode ?? "en")
                dateFormatter.dateFormat = "dd-MM-yyyy"
                let dateFormatter2 = DateFormatter()
                dateFormatter2.locale = Locale(identifier: Locale.current.languageCode ?? "en")
                dateFormatter2.dateFormat = "MMM yyyy"
                let dateFormatter3 = DateFormatter()
                dateFormatter3.locale = Locale(identifier: Locale.current.languageCode ?? "en")
                dateFormatter3.dateFormat = "yyyy-MM"
                let date = dateFormatter.date(from: "01-\(string)")
                
                self.dtyearmonth = date! as Date
                self.yearmonth = dateFormatter3.string(from: date!)
                
                searchBtn.setTitle("Get \(dateFormatter2.string(from: date!)) Trips", for: UIControl.State())
            }
            container.addSubview(fromDatePicker)
            container.addSubview(searchBtn)
            container.bringSubviewToFront(searchBtn)
            pickerBackGround.addSubview(container)
            self.view.addSubview(pickerBackGround)
        }
    }
    
    @objc func closeSearchTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
    }

    
    func showBottonBarInfo(text: String) {
        sendingEmailView.isHidden = false
        sendingEmailView.alpha = 0.0
        sendingEmailText.text = text
        UIView.animate(withDuration: 1, delay:0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
            self.sendingEmailView.alpha = 1.0
        }, completion: nil)
    }
    
    func hideBottonBarInfo(text: String) {
        sendingEmailView.isHidden = false
        sendingEmailText.text = text
        UIView.animate(withDuration: 1, delay:3, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
            self.sendingEmailView.alpha = 0.0
        }, completion: { finished in
            self.sendingEmailView.isHidden = true
        })
    }
    
    
    // IBOutletFuctions
    
    @IBAction func btnViewShuttleRides(_ sender: UIButton) {
       
        
    }
    
    @IBAction func IndiviCorporateSCChanged(_ sender: UISegmentedControl) {
        
    }
    
}

extension MyRidesViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if historyTable.tag == 1 {
            return PICKUPTIMESHUTTLE.count
        } else {
            return trips.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell", for: indexPath as IndexPath) as! NewTripCell
        
        cell.selectionStyle = .none
        
        let item = trips[indexPath.item]
        
        cell.imgprofile.sd_setImage(with: URL(string: item.driverDetails?.first?.profilePicture ?? ""), placeholderImage: UIImage(named: "default"))
        
        cell.lbDriverName.text = item.driverDetails?.first?.fullName?.capitalized
        cell.lbhistorydate.text = item.createdOn
        
        let rating = item.rating ?? 0
        if rating == 0 {
            cell.lblDriverRating.text = "Driver not rated.".localized
        } else {
            cell.lblDriverRating.text = String(format: "%.1f", rating)
        }
        if item.paymentMode == nil || item.paymentMode?.isEmpty == true {
            cell.lbpaymentmode.text = "Cash".localized
        } else {
            cell.lbpaymentmode.text = item.paymentMode?.capitalized ?? ""
        }
        cell.lbriderdestination.text = item.dropOffAddress
        cell.lbridersource.text = item.pickupAddress
        if let amount = item.paymentAmount {
            cell.lbtripcharge.text = String(format: "%.2f", amount)
        } else {
            cell.lbtripcharge.text = "0.00"
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.callDriver))
        tap.accessibilityHint = "\(indexPath.item)"
        cell.imgprofile.addGestureRecognizer(tap)
        cell.imgprofile.isUserInteractionEnabled = true
        
        cell.lblTripID.text = "Your Trip ID:".localized + " \(item.tripID?.components(separatedBy: "-").first ?? "")"
        
        cell.btnMorePressed.tag = indexPath.item
        cell.btnMorePressed.accessibilityHint = ""
        cell.btnMorePressed.addTarget(self, action: #selector(btnMorePressed(_:)), for: UIControl.Event.touchUpInside)
        
        if let currency = item.currency {
            cell.lblCurrency.text = currency
        } else {
            cell.lblCurrency.text = nil
        }
        
        cell.coverView.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showNormalTripOptions(index: indexPath.item)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        
        if historyTable.tag == 1 {
            if PICKUPTIMESHUTTLE.count > 0 && !finishedLoadingInitialTableCells {
                if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
                    let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row {
                    lastInitialDisplayableCell = true
                }
            }
        } else {
            if HISTORYDATE.count > 0 && !finishedLoadingInitialTableCells {
                if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
                    let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row {
                    lastInitialDisplayableCell = true
                }
            }
        }
        
        
        if !finishedLoadingInitialTableCells {
            
            if lastInitialDisplayableCell {
                finishedLoadingInitialTableCells = true
            }
            
            //animates the cell as it is being displayed for the first time
            cell.transform = CGAffineTransform(translationX: 0, y: 105)
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0.05 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
    
}

extension MyRidesViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result {
        case .cancelled:
            // printVal(object: "Mail cancelled")
            showAlerts(title: "", message: "Email sending was cancelled.".localized)
        case .saved:
            // printVal(object: "Mail saved")
            showAlerts(title: "", message: "Email saved.".localized)
        case .sent:
            // printVal(object: "Mail sent")
            showAlerts(title: "", message: "Email sent.".localized)
        case .failed:
            // printVal(object: "Mail sent failure: \(String(describing: error?.localizedDescription))")
            showAlerts(title: "", message: "Email sending failure:".localized + " \(String(describing: error?.localizedDescription))")
        default:
            // printVal(object: "Mail sent failure: \(String(describing: error?.localizedDescription))")
            showAlerts(title: "", message: "Email sending failure:".localized + " \(String(describing: error?.localizedDescription))")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}