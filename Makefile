VERSION ?= $$(cat VERSION)
RELEASEDIR ?= $(CURDIR)/builds/Ace.Link.$(VERSION)

docker-image:
	docker stop acelink--ace-stream-server || true
	docker build . --squash --tag blaiseio/acelink:$(VERSION)

release:
	# git tag $$(cat VERSION)
	rm -rf $(RELEASEDIR)
	mkdir -p $(RELEASEDIR)
	cp -R 'builds/Ace Link/Ace Link.app' $(RELEASEDIR)
	ln -s /Applications $(RELEASEDIR)/Applications
	hdiutil create -volname "Ace Link $(VERSION)" -srcfolder $(RELEASEDIR) -ov -format UDZO $(RELEASEDIR).dmg
