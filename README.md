# Ace Link

Ace Link is a macOS menu bar app that allows playing Ace Stream video streams in VLC player. 

Paste an Ace Stream hash in the Ace Link menu. Ace Link will launch the Ace Stream server in Docker and open your stream in VLC.


## [Download for macOS](https://github.com/blaise-io/acelink/releases)

Requires VLC, Docker and macOS High Sierra (10.13) or higher.

![Ace Link](https://i.imgur.com/QwMOUEp.png)


### Ace Stream server only

If you want to play a stream using a player other than VLC, run [`docker run -p 6878:6878 blaiseio/acestream`](https://cloud.docker.com/u/blaiseio/repository/docker/blaiseio/acestream) and open http://127.0.0.1:6878/ace/getstream?id=<hash> in a player with HLS support.


### To do

 - Show stream meta info in VLC
 - Maintain a history of streams
 - Validate that a stream is working before launching VLC
