//
//  TickerItem.swift
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

class TickerItem : NSObject, NSCoding {
	var id: String
	var headline: String
	var prompt: String
	var url: String
	var isLive: String
	var isBreaking: String

	init(id: String, headline: String, prompt: String, url: String, isLive: String, isBreaking: String) {
		self.id = id
		self.headline = headline
		self.prompt = prompt
		self.url = url
		self.isLive = isLive
		self.isBreaking = isBreaking
	}

	required init(coder aDecoder: NSCoder) {
		id = aDecoder.decodeObjectForKey("id") as String
		headline = aDecoder.decodeObjectForKey("headline") as String
		prompt = aDecoder.decodeObjectForKey("prompt") as String
		url = aDecoder.decodeObjectForKey("url") as String
		isLive = aDecoder.decodeObjectForKey("isLive") as String
		isBreaking = aDecoder.decodeObjectForKey("isBreaking") as String
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(id, forKey: "id")
		aCoder.encodeObject(headline, forKey: "headline")
		aCoder.encodeObject(prompt, forKey: "prompt")
		aCoder.encodeObject(url, forKey: "url")
		aCoder.encodeObject(isLive, forKey: "isLive")
		aCoder.encodeObject(isBreaking, forKey: "isBreaking")
	}
}