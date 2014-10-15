//
//  StoriesViewController.swift
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
import MessageUI
import UIKit

class StoriesViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
	var storiesTableView: UITableView!
	var loadingSpinner: UIActivityIndicatorView!
	var errorMessage: UILabel!

	var tickerView: UITableViewHeaderFooterView!
	var tickerContainer: UIView!
	var tickerText: UILabel!
	var tickerArrow: UIImageView!

	var tickerItems: [TickerItem]!
	var tickerPosition: Int = 0
	var tickerTimer: NSTimer!
	var sections: [Section]!

	var lastUpdatedTimer: NSTimer!
	var selectedStoryID: String!

	override func loadView() {
		super.loadView()

		// we must disable extended edges because of a strange layout glitch either with this code
		// or with Apple's. To reproduce: launch the app in landscape using iPhone 6 Plus - the only
		// phone device capable of doing so. For some reason, the tableView contentInset is calculated
		// incorrectly when extended edges are on, but only in landscape and only when launched
		// in landscape - if you launch in portrait and rotate it's OK. A partial fix was to
		// push the refreshControl creation into viewWillAppear, after the contentInset magic is
		// done by Apple, but even then it's wrong when you rotate back to portrait.
		// So: extended edges dies. Sorry about that!
		edgesForExtendedLayout = .None

		tableView.separatorStyle = .None
		tableView.backgroundColor = UIColor.beebBackgroundGrey()
		tableView.indicatorStyle = .White
		tableView.scrollIndicatorInsets = UIEdgeInsetsMake(36, 0, 0, 0)

		refreshControl = UIRefreshControl()
		refreshControl?.backgroundColor = UIColor.blackColor()
		refreshControl?.tintColor = UIColor.whiteColor()
		refreshControl?.addTarget(self, action: Selector("refreshStories"), forControlEvents: .ValueChanged)

		setRefreshControlTitle("Pull to refresh")

		createTableFooter()

		loadingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
		loadingSpinner.setTranslatesAutoresizingMaskIntoConstraints(false)
		loadingSpinner.hidesWhenStopped = true
		loadingSpinner.startAnimating()
		tableView.addSubview(loadingSpinner)

		tableView.addConstraint(NSLayoutConstraint(item: loadingSpinner, attribute: .CenterX, relatedBy: .Equal, toItem: tableView, attribute: .CenterX, multiplier: 1, constant: 0))
		tableView.addConstraint(NSLayoutConstraint(item: loadingSpinner, attribute: .CenterY, relatedBy: .Equal, toItem: tableView, attribute: .CenterY, multiplier: 1, constant: 0))

		errorMessage = UILabel()
		errorMessage.setTranslatesAutoresizingMaskIntoConstraints(false)
		errorMessage.numberOfLines = 0
		errorMessage.textColor = UIColor.whiteColor()
		errorMessage.textAlignment = .Center
		errorMessage.preferredMaxLayoutWidth = 260
		errorMessage.text = "There was a problem connecting to Better Beeb; please check your connection and try again."
		errorMessage.hidden = true
		tableView.addSubview(errorMessage)

		tableView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(==30)-[errorMessage]-(==30)-|", options: .allZeros, metrics: nil, views: ["errorMessage" : errorMessage]))
		tableView.addConstraint(NSLayoutConstraint(item: errorMessage, attribute: .CenterY, relatedBy: .Equal, toItem: tableView, attribute: .CenterY, multiplier: 1, constant: 0))
	}

	func createTableFooter() {
		let footer = UIView(frame: CGRectMake(0, 0, 320, 146))

		let firstRow = UIView()
		let secondRow = UIView()
		let thirdRow = UIView()

		let sendPhoto = HighlightingButton(off: UIColor.beebRed(), on: UIColor.redColor())
		let sendStory = HighlightingButton(off: UIColor.beebRed(), on: UIColor.redColor())
		let help = HighlightingButton(off: UIColor.blackColor(), on: UIColor.darkGrayColor())
		let terms = HighlightingButton(off: UIColor.blackColor(), on: UIColor.darkGrayColor())
		let privacy = HighlightingButton(off: UIColor.blackColor(), on: UIColor.darkGrayColor())

		let copyright = UILabel()

		firstRow.setTranslatesAutoresizingMaskIntoConstraints(false)
		secondRow.setTranslatesAutoresizingMaskIntoConstraints(false)
		thirdRow.setTranslatesAutoresizingMaskIntoConstraints(false)

		sendPhoto.setTranslatesAutoresizingMaskIntoConstraints(false)
		sendStory.setTranslatesAutoresizingMaskIntoConstraints(false)
		help.setTranslatesAutoresizingMaskIntoConstraints(false)
		terms.setTranslatesAutoresizingMaskIntoConstraints(false)
		privacy.setTranslatesAutoresizingMaskIntoConstraints(false)

		copyright.setTranslatesAutoresizingMaskIntoConstraints(false)

		sendPhoto.addTarget(self, action: Selector("sendPhotoTapped"), forControlEvents: .TouchUpInside)
		sendStory.addTarget(self, action: Selector("sendStoryTapped"), forControlEvents: .TouchUpInside)
		help.addTarget(self, action: Selector("helpTapped"), forControlEvents: .TouchUpInside)
		terms.addTarget(self, action: Selector("termsTapped"), forControlEvents: .TouchUpInside)
		privacy.addTarget(self, action: Selector("privacyTapped"), forControlEvents: .TouchUpInside)

		sendPhoto.titleLabel?.textColor = UIColor.whiteColor()
		sendStory.titleLabel?.textColor = UIColor.whiteColor()
		help.titleLabel?.textColor = UIColor.whiteColor()
		terms.titleLabel?.textColor = UIColor.whiteColor()
		privacy.titleLabel?.textColor = UIColor.whiteColor()

		sendPhoto.setTitle("Send Photo", forState: .Normal)
		sendStory.setTitle("Send Story", forState: .Normal)
		help.setTitle("Help", forState: .Normal)
		terms.setTitle("Terms of use", forState: .Normal)
		privacy.setTitle("Privacy", forState: .Normal)

		sendPhoto.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
		sendStory.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
		help.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
		terms.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
		privacy.titleLabel?.font = UIFont.boldSystemFontOfSize(13)

		let dateComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear, fromDate: NSDate())
		copyright.text = "BBC © \(dateComponents.year)"
		copyright.font = UIFont.boldSystemFontOfSize(12)
		copyright.textColor = UIColor.whiteColor()

		firstRow.addSubview(sendPhoto)
		firstRow.addSubview(sendStory)

		secondRow.addSubview(help)
		secondRow.addSubview(terms)
		secondRow.addSubview(privacy)

		thirdRow.addSubview(copyright)

		footer.addSubview(firstRow)
		footer.addSubview(secondRow)
		footer.addSubview(thirdRow)

		let viewsDictionary = ["firstRow" : firstRow, "secondRow" : secondRow, "thirdRow" : thirdRow, "sendPhoto" : sendPhoto, "sendStory" : sendStory, "help" : help, "terms" : terms, "privacy" : privacy, "copyright" : copyright]

		footer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[firstRow]-|", options: .allZeros, metrics: nil, views: viewsDictionary))
		footer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[secondRow]-|", options: .allZeros, metrics: nil, views: viewsDictionary))
		footer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[thirdRow]-|", options: .allZeros, metrics: nil, views: viewsDictionary))
		footer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(==8)-[firstRow(==44)]-(==8)-[secondRow(==44)]-(==8)-[thirdRow(==26)]-(==8)-|", options: .allZeros, metrics: nil, views: viewsDictionary))

		firstRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[sendPhoto]-[sendStory]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		firstRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[sendPhoto]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		firstRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[sendStory]|", options: .allZeros, metrics: nil, views: viewsDictionary))

		secondRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[help]-[terms]-[privacy]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		secondRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[help]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		secondRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[terms]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		secondRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[privacy]|", options: .allZeros, metrics: nil, views: viewsDictionary))

		thirdRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[copyright]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		thirdRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[copyright]-|", options: .allZeros, metrics: nil, views: viewsDictionary))

		firstRow.addConstraint(NSLayoutConstraint(item: sendPhoto, attribute: .Width, relatedBy: .Equal, toItem: sendStory, attribute: .Width, multiplier: 1, constant: 0))
		secondRow.addConstraint(NSLayoutConstraint(item: terms, attribute: .Width, relatedBy: .Equal, toItem: help, attribute: .Width, multiplier: 1, constant: 0))
		secondRow.addConstraint(NSLayoutConstraint(item: privacy, attribute: .Width, relatedBy: .Equal, toItem: help, attribute: .Width, multiplier: 1, constant: 0))

		tableView.tableFooterView = footer
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		// only create the logo view the first time
		let testLogoView = navigationController?.navigationBar.viewWithTag(0xDEADBEEF)

		if testLogoView == nil {
			let logoView = UIImageView(image: UIImage(named: "Top Bar Logo"))
			logoView.tag = 0xDEADBEEF
			logoView.center = CGPointMake(navigationController?.navigationBar.center.x ?? 0, navigationController!.navigationBar.frame.size.height / 2)
			logoView.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin
			navigationController?.navigationBar.addSubview(logoView)
		}

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Live", style: .Bordered, target: self, action: Selector("watchLiveTapped"))
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Bordered, target: self, action: Selector("toggleEditing"))

		tableView.registerClass(SectionCell.self, forCellReuseIdentifier: "Section")

		tickerItems = [TickerItem]()

		lastUpdatedTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("updateLastUpdatedText"), userInfo: nil, repeats: true)

		dispatch_async(dispatch_get_main_queue()) { [unowned self] in
			self.cleanUpStaleImages();
		}
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		if self.tickerText != nil {
			self.tickerText.preferredMaxLayoutWidth = self.tickerView.frame.size.width - 24
		}
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		if sections == nil {
			createSections()

			if sections[0].stories.count > 0 {
				// we have stories already, so skip the big spinner and show the cache…
				loadingSpinner.stopAnimating()
				tableView.reloadData()

				// …then trigger a "pull to refresh" effect
				refreshControl?.beginRefreshing()
				refreshStories()

				// and force the refresh control to be visible
				tableView.contentOffset = CGPointMake(0, -self.refreshControl!.frame.size.height)
			} else {
				// no cached stories, so do a full fetch
				fetchNewStories()
			}


			if tickerItems.count > 0 {
				// we have cached ticker items - start with these for now!
				tickerTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("advanceTicker"), userInfo: nil, repeats: true)
				tickerPosition = -1
				advanceTicker()
			}
		}
	}

	func watchLiveTapped() {
		var err: NSErrorPointer = nil
		let url: NSString! = NSString(contentsOfURL: NSURL(string: "http://www.bbc.co.uk/moira/avstream/iphone/urn:news:news.bbc.co.uk:newschannel/wifi"), usedEncoding: nil, error: err)

		if err != nil || url == nil {
			let ac = UIAlertController(title: "Playback error", message: "There was a problem connecting to the live stream; please check your connection and try again.", preferredStyle: .Alert)
			ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(ac, animated: true, completion: nil)
			return
		}

		if url != "" {
			let vc = MPMoviePlayerViewController(contentURL: NSURL(string: url))
			presentMoviePlayerViewControllerAnimated(vc)
		}
	}

	override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animateAlongsideTransition({ [unowned self] (context) -> Void in
			self.tickerText.preferredMaxLayoutWidth = self.tickerView.frame.size.width - 24

			if let testLogoView = self.navigationController?.navigationBar.viewWithTag(0xDEADBEEF) {
				testLogoView.center = CGPointMake(self.navigationController?.navigationBar.center.x ?? 0, self.navigationController!.navigationBar.frame.size.height / 2)
			}
		}, completion: nil)
	}

	func cleanUpStaleImages() {
		let fm = NSFileManager.defaultManager()

		if let allSavedFiles = fm.contentsOfDirectoryAtPath(getDocumentsDirectory(), error: nil) as? [String] {
			for path in allSavedFiles {
				let fullPath = getDocumentsDirectory().stringByAppendingPathComponent(path)

				if var attributes = fm.attributesOfItemAtPath(fullPath, error: nil) {
					let lastModifiedDate = attributes[NSFileModificationDate] as NSDate

					// if this image is over seven days old, delete it
					if abs(lastModifiedDate.timeIntervalSinceNow) > 86400 * 7  {
						fm.removeItemAtPath(fullPath, error: nil)
					}
				}
			}
		}
	}

	func updateLastUpdatedText() {
		if tableView.editing { return }

		if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? SectionCell {
			if let lastUpdatedDate = NSUserDefaults.standardUserDefaults().objectForKey("LastUpdated") as? NSDate {
				cell.setSectionDate(convertLastUpdatedDate(lastUpdatedDate))
			} else {
				cell.setSectionDate("")
			}
		}
	}

	func convertLastUpdatedDate(date: NSDate) -> String {
		let now = NSDate()
		let deltaSeconds = fabs(date.timeIntervalSinceDate(now))
		let deltaMinutes = Int(floor(deltaSeconds / 60.0))
		let deltaHours = Int(floor(Float(deltaMinutes) / 60.0))
		let deltaDays = Int(floor(Float(deltaHours) / 24.0))

		if deltaSeconds < 60 {
			return "Updated less than a minute ago"
		} else if deltaMinutes < 60 {
			if deltaMinutes == 1 {
				return "Updated 1 minute ago"
			} else {
				return "Updated \(deltaMinutes) minutes ago"
			}
		} else if deltaHours < 24 {
			if deltaHours == 1 {
				return "Updated 1 hour ago"
			} else {
				return "Updated \(deltaHours) hours ago"
			}
		} else if deltaDays < 30 {
			if deltaDays == 1 {
				return "Updated 1 day ago"
			} else {
				return "Updated \(deltaDays) days ago"
			}
		}

		// updated a long time ago; just return nothing
		return ""
	}

	func toggleEditing() {
		tableView.setEditing(!tableView.editing, animated: true)

		if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? SectionCell {
			cell.setSectionDate("")

			if tableView.editing {
				navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: Selector("toggleEditing"))
			} else {
				navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Bordered, target: self, action: Selector("toggleEditing"))
			}
		}
	}


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if sections == nil { return 0 }
        return sections.count
    }

	override func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		return 36
	}

	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 36
	}

	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		tickerView = UITableViewHeaderFooterView(frame: CGRectMake(0, 0, tableView.frame.size.width, 36))
		tickerView.setTranslatesAutoresizingMaskIntoConstraints(false)
		tickerView.contentView.backgroundColor = UIColor.beebTickerGrey()

		tickerContainer = UIView()
		tickerContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
		tickerContainer.backgroundColor = UIColor.beebTickerGrey()
		tickerContainer.alpha = 0
		tickerView.contentView.addSubview(tickerContainer)

		tickerText = UILabel()
		tickerText.setTranslatesAutoresizingMaskIntoConstraints(false)
		tickerText.numberOfLines = 2
		tickerContainer.addSubview(tickerText)
		tickerText.preferredMaxLayoutWidth = tickerView.frame.size.width - 24

		tickerArrow = UIImageView(image: UIImage(named: "Ticker Arrow Dark"))
		tickerArrow.setTranslatesAutoresizingMaskIntoConstraints(false)
		tickerContainer.addSubview(tickerArrow)

		let viewsDictionary = ["tickerContainer" : tickerContainer, "tickerText" : tickerText, "tickerArrow" : tickerArrow]

		tickerView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tickerContainer]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		tickerView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tickerContainer]|", options: .allZeros, metrics: nil, views: viewsDictionary))

		tickerContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(==6)-[tickerText]-(>=6)-|", options: .allZeros, metrics: nil, views: viewsDictionary))
		tickerContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(==2)-[tickerText]-(==2)-|", options: .allZeros, metrics: nil, views: viewsDictionary))

		tickerContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=2)-[tickerArrow]-(==6)-|", options: .allZeros, metrics: nil, views: viewsDictionary))
		tickerContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=2)-[tickerArrow]-(==3)-|", options: .allZeros, metrics: nil, views: viewsDictionary))

		let recognizer = UITapGestureRecognizer(target: self, action: Selector("tickerTapped"))
		tickerContainer.addGestureRecognizer(recognizer)

		return tickerView
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Section", forIndexPath: indexPath) as SectionCell
		cell.parentViewController = self

		let sectionNumber = indexPath.row
		let section = sections[sectionNumber]

		cell.section = sections[sectionNumber]
		cell.setSectionTitle(section.title)

		if indexPath.row == 0 {
			// WARNING WARNING WARNING
			// There appears to be an iOS 8 bug where:
			//   - A given row is not able to be moved
			//   - Other cells can be moved
			//   - You enter editing mode for the table
			//   - You scroll away so the unmovable row is off screen
			//   - You scroll back to the unmovable row is visible
			// ...then suddenly the unmovable row can be moved.
			// This block fixes that bug.
			cell.showsReorderControl = false
			cell.editing = false
		}

		if indexPath.row == 0 && !tableView.editing {
			if let lastUpdatedDate = NSUserDefaults.standardUserDefaults().objectForKey("LastUpdated") as? NSDate {
				cell.setSectionDate(convertLastUpdatedDate(lastUpdatedDate))
			} else {
				cell.setSectionDate("")
			}
		} else {
			cell.setSectionDate("")
		}

		cell.collectionView.reloadData() // we've changed its items!

		return cell
	}


	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 166
	}

	override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
		return .None
	}

	override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return false
	}

	override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return indexPath.row > 0
	}

	override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
		let chosen = sections[sourceIndexPath.row]
		sections.removeAtIndex(sourceIndexPath.row)
		sections.insert(chosen, atIndex: destinationIndexPath.row)

		saveCachedStories()
	}

	override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
		if proposedDestinationIndexPath.row == 0 { return sourceIndexPath }
		return proposedDestinationIndexPath
	}

	// MARK: - Ticker
	func tickerTapped() {
		if tickerItems == nil { return }
		if sections == nil { return }

		let tickerItem = tickerItems[self.tickerPosition]

		for section in sections {
			for story in section.stories {
				if story.id == tickerItem.id {
					showStory(story)
					return
				}
			}
		}
	}

	func advanceTicker() {
		UIView.animateWithDuration(0.2, animations: { [unowned self] in
			self.tickerContainer.alpha = 0
		}) { (finished) in
			++self.tickerPosition
			if self.tickerPosition >= self.tickerItems.count { self.tickerPosition = 0 }

			let tickerItem = self.tickerItems[self.tickerPosition]

			self.setTickerItem(tickerItem)

			UIView.animateWithDuration(0.2, delay: 0.2, options: .allZeros, animations: { () -> Void in
				self.tickerContainer.alpha = 1
			}, completion:nil)
		}
	}

	func updateTicker() -> Bool {
		var err: NSErrorPointer = nil
		let tickerString: NSString! = NSString(contentsOfURL: NSURL(string: "http://polling.bbc.co.uk/moira/ticker/uk"), usedEncoding: nil, error: err)

		if err != nil || tickerString == nil || tickerString.length == 0 { return false }

		if let data = tickerString.dataUsingEncoding(NSUTF8StringEncoding) {
			let json = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: err) as NSDictionary

			if let entries = json["entries"] as? [[String : String]] {
				tickerItems.removeAll(keepCapacity: true)

				for entry in entries {
					if entry["headline"] != nil {
						// the only required field is headline; everything else can have sensible defaults
						let item = TickerItem(id: entry["id"] ?? "", headline: entry["headline"]!, prompt: entry["prompt"] ?? "LATEST", url: entry["url"] ?? "", isLive: entry["isLive"] ?? "false", isBreaking: entry["isBreaking"] ?? "false")
						tickerItems.append(item)
					}
				}
			}
		} else {
			return false
		}

		return true
	}

	func setTickerItem(item: TickerItem) {
		if item.isBreaking == "true" {
			let attrsTitle = [NSFontAttributeName : UIFont.boldSystemFontOfSize(13), NSForegroundColorAttributeName : UIColor.whiteColor()]
			let attrsText = [NSFontAttributeName : UIFont.systemFontOfSize(13), NSForegroundColorAttributeName : UIColor.whiteColor()]

			let str: NSMutableAttributedString = NSMutableAttributedString()
			str.appendAttributedString(NSAttributedString(string: "\(item.prompt): ", attributes: attrsTitle))
			str.appendAttributedString(NSAttributedString(string: item.headline, attributes: attrsText))

			tickerArrow.image = UIImage(named: "Ticker Arrow Light")
			tickerContainer.backgroundColor = UIColor.beebTickerRed()
			tickerText.attributedText = str
		} else {
			let attrsTitle = [NSFontAttributeName : UIFont.boldSystemFontOfSize(13), NSForegroundColorAttributeName : UIColor.beebRed()]
			let attrsText = [NSFontAttributeName : UIFont.systemFontOfSize(13)]

			let str: NSMutableAttributedString = NSMutableAttributedString()
			str.appendAttributedString(NSAttributedString(string: "\(item.prompt): ", attributes: attrsTitle))
			str.appendAttributedString(NSAttributedString(string: item.headline, attributes: attrsText))

			tickerArrow.image = UIImage(named: "Ticker Arrow Dark")
			tickerContainer.backgroundColor = UIColor.beebTickerGrey()
			tickerText.attributedText = str
		}
	}



	// MARK: - Story loading
	func createSections() {
		var cachedSections = unarchiveDiskArray(getDocumentsDirectory().stringByAppendingPathComponent("cachedSections")) as [AnyObject]
		var cachedTicker = unarchiveDiskArray(getDocumentsDirectory().stringByAppendingPathComponent("cachedTicker")) as [AnyObject]

		if cachedSections.count > 0 {
			sections = cachedSections as [Section]
		} else {
			sections = [Section]()

			sections.append(Section(title: "Top Stories", url: "http://polling.bbc.co.uk/moira/feed/ukagg/1"))
			sections.append(Section(title: "World", url: "http://polling.bbc.co.uk/moira/feed/ukagg/2"))
			sections.append(Section(title: "UK", url: "http://polling.bbc.co.uk/moira/feed/ukagg/3"))
			sections.append(Section(title: "Sport", url: "http://polling.bbc.co.uk/moira/feed/sport_uk/front_page"))
			sections.append(Section(title: "England", url: "http://polling.bbc.co.uk/moira/feed/news_uk/england"))
			sections.append(Section(title: "Northern Ireland", url: "http://polling.bbc.co.uk/moira/feed/news_uk/northern_ireland"))
			sections.append(Section(title: "Scotland", url: "http://polling.bbc.co.uk/moira/feed/news_uk/scotland"))
			sections.append(Section(title: "Wales", url: "http://polling.bbc.co.uk/moira/feed/news_uk/wales"))
			sections.append(Section(title: "Business", url: "http://polling.bbc.co.uk/moira/feed/news_uk/business"))
			sections.append(Section(title: "Politics", url: "http://polling.bbc.co.uk/moira/feed/news_uk/uk_politics"))
			sections.append(Section(title: "Health", url: "http://polling.bbc.co.uk/moira/feed/news_uk/health"))
			sections.append(Section(title: "Education", url: "http://polling.bbc.co.uk/moira/feed/news_uk/education"))
			sections.append(Section(title: "Science & Environment", url: "http://polling.bbc.co.uk/moira/feed/news_uk/sci/tech"))
			sections.append(Section(title: "Technology", url: "http://polling.bbc.co.uk/moira/feed/news_uk/technology"))
			sections.append(Section(title: "Entertainment & Arts", url: "http://polling.bbc.co.uk/moira/feed/news_uk/entertainment"))
			sections.append(Section(title: "Features & Analysis", url: "http://polling.bbc.co.uk/moira/feed/news_uk/front_page/wide_front_page_features"))
			sections.append(Section(title: "Also in the News", url: "http://polling.bbc.co.uk/moira/feed/news_uk/also_in_the_news"))
		}


		if cachedTicker.count > 0 {
			tickerItems = cachedTicker as [TickerItem]
		}
	}

	func setRefreshControlTitle(str: String) {
		refreshControl?.attributedTitle = NSAttributedString(string: str, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
	}

	func refreshStories() {
		setRefreshControlTitle("Updating…")
		fetchNewStories()
	}

	func fetchNewStories() {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [unowned self] in
			for section in self.sections {
				if section.update() == false {
					dispatch_async(dispatch_get_main_queue()) {
						self.failedFetchingStories()
					}

					return
				}
			}

			if self.updateTicker() == false {
				dispatch_async(dispatch_get_main_queue()) {
					self.failedFetchingStories()
				}

				return
			}

			dispatch_async(dispatch_get_main_queue()) {
				self.finishedFetchingNewStories()
			}
		}
	}

	func failedFetchingStories() {
		let section = sections[0]

		if section.stories.count == 0 {
			sections = nil
			errorMessage.hidden = false
		}

		refreshControl?.endRefreshing()
		setRefreshControlTitle("Pull to refresh")
		loadingSpinner.stopAnimating()

		if tickerTimer != nil { tickerTimer.invalidate() }
	}

	func finishedFetchingNewStories() {
		// STEP ONE: Save our stories to disk so that we have a cache for later
		saveCachedStories()

		// STEP TWO: Save the last updated date for later display
		NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "LastUpdated")
		NSUserDefaults.standardUserDefaults().synchronize()

		// STEP THREE: Update the UI with our great new content
		refreshControl?.endRefreshing()
		setRefreshControlTitle("Pull to refresh")

		tableView.reloadData()
		loadingSpinner.stopAnimating()

		errorMessage.hidden = true

		if tickerTimer != nil { tickerTimer.invalidate() }
		tickerTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("advanceTicker"), userInfo: nil, repeats: true)
		tickerPosition = -1
		advanceTicker()
	}

	func saveCachedStories() {
		if sections == nil || tickerItems == nil { return }
		archiveDiskArray(getDocumentsDirectory().stringByAppendingPathComponent("cachedSections"), sections)
		archiveDiskArray(getDocumentsDirectory().stringByAppendingPathComponent("cachedTicker"), tickerItems)
	}

	func showStory(story: Story) {
		selectedStoryID = story.id

		// even though it's not visible or even useful, the iPhone app places a red bar under the story
		// you selected to read. On iPad this makes some sort of sense because you can see the story list
		// on the left while you're reading on the right, but this doesn't exist on iPhone and the red vbar
		// is therefore redundant. However, in the interests of accuracy, it has been reproduced here…

		let visibleCells = tableView.visibleCells()

		for visibleCell in visibleCells as [SectionCell] {
			visibleCell.highlightStory(story)
		}
		
		let vc = ReaderHostViewController()
		vc.section = story.section
		vc.story = story
		navigationController?.pushViewController(vc, animated: true)
	}


	// MARK: - Table footer button

	func sendPhotoTapped() {
		let imagePicker = UIImagePickerController()
		imagePicker.allowsEditing = false
		imagePicker.delegate = self
		imagePicker.sourceType = .PhotoLibrary

		imagePicker.view.tintColor = UIColor.whiteColor()
		imagePicker.navigationBar.barTintColor = UIColor.beebRed()
		imagePicker.navigationBar.barStyle = .Black
		imagePicker.navigationBar.translucent = false

		presentViewController(imagePicker, animated: true, completion: nil)
	}

	func sendStoryTapped() {
		let ac = UIAlertController(title: "Share your story with us", message: nil, preferredStyle: .ActionSheet)
		ac.addAction(UIAlertAction(title: "Email us", style: .Default, handler: sendStoryByEmail))
		ac.addAction(UIAlertAction(title: "Text us", style: .Default, handler: sendStoryByText))
		ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

		presentViewController(ac, animated: true, completion: nil)
	}

	func helpTapped() {
		UIApplication.sharedApplication().openURL(NSURL(string: "http://www.bbc.co.uk/news/help-21770562"))
	}

	func termsTapped() {
		UIApplication.sharedApplication().openURL(NSURL(string: "http://www.bbc.co.uk/terms/"))
	}

	func privacyTapped() {
		UIApplication.sharedApplication().openURL(NSURL(string: "http://www.bbc.co.uk/privacy"))
	}

	func sendStoryByEmail(action: UIAlertAction!) {
		if MFMailComposeViewController.canSendMail() {
			let vc = MFMailComposeViewController()
			vc.mailComposeDelegate = self
			vc.setToRecipients(["talkingpoint@bbc.co.uk"])
			vc.setSubject("Sent from Better Beeb iPhone app")
			vc.setMessageBody("Sent from Better Beeb iPhone app", isHTML: false)
			presentViewController(vc, animated: true, completion: nil)
		} else {
			let ac = UIAlertController(title: "No email account", message: "Please configure an email account on your device before sending by email.", preferredStyle: .Alert)
			ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(ac, animated: true, completion: nil)
		}
	}

	func sendStoryByText(action: UIAlertAction!) {
		if MFMessageComposeViewController.canSendText() {
			let vc = MFMessageComposeViewController()
			vc.messageComposeDelegate = self
			vc.recipients = ["+44 7624 800100"]
			presentViewController(vc, animated: true, completion: nil)
		} else {
			let ac = UIAlertController(title: "No text messaging", message: "Please configure your device for text messaging before continuing.", preferredStyle: .Alert)
			ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(ac, animated: true, completion: nil)
		}
	}

	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
		picker.dismissViewControllerAnimated(true, completion: nil)

		if let img = info["UIImagePickerControllerOriginalImage"] as? UIImage {
			let vc = MFMailComposeViewController()
			vc.mailComposeDelegate = self
			vc.setToRecipients(["talkingpoint@bbc.co.uk"])
			vc.setSubject("Sent from Better Beeb iPhone app")
			vc.setMessageBody("Sent from Better Beeb iPhone app", isHTML: false)

			let imageData = UIImagePNGRepresentation(img)
			vc.addAttachmentData(imageData, mimeType: "image/png", fileName: "photo.png")

			presentViewController(vc, animated: true, completion: nil)
		}
	}

	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		picker.dismissViewControllerAnimated(true, completion: nil)
	}

	func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
		// this is a hack to work around an iOS glitch: UIImagePicker likes to randomly change the status bar to something else
		UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
	}

	func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}

	func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
}
