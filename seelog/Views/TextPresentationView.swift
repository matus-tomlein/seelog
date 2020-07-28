//
//  TextPresentationView.swift
//  seelog
//
//  Created by Matus Tomlein on 26/07/2020.
//  Copyright © 2020 Matus Tomlein. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct TextPresentationInnerView: UIViewRepresentable {

    @Binding var desiredHeight: CGFloat

    func makeUIView(context: Context) -> UITextView {

        let standardTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor: UIColor.label
        ]

        let attributedText = NSMutableAttributedString(string: "You can go to ")
        attributedText.addAttributes(
            standardTextAttributes,
            range: NSRange(location: 0, length: attributedText.length)
        )

        let hyperlinkTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor: UIColor.blue,
            NSAttributedString.Key.link: "seelog://stackoverflow.com"
        ]

        let textWithHyperlink = NSMutableAttributedString(string: "stack overflow site")
        textWithHyperlink.addAttributes(
            hyperlinkTextAttributes,
            range: NSRange(location: 0, length: textWithHyperlink.length)
        )
        attributedText.append(textWithHyperlink)

        let endOfAttrString = NSMutableAttributedString(string: " end enjoy it using old-school UITextView and UIViewRepresentable")
        endOfAttrString.addAttributes(
            standardTextAttributes,
            range: NSRange(location: 0, length: endOfAttrString.length)
        )
        attributedText.append(endOfAttrString)

        let textView = UITextView()
        textView.attributedText = attributedText

        textView.isEditable = false
        textView.textAlignment = .center
        textView.isSelectable = true

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let fixedWidth = uiView.frame.size.width
        let newSize = uiView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))

        DispatchQueue.main.async {
            self.desiredHeight = newSize.height
        }

    }

}

struct TextPresentationView: View {

    @State private var desiredHeight: CGFloat = 0

    var body: some View {
        TextPresentationInnerView(
            desiredHeight: self.$desiredHeight
        )
        .frame(height: max(self.desiredHeight, 100))
    }
}

struct TextPresentationView_Previews: PreviewProvider {
    static var previews: some View {
        TextPresentationView()
    }
}
