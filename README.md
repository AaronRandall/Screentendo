# Screentendo

Turn part of your screen into a playable level of Super Mario Bros.

What
====
A desktop app that allows you to select a region of the screen, and have that selection converted into a playable level of Super Mario Bros.

![](https://github.com/AaronRandall/Screentendo/blob/master/Screentendo/Screentendo.gif)

Why
====
The idea came from a joke with a friend at work - he spends a bunch of his time looking at graphs (for monitoring our servers), and I joked with him that one day I'd build an app that he could overlay on those graphs to turn them into something more interesting. A short while later we had a hackday at the Songkick office, and I cobbled something together that eventually became 'Screentendo'.

Also, I've never built a Cocoa app or used SpriteKit before, so it seemed like a good excuse to play with those technologies.

How
====
When Screentendo is run, a semi-transparent window appears on screen, and can be placed over other application windows to use them as the source of level generation. After placing the Screentendo window over the desired region, clicking on it will start the level generation.

There are two basic steps to Screentendo; image processing to determine the structure of the overlayed window (the crux of the app), and level generation.

Image processing
----------------
* Fetch image from (second to) top level window, at coordinates/offset from Screentendo window
- CGWindowListCopyWindowInfo from the Quartz Window Services API returns a list of windows in the users current session, in the order in which they appear on the screen.
- the application fetches the top-most window (which is always going to be the Screentendo window you've just clicked as it currently has focus), and the second window in the hierarchy (the window you've overlayed).
- CGWindowListCreateImage is used to retrieve an image of the overlayed window (using the CGWindowID)
- the image is then cropped to the bounds of the Screentendo window

[IMAGE OF OVERLAYED IMAGE, SCREENTENDO WINDOW. SHOWING OVERLAY WITH ARROWS, ORIGINS, ETC]

The cropped image is then passed through a number of image filters:

[CROPPED IMAGE]

* motion blur - this helps to reduce the impact of general noise/artefacts in the image
[MOTION-BLURRED IMAGE]
* luminance filter - an average luminance threshold filter calculates the average luminance threshold of the image, and then reduces it to two colours based on the calculated threshold
[LUMINANCE FILTERED IMAGE]
* pixelate - a pixellation filter is applied to simplify the image detail
[PIXELLATED IAMGE]
* black and white - if the luminance filter reduced to a threshold of non black/white values, this filter will reduce to that
[BLACK AND WHITE IMAGE]
* sub-block - the image is then split into sub-blocks (by default, 10x10 pixels)
[SUB-BLOCKED IMAGE]
* calculate average block colour and convert to array - for each sub-block in the image, the average colour of the sub-block is calculated.
[AVERAGE VALUE OF BLOCK]
* array of binary values returned - a 2-dimensional array is constructed based on the average sub-block colours; any sub-block with an average colour which is mostly black is set to '1', and sub-block with an average colour which is mostly white is set to '0'.'
[IMAGE TO ARRAY]

Level generation and game logic
-------------------------------
The 2-dimensional binary representation of the image is passed to the GameScene class, which is responsible for generating the game.

Iterating over the array, any array values of 1 are generated as blocks, 0's are ignored. When the array has been processed, the background, clouds, and player sprite are added to the scene.

The rest of the game play relies on some simple use of the SpriteKit physics engine (to handle player physics, detect collisions, animate block debris, etc).

When the window is resized or moved, the scene is reset, ready to be generated (by another mouse click).

The app also has a menu option to change the block size (small, medium, large). A smaller block size increases the resolution, but takes longer to process.

[EXAMPLES OF BLOCK SIZES AS SCREENSHOTS]

Limitations
===========
This app is a proof-of-concept, not a production quality app. 

Image processing is currently REALLY slow, sub-blocking the image takes an age (each sub-block is an NSImage, which is likely a very inefficient way to solve the problem).
The current implemetation requires a pretty distinct contrast in the underlying image for the generated level to work - detecting the average colour of the entire image and using that as the threshold would probably help with this.

[More examples, with Textedit, Mario, Obama, Graph, etc.]


Downloads
=========
GitHub repo. App binary.
