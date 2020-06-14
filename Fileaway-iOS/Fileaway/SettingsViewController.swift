//
//  SettingsViewController.swift
//  Fileaway
//
//  Created by Jason Barrie Morley on 15/05/2020.
//  Copyright © 2020 InSeven Limited. All rights reserved.
//

import UIKit
import SwiftUI

class SettingsViewController: UIHostingController<SettingsView> {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SettingsView(name: "Cheese"))
    }

}
