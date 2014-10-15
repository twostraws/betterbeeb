Better Beeb
===========

TL;DR: This is a clean room re-implementation of the BBC News app for iPhone, written in Swift and released under the MIT licence. If you have questions, find me on Twitter @twostraws.

Long version: This is an open source re-implementation of the BBC News app for iOS. It's written entirely in Swift, it uses Auto Layout extensively to ensure great layouts on all supported iPhone devices, and it uses controls like UIRefreshControl, UICollectionView and UIPageViewController that were not available when the BBC News app was first built.

You might very well ask why I did this, and the answer is simple: the BBC News app is one of my all-time favourites, and I launch it maybe a dozen times a day. But it hasn't had an update in almost a year, and even then it was only minor fixes, so it's really started to struggle with recent iOS changes. There is an app development team at the BBC, but I suspect they are being given directives to work on other things (iPlayer, BBC Sport, etc) and are doing their best to keep up, but sadly that means the BBC News app hasn't had much love.

So, my version fixes that. It is my homage, my thank you, to the BBC app development team for all their hard work. I'm making all the source code freely available and freely reusable under the MIT licence, because a) even though I've stripped out any BBC branding I still can't really ship this app, b) anyone curious about Swift can read my code and learn from a real, working app, and c) I hope maybe someone at the BBC sees this and decides to give the BBC News app the refresh it deserves. And if they want to read or even use any of my code, it's here for the taking under an open licence.


What's different?
-----------------

This update, immodestly called Better Beeb, fixes some things that have been bothering me for a while:

- It's now fully iOS 7 themed, which means the black status bar is dead and you can finally watch videos in full screen.

- Images now fill the full width of the screen on iPhone 6 and iPhone 6 Plus, just like they used to do on iPhone 5 and earlier.

- It has the "left-edge swipe" gesture to go back from the reading view to the list view, which means iPhone 5, iPhone 6 and iPhone 6 Plus users can navigate around more easily.

- It's ARM64 ready, so it will run faster for owners of iPhone 5s or later.

- Many small niggles are resolved. For example, the scrollbar no longer goes off the screen when reading stories, the story refresh no longer freezes up if your connection is poor, stories no longer scroll back to the top if you multitask, the inability to scroll quickly between stories in the reading view has been eradicated, and you can even use the "Send Photo" button more than once without locking up the app.


What's missing?
---------------

In terms of how close it is to the existing app, there are a few areas of notable difference - partly on a design whim, and partly because I have other things to work on. You're welcome to fork this and implement as you see fit.

- Better Beeb does not include iPad support. Clearly this would need to be added at some point, but it's unlikely to be tricky.

- Better Beeb is written for iOS 8, which would be a problem on the App Store because so many users are still on iOS 7. However, I have limited my usage of iOS 8 APIs, and indeed the only instance I can think of is the new UIAlertController class rather than UIActionSheet and UIAlertView. This would be trivial to change, and would allow the app to support iOS 7 and 8 and thus 94% of users.

- Better Beeb does away with having collapsible sections, because it always felt a bit pointless. You can of course reorder them as you want, but I nearly always find myself going through all the sections anyway. Again, this would be trivial to add if it were a popular request.

- Better Beeb does away with pull to refresh while you're reading stories. This seemed to work inconsistently before, and even when it worked it only ever seemed useful for live sports reporting - something that BBC News online long ago replaced with streaming updates.

- I have on occasion been a touch lazy. For example, the BBC News app uses different video URLs if you're on 3G to WiFi. As I made this app for myself and am happy to exchange 3G bandwidth for better video, I've made it always use WiFi. Sorry!


So, that's it from me. To summarise, I'm not trying to replace the BBC News app, I'm not trying to pass myself off as part of the BBC, and I hope I'm not treading on any toes. Indeed, for all I know there could be a BBC News app update out in just a few days that does all this and much more – and I would welcome it greatly!
