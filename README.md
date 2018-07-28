# Ace Link

Mac OS X menu/status bar app that allows playing Ace Stream videos in VLC. Requires VLC and Docker.

How it works: Paste an Ace Stream hash in the Ace Link menu. Ace Link will launch the Ace Stream server in Docker and starts VLC with the Ace Stream server URL once started. When exiting Ace Link, it will shut down the Ace Stream server.

**[Download the beta for Mac](https://github.com/blaise-io/acelink/releases)**

![Ace Link](https://i.imgur.com/QwMOUEp.png)

### To do, maybe

 - Open streams from the command line
 - Show stream meta info
 - Stop the server when VLC is closed
 - Requires VLC and Docker

### Research

 - Use a more minimal Docker container, or
 - Use the Wine version of Ace Stream
