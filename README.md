# Ace Link

Ace Link is a macOS menu bar app that allows playing Ace Stream video streams in VLC player. 

Paste an Ace Stream hash in the Ace Link menu. Ace Link will launch the Ace Stream server in Docker and open your stream in VLC. You can also launch Ace Link by opening an acestream:// link directly from a website.


## [Download for macOS](https://github.com/blaise-io/acelink/releases/download/1.4.0/Ace.Link.1.4.0.dmg)

Requires VLC, Docker and macOS High Sierra (10.13) or higher.

![Ace Link](https://i.imgur.com/QwMOUEp.png)

Ace Link is an unsigned app because Apple does not allow p2p related applications. If your version of macOS does not allow opening unsigned applications, [follow these instructions to bypass this restriction](http://osxdaily.com/2016/09/27/allow-apps-from-anywhere-macos-gatekeeper/).

 - [Download an older version](https://github.com/blaise-io/acelink/releases)


### Ace Stream server only

If you want to play a stream using a player other than VLC, run [`docker run -p 6878:6878 blaiseio/acestream`](https://cloud.docker.com/u/blaiseio/repository/docker/blaiseio/acestream) and open `http://127.0.0.1:6878/ace/getstream?id=<hash>` in a player with HLS support.
