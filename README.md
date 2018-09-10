# Ace Link

Mac OS X menu/status bar app that allows playing Ace Stream video streams in VLC player. 

Paste an Ace Stream hash in the Ace Link menu. Ace Link launches the Ace Stream server in Docker and starts VLC with the Ace Stream server URL.

## [Download for Mac](https://github.com/blaise-io/acelink/releases)

Requires VLC, Docker and Mac OS X High Sierra (10.13.x).

![Ace Link](https://i.imgur.com/QwMOUEp.png)


### To do, maybe

 - Show stream meta info 
 - Maintain history of streams (help needed: how do I retrieve a stream's title from the Ace Stream server?)
 - Validate stream is working before launching VLC
 - Use the Wine version of Ace Stream and remove Docker dependency
