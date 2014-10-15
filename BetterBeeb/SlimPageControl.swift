//
//  SlimPageControl.swift
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

class SlimPageControl: UIPageControl {
	override init() {
		super.init()
		self.backgroundColor = UIColor.clearColor()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		for vw in subviews as [UIView] {
			// hide the pretty circular views, but keep their spacing for AutoLayout
			vw.alpha = 0
		}
	}

	override func drawRect(rect: CGRect) {
		// We have custom drawing code to draw Beeb-style squares. They aren't very attractive, but oh well…
		super.drawRect(rect)

		let context = UIGraphicsGetCurrentContext()
		CGContextSaveGState(context)
		CGContextSetAllowsAntialiasing(context, true)

		var dotSize = 7
		var dotSpacing = 6
		var dotY = (self.frame.size.height - CGFloat(dotSize)) / 2
		var dotsWidth = (dotSize * self.numberOfPages) + (self.numberOfPages - 1) * dotSpacing
		var offset = (self.frame.size.width - CGFloat(dotsWidth)) / 2

		for (var i = 0; i < self.numberOfPages; i++) {
			var dotRect = CGRectMake(offset + (CGFloat(dotSize) + CGFloat(dotSpacing)) * CGFloat(i), dotY, CGFloat(dotSize), CGFloat(dotSize))
			
			if (i == self.currentPage) {
				CGContextSetFillColorWithColor(context, currentPageIndicatorTintColor?.CGColor)
				CGContextFillRect(context, dotRect)
			} else {
				CGContextSetFillColorWithColor(context, pageIndicatorTintColor?.CGColor)
				CGContextFillRect(context, dotRect)
			}
		}

		CGContextRestoreGState(context)
	}

	override var currentPage: Int {
		didSet {
			setNeedsDisplay()
		}
	}
}
