//
//  Story.swift
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

class Story : NSObject, NSXMLParserDelegate, NSCoding {
	var title: String!
	var summary: String!
	var category: String!
	var updated: NSDate!
	var id: String!
	var linkHref: String!
	var linkTitle: String!
	var thumbnail: String!
	var content: String!

	weak var section: Section!
	var currentText: String = ""

	override init() {
		super.init()
	}

	init(parentSection: Section, parser: NSXMLParser) {
		super.init()

		section = parentSection
		parser.delegate = self
	}

	required init(coder aDecoder: NSCoder) {
		title = aDecoder.decodeObjectForKey("title") as String
		summary = aDecoder.decodeObjectForKey("summary") as String
		category = aDecoder.decodeObjectForKey("category") as String
		updated = aDecoder.decodeObjectForKey("updated") as NSDate
		id = aDecoder.decodeObjectForKey("id") as String
		linkHref = aDecoder.decodeObjectForKey("linkHref") as String
		linkTitle = aDecoder.decodeObjectForKey("linkTitle") as String
		thumbnail = aDecoder.decodeObjectForKey("thumbnail") as String
		content = aDecoder.decodeObjectForKey("content") as String
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(title, forKey: "title")
		aCoder.encodeObject(summary, forKey: "summary")
		aCoder.encodeObject(category, forKey: "category")
		aCoder.encodeObject(updated, forKey: "updated")
		aCoder.encodeObject(id, forKey: "id")
		aCoder.encodeObject(linkHref, forKey: "linkHref")
		aCoder.encodeObject(linkTitle, forKey: "linkTitle")
		aCoder.encodeObject(thumbnail, forKey: "thumbnail")
		aCoder.encodeObject(content, forKey: "content")

	}

	func parser(parser: NSXMLParser, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
		if (elementName == "link") {
			linkHref = (attributeDict["href"] as AnyObject?) as String
			linkTitle = (attributeDict["title"] as AnyObject?) as String
		} else if (elementName == "media:thumbnail") {
			let originalURL = (attributeDict["url"] as AnyObject?) as NSString
			thumbnail = cleanImageURL(originalURL)
		}
	}

	func parser(parser: NSXMLParser, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
		switch elementName {
		case "title":
			title = currentText.trim()
			currentText = ""

		case "summary":
			summary = currentText.trim()
			currentText = ""
			break

		case "category":
			category = currentText.trim()
			currentText = ""
			break

		case "updated":
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
			let sourceString = currentText.trim()

			if let date = dateFormatter.dateFromString(sourceString) {
				updated = date
			}

			currentText = ""
			break

		case "id":
			id = currentText.trim()
			currentText = ""
			break

		case "content":
			var parsedString = currentText.trim() as NSString

			let imageDeviceRegex = NSRegularExpression(pattern: "(bbcimage://.*)(%7bdevice%7d)(.*)", options: NSRegularExpressionOptions.AllowCommentsAndWhitespace, error: nil)
			parsedString = imageDeviceRegex.stringByReplacingMatchesInString(parsedString, options: .allZeros, range: NSMakeRange(0, parsedString.length), withTemplate: "$1iphone-retina$3")

			let imageRegex = NSRegularExpression(pattern: "bbcimage://[^/]+", options: NSRegularExpressionOptions.AllowCommentsAndWhitespace, error: nil)
			parsedString = imageRegex.stringByReplacingMatchesInString(parsedString, options: .allZeros, range: NSMakeRange(0, parsedString.length), withTemplate: "http:/$1")

			content = parsedString

			currentText = ""
			break

		case "entry":
			parser.delegate = section			
			currentText = ""
			break

		default:
			currentText = ""
			break
		}
	}

	func parser(parser: NSXMLParser, foundCharacters string: String) {
		currentText += string
	}

	func cleanImageURL(url: NSString) -> String {
		let deviceSpecific = url.stringByReplacingOccurrencesOfString("%7bdevice%7d", withString: "iphone-retina") as NSString
		let idx = deviceSpecific.rangeOfString("ichef.bbci").location
		return "http://" + deviceSpecific.substringFromIndex(idx)
	}
}