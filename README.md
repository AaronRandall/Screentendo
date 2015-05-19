# Screentendo

Turn part of your screen into a playable level of Mario.

What
A desktop app for Mac that allows you to select a region of the screen, and have that selection converted into a playable level of Mario.

[Demo gif]

Why
It started as a joke with a friend at work - he spends a bunch of his time looking at graphs (for monitoring our servers), and I joked with him that one day I'd build an app that he could overlay on those graphs to turn them into something more interesting. A short while later we had a hackday at the Songkick office, and I cobbled something together that, with a little SpriteKit magic, became 'Screentendo'.

I've never built a Cocoa app before, or used SpriteKit, so it seemed like a good excuse to play with those technologies.

How
 Two steps
   Image processing
     Fetch image from (second to) top level window, at coordinates/offset from Screentendo window

     motion blur
     luminance filter
     pixelate
     black and white
     sub-block
     calculate average block colour and convert to array

   Level generation and game logic
     use array representation of image to draw blocks on screen
     basic SpriteKit physics

Limitations
REALLY SLOW to do image processing. Really inefficient way of sub-blocking NSImage (into smaller NSImages).
Currently requires pretty good contrast for underlying image.
