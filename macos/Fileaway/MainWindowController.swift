//
//  MainWindowController.swift
//  Fileaway
//
//  Created by Pavlos Vinieratos on 02/10/2018.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
		windowFrameAutosaveName = NSWindow.FrameAutosaveName(rawValue: "windowFrame")
    }
}
