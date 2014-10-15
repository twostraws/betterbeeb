//
//  ReaderHostViewController.swift
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

import MessageUI
import Social
import UIKit

class ReaderHostViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, MFMailComposeViewControllerDelegate {
	weak var section: Section!
	weak var story: Story!

	var headerBar: UIView!
	var sectionTitle: UILabel!
	var pageCounter: SlimPageControl!
	var pageController: UIPageViewController!

	override func loadView() {
		super.loadView()

		edgesForExtendedLayout = .None

		view.backgroundColor = UIColor.beebStoryBackground()

		headerBar = UIView()
		sectionTitle = UILabel()
		pageCounter = SlimPageControl()
		pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)

		headerBar.setTranslatesAutoresizingMaskIntoConstraints(false)
		sectionTitle.setTranslatesAutoresizingMaskIntoConstraints(false)
		pageCounter.setTranslatesAutoresizingMaskIntoConstraints(false)
		pageController.view.setTranslatesAutoresizingMaskIntoConstraints(false)

		headerBar.backgroundColor = UIColor.beebStoryBackground()

		pageController.dataSource = self
		pageController.delegate = self

		addChildViewController(pageController)
		view.addSubview(pageController.view)

		headerBar.addSubview(sectionTitle)
		headerBar.addSubview(pageCounter)
		view.addSubview(headerBar)

		let viewsDictionary = ["headerBar" : headerBar, "sectionTitle" : sectionTitle, "pageCounter" : pageCounter, "pageControllerView" : pageController.view]

		headerBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(==8)-[sectionTitle]-(>=1)-[pageCounter]-(==4)-|", options: .allZeros, metrics: nil, views: viewsDictionary))
		headerBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[sectionTitle]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		headerBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[pageCounter]|", options: .allZeros, metrics: nil, views: viewsDictionary))

		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[headerBar]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[pageControllerView]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[headerBar(==22)][pageControllerView]|", options: .allZeros, metrics: nil, views: viewsDictionary))
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		// the original app has both font size adjust and share buttons, but our "Better Beeb" logo is bigger than theirs
		// so there isn't enough width for us to have font size adjustment
		let fontAdjustButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: Selector("adjustTextSizeTapped"))
		let shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: Selector("shareTapped"))
		navigationItem.rightBarButtonItems = [shareButton]

		let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(13)]
		sectionTitle.attributedText = NSAttributedString(string: section.title.uppercaseString, attributes: attrs)

		pageCounter.numberOfPages = section.stories.count
		pageCounter.pageIndicatorTintColor = UIColor.beebPagingDotsGrey()
		pageCounter.currentPageIndicatorTintColor = UIColor.beebRed()
		pageCounter.userInteractionEnabled = false

		if let currentIndex = find(section.stories, story) {
			self.pageCounter.currentPage = currentIndex
		} else {
			self.pageCounter.currentPage = -1
		}

		let vc = ReaderContentViewController()
		vc.story = story

		pageController.setViewControllers([vc], direction: .Forward, animated: false, completion: nil)
    }


	func adjustTextSizeTapped() {
		// Not implemented.
	}

	func shareTapped() {
		let ac = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
		ac.addAction(UIAlertAction(title: "Email", style: .Default, handler: shareByEmail))
		ac.addAction(UIAlertAction(title: "Twitter", style: .Default, handler: shareByTwitter))
		ac.addAction(UIAlertAction(title: "Facebook", style: .Default, handler: shareByFacebook))
		ac.addAction(UIAlertAction(title: "Copy web link", style: .Default, handler: copyWebLink))
		ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		presentViewController(ac, animated: true, completion: nil)
	}

	func shareByEmail(action: UIAlertAction!) {
		if MFMailComposeViewController.canSendMail() {
			let vc = MFMailComposeViewController()
			vc.mailComposeDelegate = self

			vc.setSubject("BBC News: \(story.title)")
			let body = "I saw this story on the Better Beeb iPhone app and thought you should see it:\n\n\(story.title)\n\n\(story.summary)\n\nRead more: \(story.linkHref)\n\n\n***Disclaimer***\nThe BBC is not responsible for the content of this e-mail, and anything written in this e-mail does not necessarily reflect the BBC's views or opinions. Please note that neither the e-mail address nor name of the sender have been verified."
			vc.setMessageBody(body, isHTML: false)

			presentViewController(vc, animated:true, completion: nil)
		} else {
			let ac = UIAlertController(title: "No email account", message: "Please configure an email account on your device before sharing by email.", preferredStyle: .Alert)
			ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(ac, animated: true, completion: nil)
		}
	}

	func shareByTwitter(action: UIAlertAction!) {
		let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
		vc.addURL(NSURL(string: story.linkHref))
		vc.setInitialText(story.title)

		presentViewController(vc, animated: true, completion: nil)
	}

	func shareByFacebook(action: UIAlertAction!) {
		let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
		vc.addURL(NSURL(string: story.linkHref))
		vc.setInitialText(story.title)

		presentViewController(vc, animated: true, completion: nil)
	}

	func copyWebLink(action: UIAlertAction!) {
		let pasteboard = UIPasteboard.generalPasteboard()
		pasteboard.URL = NSURL(string: story.linkHref)
	}

	func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}

	// MARK: - UIPageViewController data source

	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		let contentViewController = viewController as ReaderContentViewController

		if let currentIndex = find(section.stories, contentViewController.story) {
			if currentIndex > 0 {
				let vc = ReaderContentViewController()
				vc.story = section.stories[currentIndex - 1]
				return vc
			}
		}

		return nil
	}

	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		let contentViewController = viewController as ReaderContentViewController

		if let currentIndex = find(section.stories, contentViewController.story) {
			if currentIndex < section.stories.count - 1 {
				let vc = ReaderContentViewController()
				vc.story = section.stories[currentIndex + 1]
				return vc
			}
		}

		return nil
	}

	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
		if !completed { return }

		let currentVC = self.pageController.viewControllers.last as ReaderContentViewController
		if let currentIndex = find(section.stories, currentVC.story) {
			self.pageCounter.currentPage = currentIndex
		} else {
			self.pageCounter.currentPage = -1
		}
	}
}
