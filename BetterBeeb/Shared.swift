//
//  Shared.swift
//  BetterBeeb
//
//  Created by Hudzilla on 15/10/2014.
//  Copyright (c) 2014 Paul Hudson. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import UIKit

public extension UIColor {
	class func beebTickerGrey() -> UIColor {
		return UIColor(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
	}

	class func beebTickerRed() -> UIColor {
		return UIColor(hue: 0.0167, saturation: 0.92, brightness: 0.69, alpha: 1)
	}

	class func beebPagingDotsGrey() -> UIColor {
		return UIColor(hue: 0, saturation: 0, brightness: 0.71, alpha: 1)
	}

	class func beebBackgroundGrey() -> UIColor {
		return UIColor(hue: 0, saturation: 0, brightness: 0.19, alpha: 1)
	}

	class func beebStoryBackground() -> UIColor {
		return UIColor(hue: 0, saturation: 0, brightness: 0.94, alpha: 1)
	}

	class func beebRed() -> UIColor {
		return UIColor(hue: 0.9944, saturation: 1.0, brightness: 0.6, alpha: 1)
	}
}

public extension String {
	func trim() -> String {
		return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	}

	func stringByReplacingFirstOccurrenceOfString(search: NSString, withString replacement: String) -> String {
		let range = (self as NSString).rangeOfString(search)

		if (range.location != NSNotFound) {
			return (self as NSString).stringByReplacingCharactersInRange(range, withString: replacement)
		}

		return self
	}
}

func downloadImage(url: NSURL, handler: ((image: UIImage, NSError!) -> Void)) {
	var imageRequest: NSURLRequest = NSURLRequest(URL: url)
	NSURLConnection.sendAsynchronousRequest(imageRequest,
		queue: NSOperationQueue.mainQueue(),
		completionHandler:{response, data, error in

			if data != nil {
				dispatch_async(dispatch_get_main_queue()) {
					handler(image: UIImage(data: data), error)
				}
			}
	})
}

func stringFromResource(name: String) -> String {
	let path = NSBundle.mainBundle().pathForResource(name, ofType: nil)
	let str:NSString = NSString(contentsOfFile: path!, usedEncoding: nil, error: nil)

	return str
}

func getDocumentsDirectory() -> String {
	let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
	let documentsDirectory = paths[0] as String
	return documentsDirectory
}


func unarchiveDiskArray(filename: String) -> NSArray {
	var savedData: NSData! = NSData(contentsOfFile: filename)

	if (savedData != nil) {
		if let array = NSKeyedUnarchiver.unarchiveObjectWithData(savedData) as? NSArray {
			return array
		} else {
			return NSMutableArray(capacity: 8)
		}
	} else {
		return NSMutableArray(capacity: 8)
	}
}

func archiveDiskArray(filename: String, array: NSArray) {
	let savedData = NSKeyedArchiver.archivedDataWithRootObject(array)
	savedData.writeToFile(filename, atomically:true)
}
