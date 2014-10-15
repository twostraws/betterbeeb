//
//  ReaderContentViewController.swift
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

import MediaPlayer
import UIKit

class ReaderContentViewController: UIViewController, UIWebViewDelegate {
	var story: Story!

	var webView: UIWebView!

	override func loadView() {
		super.loadView()

		webView = UIWebView()
		webView.setTranslatesAutoresizingMaskIntoConstraints(false)
		view.addSubview(webView)

		webView.delegate = self
		webView.backgroundColor = UIColor.beebStoryBackground()

		let viewsDictionary = ["webView" : webView]
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: .allZeros, metrics: nil, views: viewsDictionary))
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		var template = stringFromResource("template.html")

		var titleString = "<h1>\(story.title)</h1>"
		var formattedDate: String! = nil

		var timeSincePublished = NSDate().timeIntervalSinceDate(story.updated)

		if timeSincePublished < 60 * 60 * 9 {
			var roundedHours = Int(floor(timeSincePublished / (60 * 60)))

			if roundedHours == 0 {
				var roundedMinutes = Int(floor(timeSincePublished / 60))

				if roundedMinutes == 0 {
					formattedDate = "moments ago"
				} else if roundedMinutes == 1 {
					formattedDate = "1 minute ago"
				} else {
					formattedDate = "\(roundedMinutes) minutes ago"
				}

			} else if roundedHours == 1 {
				formattedDate = "1 hour ago"
			} else {
				formattedDate = "\(roundedHours) hours ago"
			}
		} else {
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "d MMM yyyy HH:mm"
			dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
			formattedDate = dateFormatter.stringFromDate(story.updated) + " GMT"
		}

		var lastUpdatedString = "Last updated \(formattedDate)"

		let dateComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear, fromDate: NSDate())

		var html = NSString(format: template, "", "iPhone", "", "", titleString, lastUpdatedString, story.content, "BBC &copy; \(dateComponents.year)")
		webView.loadHTMLString(html, baseURL: NSBundle.mainBundle().resourceURL)
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		webView.scrollView.scrollsToTop = true
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		// we must disable scrolls to top as we browse away from this page, otherwise there will be more than one
		// view will scrollsToTop enabled and thus iOS will do nothing.
		webView.scrollView.scrollsToTop = false
	}

	func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		if let urlString: NSString = request.URL.absoluteString {
			if urlString.hasPrefix("bbcvideo://") {
				let idx = urlString.rangeOfString("bbc.co.uk").location
				var url: NSString = "http://" + urlString.substringFromIndex(idx)
				url = url.stringByReplacingOccurrencesOfString("%7bdevice%7d", withString: "iphone")
				url = url.stringByReplacingOccurrencesOfString("%7bbandwidth%7d", withString: "wifi")

				var err: NSErrorPointer = nil
				let str: NSString! = NSString(contentsOfURL: NSURL(string: url), usedEncoding: nil, error: err)

				if err != nil || str == nil {
					let ac = UIAlertController(title: "Playback error", message: "There was a problem playing the movie; please check your connection and try again.", preferredStyle: .Alert)
					ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
					presentViewController(ac, animated: true, completion: nil)
					return false
				}

				let vc = MPMoviePlayerViewController(contentURL: NSURL(string: str))
				presentMoviePlayerViewControllerAnimated(vc)

				return false
			}
		}

		if navigationType == .LinkClicked {
			// any other types of links we want to open externally
			UIApplication.sharedApplication().openURL(request.URL)
			return false
		}

		return true
	}
}
