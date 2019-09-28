# Ace Link

Mac OS X menu/status bar app that allows playing Ace Stream video streams in VLC player. 

Paste an Ace Stream hash in the Ace Link menu. Ace Link launches the Ace Stream server in Docker and starts VLC with the Ace Stream server URL.


## [Download for macOS](https://github.com/blaise-io/acelink/releases)

Requires VLC, Docker and macOS High Sierra (10.13) or higher.

![Ace Link](https://i.imgur.com/QwMOUEp.png)


### Ace Stream server only

If you only want to run the Ace Stream server in Docker, just run  
[`docker run -p 6878:6878 blaiseio/acestream`](https://cloud.docker.com/u/blaiseio/repository/docker/blaiseio/acestream)


### To do, maybe

 - Show stream meta info in VLC
 - Maintain a history of streams
 - Validate that a stream is working before launching VLC
