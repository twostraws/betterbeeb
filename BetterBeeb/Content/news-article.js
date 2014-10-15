//Used to invoke function in BNArticleView UIWebView to indicate that the document (including images)
//has completely loaded to allow height to be correctly determined.
window.addEventListener("load", function () {
    location.href = "internal://iosapp";
});

(function () {
    var BASE_64_1x1_WHITE_IMAGE = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7";

    var PLAY_ICON_NORMAL;
    var PLAY_ICON_OVER;

     var touchMoving = false; //Prevent accidentally playing video whilst scrolling article.
 
    /*
     * Adds an Play icon to the argument (anchor) element that when
     * tapped, invokes the video player (based on the href attribute value).
     */
    function addPlayOverlay(element, mediaType) {
        var uri = element.getAttribute('href');
        makePlayButton(element.parentNode, uri, mediaType);
    }

    /*
     * appends a play graphic to a new anchor element
     * in the DOM and sets its URI to the specified uri arg value.
     */
    function makePlayButton(elementToAppend, uri, mediaType) {
        var imgPlay = document.createElement('div');
        imgPlay.className = mediaType === 'video' ? 'playVideoIcon' : 'playAudioIcon';
        elementToAppend.appendChild(imgPlay);
        addTouchEvents(imgPlay, uri);

    }

    function addTouchEvents(element, uri) {

        var touchEndHandler = function (e) { 
            e.target.className = PLAY_ICON_NORMAL;
 
            if(touchMoving == false) {
                location.assign(uri); //Invoke handler (in Objective-C) to play video.
                return false;
            } else {
                touchMoving = false;
            }
        };

        var touchStartHandler = function (e) {
            if(touchMoving == false) {
                e.target.className = PLAY_ICON_NORMAL + " " + PLAY_ICON_OVER;
                return false;
            }
        };

        var touchMoveHandler = function (e) {
            touchMoving = true;
        }; 

        //Video played on touchend.
        element.addEventListener("touchend",touchEndHandler,true);

        element.addEventListener("touchstart",touchStartHandler,true);

        element.addEventListener("touchmove", touchMoveHandler, true);
 
    }
    
    function isVideo(element) {
        var urlref = element.getAttribute('href');
        if (urlref != null) {
            return (urlref.substring(0, 8) == 'bbcvideo');
        }
        return false;
    }
 
    function isAudio(element) {
        var urlref = element.getAttribute('href');
        if (urlref != null) {
            return (urlref.substring(0, 8) == 'bbcaudio');
        }
        return false;
    }

    //Displays block element if hidden (used to display hidden (non-video) images and related captions.
    function displayElement(element) {
        var displayStyle = window.getComputedStyle(element, null).getPropertyValue('display');

        if (displayStyle == 'none') {
            element.style.display = 'block'; //assumption.
        }
    }

    function checkImageLoaded(img) {
        if (!img.complete) {
            return false;
        }

        //This should also determine if the image is actually loaded.
        if (typeof img.naturalWidth != "undefined" && img.naturalWidth == 0) {
            return false;
        }

        return true;
    }
 
    /* Topcat (which powers the foreign language feeds (for now) introduces
    * different CSS which makes image re-display checks fail between feed types
    */
    function isWorldServiceArticle(parentNode) {
        var parentClass = parentNode.getAttribute("class");
        if (parentClass === "bbc-image") {
            return true;
        } else {
            return false;
        }
    }

    var newsArticle = {
        init: function () {
            var images = document.getElementsByTagName('img');

            for (var i = 0; i < images.length; i++) {
                var mediaType;
                var image = images[i];

                var elementIsVideo = isVideo(image.parentNode);
                var elementIsAudio = isAudio(image.parentNode);

                if (elementIsVideo || elementIsAudio) {
                    //In the case of a video, it's the grand parent that's not displayed.
                    if (image.parentNode && image.parentNode.parentNode) {
                        displayElement(image.parentNode.parentNode);
                        image.parentNode.className = "has-avcontent";//Used for setting height (in css).
                    }

                    mediaType = elementIsVideo ? "video" : "audio";
                    PLAY_ICON_NORMAL = elementIsVideo ? "playVideoIcon" : "playAudioIcon";
                    PLAY_ICON_OVER = elementIsVideo ? "playVideoOverIcon" : "playAudioOverIcon";

                    addPlayOverlay(image.parentNode, mediaType);
                }

                if (checkImageLoaded(image) == false) {
                    image.addEventListener('load', function (e) {
                        var element = e.target;
                        if (isWorldServiceArticle(image.parentNode.parentNode.parentNode)) {
                            displayElement(image.parentNode.parentNode);
                        } else {
                            displayElement(element.parentNode);
                        }
                    });
 
                    image.addEventListener("error", function (e) {
                        e.target.src = BASE_64_1x1_WHITE_IMAGE;
                        e.target.className += ' blank-img';
                    });
                } else {
                    displayElement(image.parentNode);
                }
            }
        },
 
        /*
         * Util function used by the app to change width based on orientation.
         */
        adjustContentWidth: function (width) {
            document.getElementById("view").setAttribute('content', 'width=' + width);
        },

        /*
         * Change font-size by adding a class to the HTML element.
         * Keys are xs, s, m (default), l, xl, xxl
         */
        adjustTextSize: function (key) {
            var element = document.getElementsByTagName("html")[0];
            element.className = key;
        },

        /*
         * Util function used by app to determine where to position the section title based
         * on the left padding of the H1 element in the Web View.
         */
        getXPosForCategoryHeaderTitle: function () {
            var articlePadding = this.computeStyleProperty(document.getElementById("content")[0], "margin-left");
            return parseFloat(articlePadding);
        },

        computeStyleProperty: function (elementName, propertyValue) {
            return window.getComputedStyle(elementName, null).getPropertyValue(propertyValue);
        }
    };

    if (!window.newsArticle) {
        window.newsArticle = newsArticle;
    }

})();