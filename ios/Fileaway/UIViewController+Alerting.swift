//
//  UIViewController+Convenience.swift
//  Fileaway
//
//  Created by Jason Morley on 11/26/18.
//  Copyright © 2018 InSeven Limited. All rights reserved.
//

import UIKit

extension UIViewController {
	
	public func present(_ message: String, title: String? = nil) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		if presentedViewController != nil {
			dismiss(animated: true) {
				self.present(alert, animated: true)
			}
		} else {
			present(alert, animated: true)
		}
	}
	
	public func present(error: Error, title: String? = nil) {
		present(String(describing: error), title: "Error")
	}
}
