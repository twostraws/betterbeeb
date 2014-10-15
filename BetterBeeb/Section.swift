//
//  Section.swift
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

class Section : NSObject, NSXMLParserDelegate, NSCoding {
	var title: String
	var feedURL: String
	var stories: [Story]

	var isUpdating: Bool = false
	var tempStories: [Story]!

	init(title: String, url: String) {
		self.title = title
		self.feedURL = url
		self.stories = [Story]()
	}

	required init(coder aDecoder: NSCoder) {
		title = aDecoder.decodeObjectForKey("title") as String
		feedURL = aDecoder.decodeObjectForKey("feedURL") as String
		stories = aDecoder.decodeObjectForKey("stories") as [Story]

		super.init()

		for story in stories {
			story.section = self
		}
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(title, forKey: "title")
		aCoder.encodeObject(feedURL, forKey: "feedURL")
		aCoder.encodeObject(stories, forKey: "stories")
	}

	func update() -> Bool {
		if isUpdating { return true }

		isUpdating = true

		var url = NSURL(string: self.feedURL)

		var err: NSErrorPointer = nil
		var contents: NSString! = NSString(contentsOfURL: url, usedEncoding: nil, error: err)

		if contents == nil || err != nil {
			// failed to fetch any content for some reason
			isUpdating = false
			return false
		}

		// the BBC feed sends in the story data as XML inline with the story metadata, which is ugly. This hack forces the story
		// to be treated as character data so we can read it as one lump of XHTML.
		contents = contents.stringByReplacingOccurrencesOfString("<content type=\"xhtml\">", withString: "<content type=\"xhtml\"><![CDATA[")
		contents = contents.stringByReplacingOccurrencesOfString("</content>", withString: "]]></content>")

		if let contentsData = contents.dataUsingEncoding(NSUTF8StringEncoding) {
			var xmlParser = NSXMLParser(data: contentsData)
			xmlParser.delegate = self

			self.tempStories = [Story]()
			xmlParser.parse()
			stories = tempStories

			isUpdating = false

			return true
		}

		isUpdating = false

		return false
	}

	func parser(parser: NSXMLParser, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
		if (elementName == "entry") {
			let story: Story = Story(parentSection: self, parser: parser)
			tempStories.append(story)
		}
	}
}