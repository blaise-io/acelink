# Ace Link

Ace Link is a menu bar app that allows playing Ace Streams on macOS. 

Play an Ace Stream or Magnet in any media player by pasting the URL in the Ace Link menu, or open an acestream or magnet link in Ace Link.

## [Download for macOS](https://github.com/blaise-io/acelink/releases/download/2.0.5/Ace.Link.2.0.5.dmg)

 - Install using HomeBrew: `brew install --cask ace-link`
 - [Download an older version](https://github.com/blaise-io/acelink/releases)

Requires Docker and macOS High Sierra (10.13) or later.

<img src="acelink.png" width="350" alt="Ace Link" />

### Media players

Ace Link allows selecting your own media player. Ace link does not transcode streams, so pick a player that supports popular audio and video codecs. VLC, IINA and MPV are free and open source media players that are able to play nearly anything. QuickTime and web browsers will play most streams, but not all. 

### Signing

Ace Link is an unsigned app because Apple does not allow p2p related applications. If your version of macOS does not allow opening unsigned applications, [follow these instructions to bypass this restriction](https://apple.stackexchange.com/a/240560).

### Ace Stream server only

If you just want to run the AceStream engine, you can do so without Ace Link:

```sh
docker run --rm -p 6878:6878 blaiseio/acelink
# now open http://<network ip>:6878/ace/getstream?id=<acestream id>
# or http://<network ip>:6878/ace/getstream?infohash=<magnet uri> in a player
```

If you want to use a custom acestream.conf: 
```
docker run --rm -p 6878:6878 -v "$(pwd)/acestream.conf:/opt/acestream/acestream.conf" blaiseio/acelink
```
