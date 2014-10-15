//
//  SectionCell.swift
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

class SectionCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	weak var parentViewController: StoriesViewController!
	var section: Section!

	var leftLabel: UILabel!
	var rightLabel: UILabel!

	var collectionView: UICollectionView!
	var flowLayout: UICollectionViewFlowLayout!


	required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		selectionStyle = .None
		backgroundColor = UIColor.beebBackgroundGrey()

		let topRow = UIView()
		let bottomRow = UIView()

		leftLabel = UILabel()
		rightLabel = UILabel()

		topRow.setTranslatesAutoresizingMaskIntoConstraints(false)
		bottomRow.setTranslatesAutoresizingMaskIntoConstraints(false)
		leftLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		rightLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

		rightLabel.textAlignment = .Right



		flowLayout = UICollectionViewFlowLayout()
		flowLayout.scrollDirection = .Horizontal

		collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
		collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)

		collectionView.delegate = self
		collectionView.dataSource = self

		flowLayout.sectionInset = UIEdgeInsetsMake(0, 6, 0, 6)
		flowLayout.minimumInteritemSpacing = 6
		flowLayout.itemSize = CGSizeMake(128, 134)
		collectionView.backgroundColor = UIColor.beebBackgroundGrey()
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.scrollsToTop = false
		collectionView.decelerationRate = UIScrollViewDecelerationRateFast

		collectionView.registerClass(StoryCell.self, forCellWithReuseIdentifier: "Story")


		topRow.addSubview(leftLabel)
		topRow.addSubview(rightLabel)
		bottomRow.addSubview(collectionView)

		contentView.addSubview(topRow)
		contentView.addSubview(bottomRow)


		let viewsDictionary = ["topRow" : topRow, "bottomRow" : bottomRow, "leftLabel" : leftLabel, "rightLabel" : rightLabel, "collectionView" : collectionView]

		topRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(==6)-[leftLabel]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		topRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(==8)-[leftLabel]-(==8)-|", options: .allZeros, metrics: nil, views: viewsDictionary))
		topRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[rightLabel]-(==6)-|", options: .allZeros, metrics: nil, views: viewsDictionary))
		topRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(==8)-[rightLabel]-(==8)-|", options: .allZeros, metrics: nil, views: viewsDictionary))

		bottomRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		bottomRow.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView(==134)]|", options: .allZeros, metrics: nil, views: viewsDictionary))

		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[topRow]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bottomRow]|", options: .allZeros, metrics: nil, views: viewsDictionary))
		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[topRow][bottomRow]|", options: .allZeros, metrics: nil, views: viewsDictionary))		
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	func setSectionTitle(str: String) {
		let attrs = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont.boldSystemFontOfSize(16)]
		let title = NSAttributedString(string: str.uppercaseString, attributes: attrs)

		leftLabel.attributedText = title
	}

	func setSectionDate(str: String) {
		let attr = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont.boldSystemFontOfSize(11)]
		let title = NSAttributedString(string: str, attributes: attr)

		rightLabel.attributedText = title
	}

	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if self.section == nil { return 0 }
		return self.section.stories.count
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Story", forIndexPath: indexPath) as StoryCell

		let story = section.stories[indexPath.item]
		cell.setStory(story)

		if parentViewController.selectedStoryID != nil && parentViewController.selectedStoryID == story.id {
			cell.setHighlightedStory(true)
		} else {
			cell.setHighlightedStory(false)
		}

		return cell
	}

	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		parentViewController.showStory(section.stories[indexPath.item])
	}

	func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		var visibleWidth = 10 + flowLayout.itemSize.width
		let indexOfItemToSnap: Int = Int(round(targetContentOffset.memory.x / visibleWidth))

		if (targetContentOffset.memory.x >= scrollView.contentSize.width - scrollView.bounds.size.width) {
			// we're trying to scroll to the very last element, so scroll to the end
			targetContentOffset.memory = CGPointMake(collectionView.contentSize.width - collectionView.bounds.size.width, 0)
		} else {
			// we're trying to scroll to any element that is not the last, so snap to it
			targetContentOffset.memory = CGPointMake(CGFloat(indexOfItemToSnap) * visibleWidth, 0)
		}
	}

	func highlightStory(highlighted: Story) {
		let visibleCells = collectionView.visibleCells() as [StoryCell]

		for cell in visibleCells {
			if cell.story.id == highlighted.id {
				cell.setHighlightedStory(true)
			} else {
				cell.setHighlightedStory(false)
			}
		}
	}
}
