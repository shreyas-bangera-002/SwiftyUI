//
//  Picker.swift
//  
//
//  Created by SpringRole on 28/11/2019.
//

import UIKit

public class Picker<T: Valuable>: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    public struct PickerConfig {
        let rowHeight: CGFloat
        public init(rowHeight: CGFloat) {
            self.rowHeight = rowHeight
        }
    }
    
    enum ViewType { case normal, accessory }
    
    private let data: [T]
    private var selectedItem: Dynamic<T>?
    private var selection: T?
    private let config: PickerConfig?
    private let viewType: ViewType
    
    @discardableResult
    public init(_ data: [T], config: PickerConfig? = nil, textfield: UITextField? = nil, bindTo selectedItem: Dynamic<T>? = nil) {
        self.viewType = textfield.isNil ? .normal : .accessory
        self.data = data
        self.config = config
        self.selectedItem = selectedItem
        selection = selectedItem?.value
        super.init(frame: .zero)
        dataSource = self
        delegate = self
        UIToolbar().then {
            $0.sizeToFit()
            $0.setItems([
                UIBarButtonItem(title: "Cancel", style: .plain) {_ in
                    textfield?.resignFirstResponder()
                },
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: "Done", style: .done) { [weak self] _ in
                    if let item = self?.selection, item.value != selectedItem?.value.value {
                        selectedItem?.value = item
                        textfield?.text = item.value
                    }
                    textfield?.resignFirstResponder()
                }
            ], animated: false)
            $0.isUserInteractionEnabled = true
            textfield?.inputAccessoryView = $0
            textfield?.inputView = self
        }
        textfield?.text = selectedItem?.value.value
        textfield?.tintColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row].value
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch viewType {
        case .normal:
            selectedItem?.value = data[row]
        case .accessory:
            selection = data[row]
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return config?.rowHeight ?? 30
    }
    
    deinit {
        log("\(#function) \(Self.self)")
    }
}
