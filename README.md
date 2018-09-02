# Ace Link

Mac OS X menu/status bar app that allows playing Ace Stream video streams in VLC player. Requires VLC and Docker.

Paste an Ace Stream hash in the Ace Link menu. Ace Link launches the Ace Stream server in Docker and starts VLC with the Ace Stream server URL.

## [Download for Mac](https://github.com/blaise-io/acelink/releases)

![Ace Link](https://i.imgur.com/QwMOUEp.png)

### To do, maybe

 - Show stream meta info
 - Validate stream is working before launching VLC
 - Stop the server when VLC is closed 
 - Use the Wine version of Ace Stream and remove Docker dependency
