//
//  ScenarioPickerViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/19/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol ScenarioPickerViewControllerDelegate: class {
    func scenarioPickerViewControllerDidCancel(_ controller: ScenarioPickerViewController)
    func scenarioPickerViewController(_ controller: ScenarioPickerViewController, didFinishPicking scenario: Scenario)
}

class ScenarioPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var delegate: ScenarioPickerViewControllerDelegate?
    var scenarioPicker = UIPickerView()
    var pickerData = [String]()
    var pickedScenario: String?
    var disableToggle: Bool?
    let scenarioComponent = 0
    var scenario: Scenario!
    var additionalTitles: [(_:String, _:String)]!
    var didPick = false

    @IBAction func cancel(_ sender: Any) {
        delegate?.scenarioPickerViewControllerDidCancel(self)
    }
    @IBAction func done(_ sender: Any) {

        if !didPick {
            scenarioPicker.selectRow(0, inComponent: 0, animated: true)
            let row = scenarioPicker.selectedRow(inComponent: 0)
            pickedScenario = pickerData[row]
        }
        delegate?.scenarioPickerViewController(self, didFinishPicking: scenario)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Programmatic Picker!

        let scenarioPicker = UIPickerView(frame: CGRect(x: 10, y: 140, width: self.view.frame.width - 20, height: 200))
        scenarioPicker.layer.cornerRadius = 10
        scenarioPicker.layer.masksToBounds = true
        scenarioPicker.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        scenarioPicker.showsSelectionIndicator = true
        scenarioPicker.delegate = self
        scenarioPicker.dataSource = self
    
        var number = String()
        var myTitle = String()
        for i in 0..<additionalTitles.count {
            number = additionalTitles[i].0
            myTitle = number + " - " + additionalTitles[i].1
            
            pickerData.append(myTitle)
            scenarioPicker.reloadAllComponents()
        }
        self.view.addSubview(scenarioPicker)
        //scenarioPicker.selectRow(0, inComponent: 0, animated: true)
    }

    // Implement delegate protocols for pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    // Get picker selection
    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int)
    {
        didPick = true
        pickedScenario = pickerData[row]
    }
}
