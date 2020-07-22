//
//  ViewController.swift
//  heltecThing
//
//  Created by lex on 26.06.20.
//  Copyright © 2020 zabrodin. All rights reserved.
//

import UIKit
//import PromiseKit
//import SwiftyJSON
import RestEssentials

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valuePicker: UIPickerView!
    @IBOutlet weak var textField: UITextField!
    
    private let channelNumber = "1082845"
    private let counterFieldNumber = "1"
    private let heltecChannelWriteAPIKey = "D029V60SWX9OTO8Z"
    private let heltecChannelReadAPIKey = "LBWYUUMWVLK2LXZD"
    private let endpoint = "https://api.thingspeak.com"
    
    
    // Read
    // https://api.thingspeak.com/channels/1082845/fields/1.json?api_key=LBWYUUMWVLK2LXZD&results=2
    
    // Write
    // GET https://api.thingspeak.com/update?api_key=D029V60SWX9OTO8Z&field1=0
    
    private var value:Int?
    
    @IBAction func SandTapHandler(_ sender: Any) {
        
    }
    
    private func readRemouteValue(withCompletion completion: @escaping (String?)->Void) {
        let readUrl = "\(endpoint)/channels/\(channelNumber)/fields/\(counterFieldNumber).json?api_key=\(heltecChannelReadAPIKey)"
        guard let rest = RestController.make(urlString: readUrl) else {
            print("Bad URL")
            return
        }
        
        rest.get(withDeserializer: JSONDeserializer()) { result, httpResponse in
            do {
                let json:JSON = try result.value()
                let feeds:JSONArray? = json["feeds"].array
                
                guard let lastFeed:JSON = feeds?.reversed()[0] else {
                    completion(nil)
                    return
                }
                
                let fieldValue = lastFeed["field1"]
                completion(fieldValue.string)
            } catch {
                print("Error performing GET: \(error)")
            }
        }
    }
    
    private func writeRemouteValue(_ value:String, withCompletion completion: @escaping (Bool)->Void) {
        let writeUrl = "\(endpoint)/update?api_key=\(heltecChannelWriteAPIKey)&field1=\(value)"
        guard let rest = RestController.make(urlString: writeUrl) else {
            print("Bad URL")
            return
        }
        
        rest.get(withDeserializer: JSONDeserializer()) { result, httpResponse in
            print("Status code = \(httpResponse?.statusCode)")
            completion(200 == (httpResponse?.statusCode ?? 0))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.readRemouteValue(withCompletion: { value in
            if let valueString = value, let valueInt = Int(valueString) {
                DispatchQueue.main.async {
                    self.value = valueInt
                    self.valueLabel.text = valueString
                    self.valuePicker.selectRow(valueInt, inComponent: 0, animated: false)
                }
            }
        })
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return 999999
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return String(row)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        print(row)
        self.readRemouteValue(withCompletion: { value in
            if let valueString = value, let valueInt = Int(valueString) {
                if self.value == valueInt {
                    let modifiedInt = row
                    self.writeRemouteValue(String(modifiedInt), withCompletion: { (success) in
                        DispatchQueue.main.async {
                            let remoteValue = success ? modifiedInt : valueInt
                            self.value = remoteValue
                            self.valueLabel.text = String(remoteValue)
                            self.valuePicker.selectRow(remoteValue, inComponent: 0, animated: false)
                        }
                    })
                }
                else{
                    DispatchQueue.main.async {
                        self.value = valueInt
                        self.valueLabel.text = valueString
                        self.valuePicker.selectRow(valueInt, inComponent: 0, animated: false)
                    }
                }
            }
        })
    }
}

