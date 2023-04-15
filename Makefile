VERSION := $(shell cat VERSION)
ARCHIVEDIR ?= $(CURDIR)/builds/archives/Ace.Link.$(VERSION).xcarchive
RELEASEDIR ?= $(CURDIR)/builds/Ace.Link.$(VERSION)
DOCKER_BUILDKIT ?= 1
DOCKER_DEFAULT_PLATFORM ?= linux/amd64

docker:
	# Create docker image
	docker build . --tag blaiseio/acelink:$(VERSION) --progress=plain

build:
	# Create a build
	sed -i '' 's/[0-9]\.[0-9]\.[0-9]/$(VERSION)/g' README.md
	agvtool new-marketing-version $(VERSION)
	xcodebuild -scheme 'Ace Link' archive -archivePath $(ARCHIVEDIR)

tag:
	# Create a new release tag
	git tag $(VERSION)
	git push origin --tags

release:
	# Create a new release DMG from the latest build
	rm -rf $(RELEASEDIR)
	mkdir -p $(RELEASEDIR)
	cp -R '$(ARCHIVEDIR)/Products/Applications/Ace Link.app' $(RELEASEDIR)
	ln -s /Applications $(RELEASEDIR)/Applications
	hdiutil create -volname "Ace Link $(VERSION)" -srcfolder $(RELEASEDIR) -ov -format UDZO $(RELEASEDIR).dmg
	rm -rf $(RELEASEDIR)
	open -a finder $(CURDIR)/builds
	open https://github.com/blaise-io/acelink/releases/new
