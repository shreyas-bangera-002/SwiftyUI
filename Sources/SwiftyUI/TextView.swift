//
//  TextView.swift
//  
//
//  Created by SpringRole on 10/04/2020.
//

import UIKit

public class TextView: UITextView, UITextViewDelegate {
    public var textChanged: SuccessBlock<String>
    let placeholderLabel: UILabel
    
    public init(style: Style, text: String = "", placeholder: String = "", placeholderStyle: Style, layout: @escaping Layout, textChanged: SuccessBlock<String> = nil) {
        self.textChanged = textChanged
        placeholderLabel = UILabel(style: placeholderStyle, title: placeholder, layout: { $0.top(10).horizontal(10) })
        super.init(frame: .zero, textContainer: nil)
        self.layout = layout
        self.delegate = self
        self.setText(text)
        self.font = style.font
        self.backgroundColor = style.bgColor
        self.textColor = style.color
        placeholderLabel.add(to: self)
    }
    
    public func setText(_ text: String) {
        self.text = text
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        textChanged?(textView.text)
    }
}
