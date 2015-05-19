# Screentendo

Turn part of your screen into a playable level of Mario.

Why?

How?
 Two steps
   Image processing
     Fetch image from (second to) top level window, at coordinates/offset from Screentendo window

     motionBlurImage
     luminanceFilterImage
     pixelateImage
     blackAndWhiteImage
     sub-block
     calculate average block colour and convert to array

   Level generation and game logic
     use array representation of image to draw blocks on screen
     basic SpriteKit physics
