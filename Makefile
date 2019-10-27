VERSION := $(shell cat "$(CURDIR)/Ace Link.xcodeproj/project.pbxproj" \
	| grep MARKETING_VERSION -m1 | sed 's/.* = \(.*\);/\1/')
RELEASEDIR ?= $(CURDIR)/builds/Ace.Link.$(VERSION)

TODO: Populate MARKETING_VERSION from VERSION file instead

docker-image:
	# Build the Docker image
	# Also built automatically by https://hub.docker.com/r/blaiseio/acelink
	docker stop acelink--ace-stream-server || true
	docker build . --squash --tag blaiseio/acelink:$(VERSION)

release-dmg:
	# Create a new release DMG
	rm -rf $(RELEASEDIR)
	mkdir -p $(RELEASEDIR)
	cp -R 'builds/Ace Link/Ace Link.app' $(RELEASEDIR)
	ln -s /Applications $(RELEASEDIR)/Applications
	hdiutil create -volname "Ace Link $(VERSION)" -srcfolder $(RELEASEDIR) -ov -format UDZO $(RELEASEDIR).dmg
	open https://github.com/blaise-io/acelink/releases/new

release-tag:
	# Create a new release tag
	git tag $(VERSION)
	git push origin --tags

.PHONY: $(MAKECMDGOALS)
