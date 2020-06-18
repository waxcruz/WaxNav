//
//  WaxNavSortViewController.swift
//  WaxNav
//
//  Created by Bill Weatherwax on 4/12/20.
//  Copyright © 2020 waxcruz. All rights reserved.
//

import Foundation
import UIKit
import WaxUtilities


class WaxNavSortViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // local
    let model = Model.model
    let myConstants = GlobalConstants()
    var pickers = Array<UIPickerView>()
    var copyrightYear : String = ""



    // outlets - picker levels
    @IBOutlet weak var featureLevel: UIPickerView!
    @IBOutlet weak var distanceLevel: UIPickerView!
    @IBOutlet weak var altitudeLevel: UIPickerView!
    @IBOutlet weak var bearingLevel: UIPickerView!
    // outlets - sort levels
    @IBOutlet weak var featureSortOrder: UIPickerView!
    @IBOutlet weak var distanceSortOrder: UIPickerView!
    @IBOutlet weak var altitudeSortOrder: UIPickerView!
    @IBOutlet weak var bearingSortOrder: UIPickerView!
    // display areas
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var copyright: UILabel!
    // buttons
    @IBOutlet weak var back: UIButton!
    
    
    
    override func viewDidLoad() {
        //
        copyrightYear = WaxDates.year()
        copyright.text = (copyright.text ?? "????")+copyrightYear
        // build pickers for matching pickers selected
        // levels have positions 0 to 3
        pickers.append(featureLevel)
        pickers.append(distanceLevel)
        pickers.append(altitudeLevel)
        pickers.append(bearingLevel)
        // orders have positions 4 to 7
        pickers.append(featureSortOrder)
        pickers.append(distanceSortOrder)
        pickers.append(altitudeSortOrder)
        pickers.append(bearingSortOrder)

        // wire pickers to view
        featureLevel.delegate = self
        featureLevel.dataSource = self
        featureSortOrder.delegate = self
        featureSortOrder.dataSource = self
        distanceLevel.delegate = self
        distanceLevel.dataSource = self
        distanceSortOrder.delegate = self
        distanceSortOrder.dataSource = self
        altitudeLevel.delegate = self
        altitudeLevel.dataSource = self
        altitudeSortOrder.delegate = self
        altitudeSortOrder.dataSource = self
        bearingLevel.delegate = self
        bearingLevel.dataSource = self
        bearingSortOrder.delegate = self
        bearingSortOrder.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let selectedSortOptions = model.sortOptionsSelected
        // populate the 8 sort pickers
        let featureSortLevelIndex = myConstants.sortLevels.firstIndex(of: selectedSortOptions[myConstants.sortLevelTypes[0]]!)
        featureLevel.selectRow(featureSortLevelIndex ?? 0 , inComponent: 0, animated: true)
         let featureSortDirectionIndex = myConstants.sortDirections.firstIndex(of: selectedSortOptions[myConstants.sortDirectionTypes[0]]!)
        featureSortOrder.selectRow(featureSortDirectionIndex ?? 0, inComponent: 0, animated: true)
        let distanceSortLevelIndex = myConstants.sortLevels.firstIndex(of: selectedSortOptions[myConstants.sortLevelTypes[1]]!)
        distanceLevel.selectRow(distanceSortLevelIndex ?? 0, inComponent: 0, animated: true)
        let distanceSortDirectionIndex = myConstants.sortDirections.firstIndex(of: selectedSortOptions[myConstants.sortDirectionTypes[1]]!)
        distanceSortOrder.selectRow(distanceSortDirectionIndex ?? 0, inComponent: 0, animated: true)
        let altitudeSortLevelIndex = myConstants.sortLevels.firstIndex(of: selectedSortOptions[myConstants.sortLevelTypes[2]]!)
        altitudeLevel.selectRow(altitudeSortLevelIndex ?? 0, inComponent: 0, animated: true)
        let altitudeSortDirectionIndex = myConstants.sortDirections.firstIndex(of: selectedSortOptions[myConstants.sortDirectionTypes[2]]!)
        altitudeSortOrder.selectRow(altitudeSortDirectionIndex ?? 0, inComponent: 0, animated: true)
        let bearingSortLevelIndex = myConstants.sortLevels.firstIndex(of: selectedSortOptions[myConstants.sortLevelTypes[3]]!)
        bearingLevel.selectRow(bearingSortLevelIndex ?? 0, inComponent: 0, animated: true)
        let bearingSortDirectionIndex = myConstants.sortDirections.firstIndex(of: selectedSortOptions[myConstants.sortDirectionTypes[3]]!)
        bearingSortOrder.selectRow(bearingSortDirectionIndex ?? 0, inComponent: 0, animated: true)
        // remember initial selections

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // 0 - 3 have 5 selection
        // 4 - 7 have  2 selections
        let pickerCount = pickers.firstIndex(of: pickerView)!
        if pickerCount <= 3 {
            return myConstants.sortLevels.count
        } else {
            return myConstants.sortDirections.count
        }

    }
    
      func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

           let pickerIndex = pickers.firstIndex(of: pickerView)
           switch pickerIndex {
           // load picker title for specific picker
           case 0, 1, 2, 3: // feature level picker
               return myConstants.sortLevels[row]
           case 4, 5, 6, 7: // feature sort order picker
               return myConstants.sortDirections[row]
    
           default:
               return "internal error"
           }
       }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // prevent selection of already selected level
        let pickerIndex = pickers.firstIndex(of: pickerView)
        switch pickerIndex {
        case 0, 1, 2, 3:
            if areLevelChoicesInConflict() {
                message.text = myConstants.selectionTaken
                back.isHidden = true
            } else {
                message.text = ""
                back.isHidden = false
                // save the choice
                let saveKey = myConstants.sortLevelTypes[pickerIndex!]
                let saveValue = myConstants.sortLevels[row]
                updateSortChoices(settingsKey: saveKey, settingsValue: saveValue)
            }
        case 4, 5, 6,  7:
            // save the choice
            let saveKey = myConstants.sortDirectionTypes[pickerIndex! - 4]
            let saveValue = myConstants.sortDirections[row]
            updateSortChoices(settingsKey: saveKey, settingsValue: saveValue)
            break
        default:
            print("login error in Sort selection VC")
        }
    }

    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    
    }
    
    @IBAction func clearSelections(_ sender: Any) {
        for picker in pickers {
            picker.selectRow(0, inComponent: 0, animated: false)
        }
        back.isHidden = false
        message.text = ""
    }
    
    func updateSortChoices(settingsKey : String, settingsValue : String) {
        var updateSettings = model.sortOptionsSelected
        updateSettings[settingsKey] = settingsValue
        model.sortOptionsSelected = updateSettings
    }
    
    
    func areLevelChoicesInConflict()-> Bool
    {
        // use a set to detect duplicate choices in sort levels
        var levelChoices : Set = Set<String>()
        for i in 0...3 {
            let pickerSelected = pickers[i].selectedRow(inComponent: 0)
            if pickerSelected == 0 { // no choice isn't a conflict
                continue
            }
            if levelChoices.contains(String(pickerSelected)) {
                return true
            } else {
                levelChoices.insert(String(pickerSelected))
            }
        }
        return false
    }
}
