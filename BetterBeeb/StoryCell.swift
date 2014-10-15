//
//  StoryCell.swift
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

import UIKit

class StoryCell: UICollectionViewCell {
	var story: Story!
	var imageView: UIImageView!
	var title: UILabel!
	var titleContainer: UIView!
	var highlight: UIView!

	override init(frame: CGRect) {
		super.init(frame: frame)

		contentView.backgroundColor = UIColor.blackColor()

		imageView = UIImageView()
		title = UILabel()
		titleContainer = UIView()
		highlight = UIView()

		imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
		title.setTranslatesAutoresizingMaskIntoConstraints(false)
		titleContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
		highlight.setTranslatesAutoresizingMaskIntoConstraints(false)
		highlight.backgroundColor = UIColor.blackColor()

		imageView.contentMode = .ScaleAspectFill
		imageView.backgroundColor = UIColor.blackColor()
		titleContainer.backgroundColor = UIColor.blackColor()

		title.numberOfLines = 3

		contentView.addSubview(imageView)
		titleContainer.addSubview(title)
		contentView.addSubview(titleContainer)
		contentView.addSubview(highlight)

		let viewsDictionary = ["imageView" : imageView, "title" : title, "titleContainer" : titleContainer, "highlight" : highlight]
		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(==4)-[titleContainer]-(==4)-|", options: .allZeros, metrics: nil, views: viewsDictionary))
		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[highlight]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView(==72)]-(==2)-[titleContainer(>=52)][highlight(==8)]|", options: .allZeros, metrics: nil, views: viewsDictionary))

		titleContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[title]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		titleContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[title]-(>=0)-|", options: .allZeros, metrics: nil, views: viewsDictionary))
		title.setContentHuggingPriority(1000, forAxis: .Vertical)
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	func setStory(story: Story) {
		self.story = story

		let attrs = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont.systemFontOfSize(14)]
		title.attributedText = NSAttributedString(string: story.title, attributes: attrs)

		imageView.image = nil

		var fm = NSFileManager.defaultManager()
		var thumbnailFilename = getDocumentsDirectory().stringByAppendingPathComponent("img-\(story.thumbnail.lastPathComponent)")

		if fm.fileExistsAtPath(thumbnailFilename) {
			let thumbnailImage = UIImage(contentsOfFile: thumbnailFilename)
			self.imageView.image = thumbnailImage
		} else {
			downloadImage(NSURL(string: story.thumbnail)) { [weak self] image, error in
				if self == nil { return }
				if error != nil { return }
				
				self?.imageView.image = image

				let imageData = UIImageJPEGRepresentation(image, 95)
				imageData.writeToFile(thumbnailFilename, atomically: true)
			}
		}
	}

	func setHighlightedStory(highlighted: Bool) {
		if highlighted {
			highlight.backgroundColor = UIColor.beebRed()
		} else {
			highlight.backgroundColor = UIColor.blackColor()
		}
	}
}
