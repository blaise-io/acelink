# Ace Link

Ace Link is a menu bar app that allows playing Ace Streams on macOS. 

Play an Ace Stream or Magnet in any media player by pasting the URL in the Ace Link menu, or open an acestream or magnet link in Ace Link.

## [Download for macOS](https://github.com/blaise-io/acelink/releases/download/2.0.0/Ace.Link.2.0.0.dmg)

 - Install using HomeBrew: `brew install --cask ace-link`
 - [Download an older version](https://github.com/blaise-io/acelink/releases)

Requires Docker and macOS High Sierra (10.13) or later.

<img src="acelink.png" width="350" alt="Ace Link" />

### Media players

Ace Link allows selecting your own media player. Ace link does not transcode streams, so pick a player that supports popular audio and video codecs. Free and open source media players that play anything are VLC, IINA and MPV. QuickTime and web browsers will play most streams, but not all. 

### Signing

Ace Link is an unsigned app because Apple does not allow p2p related applications. If your version of macOS does not allow opening unsigned applications, [follow these instructions to bypass this restriction](http://osxdaily.com/2016/09/27/allow-apps-from-anywhere-macos-gatekeeper/).

### Ace Stream server only

If you want to run the AceStream engine without running Ace Link, you can just run `docker run --rm -p 6878:6878 blaiseio/acelink`. You can mount a custom config file: 
```
docker run --rm -p 6878:6878 -v "$(pwd)/acestream.conf:/opt/acestream/acestream.conf" blaiseio/acelink
```