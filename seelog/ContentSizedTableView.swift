//
//  ContentSizedTableView.swift
//  Seelog
//
//  Created by Matus Tomlein on 09/11/2019.
//  Copyright © 2019 Matus Tomlein. All rights reserved.
//

import Foundation
import UIKit

final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: contentSize.height)
    }
}
