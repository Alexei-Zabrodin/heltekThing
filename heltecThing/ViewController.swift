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
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    private let channelNumber = "1082845"
    private let kCounterFieldNumber = "1"
    private let kTextFieldNumber = "2"
    private let heltecChannelWriteAPIKey = "D029V60SWX9OTO8Z"
    private let heltecChannelReadAPIKey = "LBWYUUMWVLK2LXZD"
    private let endpoint = "https://api.thingspeak.com"
    
    
    // Read
    // https://api.thingspeak.com/channels/1082845/fields/1.json?api_key=LBWYUUMWVLK2LXZD&results=2
    
    // Write
    // GET https://api.thingspeak.com/update?api_key=D029V60SWX9OTO8Z&field1=0
    
    private var value:Int?
    
    @IBAction func SandTapHandler(_ sender: Any) {
        spinner.startAnimating()
        self.writeRemouteValue((kCounterFieldNumber: String(valuePicker.selectedRow(inComponent: 0)), kTextFieldNumber: textField.text ?? ""), withCompletion: { (success) in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }
        })
    }
    
    @IBAction func reloadTapHandler(_ sender: Any) {
        update()
    }
    
    func update(){
        spinner.startAnimating()
        self.readRemouteValue(numberField: kCounterFieldNumber, withCompletion: {[weak self] value in
            DispatchQueue.main.async {
                guard let self = self else {return}
                self.spinner.stopAnimating()
                
                if let valueString = value, let valueInt = Int(valueString) {
                    self.value = valueInt
                    self.valueLabel.text = valueString
                    self.valuePicker.selectRow(valueInt, inComponent: 0, animated: false)
                }
            }
        })
    }
    
    private func readRemouteValue(numberField:String, withCompletion completion: @escaping (String?)->Void) {
        let readUrl = "\(endpoint)/channels/\(channelNumber)/fields/\(numberField).json?api_key=\(heltecChannelReadAPIKey)"
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
                
                let fieldValue = lastFeed["field\(String(numberField))"]
                completion(fieldValue.string)
            } catch {
                print("Error performing GET: \(error)")
            }
        }
    }
    
    private func writeRemouteValue(_ value:(kCounterFieldNumber: String, kTextFieldNumber: String), withCompletion completion: @escaping (Bool)->Void) {
        let writeUrl = "\(endpoint)/update?api_key=\(heltecChannelWriteAPIKey)&field\(kCounterFieldNumber)=\(value.kCounterFieldNumber)&field\(kTextFieldNumber)=\(value.kTextFieldNumber)"
        guard let rest = RestController.make(urlString: writeUrl) else {
            let alert = UIAlertController(title: "Try later", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
        update()
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
        let textFieldText = self.textField.text ?? ""
        spinner.startAnimating()
        self.readRemouteValue(numberField: kCounterFieldNumber, withCompletion: { value in
            if let valueString = value, let valueInt = Int(valueString) {
                if self.value == valueInt {
                    let modifiedInt = row
                    self.writeRemouteValue((kCounterFieldNumber: String(modifiedInt), kTextFieldNumber: textFieldText), withCompletion: { (success) in
                        DispatchQueue.main.async {
                            self.spinner.stopAnimating()
                            let remoteValue = success ? modifiedInt : valueInt
                            self.value = remoteValue
                            self.valueLabel.text = String(remoteValue)
                            self.valuePicker.selectRow(remoteValue, inComponent: 0, animated: false)
                        }
                    })
                }
                else{
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.value = valueInt
                        self.valueLabel.text = valueString
                        self.valuePicker.selectRow(valueInt, inComponent: 0, animated: false)
                    }
                }
            }
            else{
                DispatchQueue.main.async {[weak self]in self?.spinner.stopAnimating()}
            }
        })
    }
}

