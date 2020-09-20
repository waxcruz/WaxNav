//
//  WaxNavSettingsViewController.swift
//  WaxNav
//
//  Created by Bill Weatherwax on 3/7/20.
//  Copyright © 2020 waxcruz. All rights reserved.
//

import Foundation
import UIKit


class WaxNavSettingsViewController: UIViewController, UITextFieldDelegate {
    
    // selections
    @IBOutlet weak var featureA: UISwitch!
    @IBOutlet weak var featureH: UISwitch!
    @IBOutlet weak var featureL: UISwitch!
    @IBOutlet weak var featureP: UISwitch!
    @IBOutlet weak var featureR: UISwitch!
    @IBOutlet weak var featureS: UISwitch!
    @IBOutlet weak var featureT: UISwitch!
    @IBOutlet weak var featureU: UISwitch!
    @IBOutlet weak var featureV: UISwitch!
    @IBOutlet weak var featureX: UISwitch!
    @IBOutlet weak var useMyCurrentAltitude: UISwitch!
    
    
    // input fields
    @IBOutlet weak var toleranceFieldOfView: UITextField! {
        didSet {
            toleranceFieldOfView?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForToleranceFieldOfView)))
        }
    }
    
    @IBOutlet weak var selectLimit: UITextField! {
        didSet {
            selectLimit?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForSelectLimit)))
        }
    }
    
    
    
    // local
    let model = Model.model
    var featureSwitches = Array<UISwitch>()

    override func viewDidLoad() {
        // each switch feature's tag is used as index so place switches in the tag value order
        featureSwitches.append(featureA)
        featureSwitches.append(featureH)
        featureSwitches.append(featureL)
        featureSwitches.append(featureP)
        featureSwitches.append(featureR)
        featureSwitches.append(featureS)
        featureSwitches.append(featureT)
        featureSwitches.append(featureU)
        featureSwitches.append(featureV)
        featureSwitches.append(featureX)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        let selectedFeatures = model.featuresSelected
        for featureSwitch in featureSwitches {
            featureSwitch.isOn = selectedFeatures[model.featureClasses[featureSwitch.tag]] ?? false
        }
        let selectedSettings = model.settingsSelected
        toleranceFieldOfView.text = selectedSettings["tolerance"]
        useMyCurrentAltitude.isOn = selectedSettings["altitude"] == "True" ? true : false
    }
    
    // feature selected
    @IBAction func featueSelected(_ sender: Any) {
        let choice : UISwitch = sender as! UISwitch
        let choiceValue = choice.tag
        var updateFeaturesSelected = model.featuresSelected
        updateFeaturesSelected[model.featureClasses[choiceValue]] = choice.isOn
        model.featuresSelected = updateFeaturesSelected
    }
    
    @IBAction func dismissFeatures(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    

    @objc func doneButtonTappedForToleranceFieldOfView() {
        updateSettingsChoices(settingsKey: "tolerance", settingsValue: toleranceFieldOfView.text ?? "5")
        toleranceFieldOfView.resignFirstResponder()
    }

    @objc func doneButtonTappedForSelectLimit() {
        updateSettingsChoices(settingsKey: "limit", settingsValue: selectLimit.text ?? "1000")
        selectLimit.resignFirstResponder()
    }

    
    func updateSettingsChoices(settingsKey : String, settingsValue : String) {
        var updateSettings = model.settingsSelected
        updateSettings[settingsKey] = settingsValue
        model.settingsSelected = updateSettings
    }
    
    @IBAction func minAltitudeChoice(_ sender: UISwitch) {
        updateSettingsChoices(settingsKey: "altitude", settingsValue: sender.isOn ? "True" : "False")
        useMyCurrentAltitude.resignFirstResponder()
    }
    

    	
}
