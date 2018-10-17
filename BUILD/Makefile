VERSION = $(shell cat tmp/version/version_display.txt)
#VERSION = 56.2.4

build-hinki: | tmp/version/version_display.txt
	$(MAKE) tmp/waterfox-$(VERSION)
	$(MAKE) tmp/waterfox-$(VERSION)/debian
#	$(MAKE) tmp/waterfox-$(VERSION)/waterfox
	$(MAKE) copy
	$(MAKE) tmp/waterfox-$(VERSION)/features
	$(MAKE) tmp/waterfox-$(VERSION)/debian/changelog
	$(MAKE) debs/waterfox_$(VERSION)_amd64.deb

tmp/version:
	@mkdir -p tmp/version

tmp/version/version_display.txt: | tmp/version
	@cd tmp/version && \
	 ln -s ../../../../github/browser/config/version_display.txt

# geht erst, wenn version_display.txt existiert
tmp/waterfox-$(VERSION): | tmp/version/version_display.txt
	mkdir -p $@

tmp/waterfox-$(VERSION)/debian: | waterfox/debian tmp/waterfox-$(VERSION)
	cp -r waterfox/debian $(dir $@)

copy:
	@cp -rL ../../github/objdir/dist/bin tmp/waterfox-$(VERSION)/waterfox

tmp/waterfox-$(VERSION)/features:
	@mv tmp/waterfox-$(VERSION)/waterfox/browser/features/ tmp/waterfox-$(VERSION)

.PHONY: tmp/waterfox-$(VERSION)/debian/changelog
tmp/waterfox-$(VERSION)/debian/changelog: | tmp/waterfox-$(VERSION)/debian
	@( ! grep -q -E "__VERSION__|__TIMESTAMP__" $@ ) || \
	 sed -i -e "s|__VERSION__|$(VERSION)|" -e "s|__TIMESTAMP__|$(shell date --rfc-2822)|" $@
# Make sure correct permissions are set
	@chmod 755 tmp/waterfox-$(VERSION)/debian/waterfox.prerm
	@chmod 755 tmp/waterfox-$(VERSION)/debian/waterfox.postinst
	@chmod 755 tmp/waterfox-$(VERSION)/debian/rules
	@chmod 755 tmp/waterfox-$(VERSION)/debian/wrapper/waterfox
# Remove unnecessary files
	@rm -rf tmp/waterfox-$(VERSION)/waterfox/dictionaries
	@rm -rf tmp/waterfox-$(VERSION)/waterfox/updater
	@rm -rf tmp/waterfox-$(VERSION)/waterfox/updater.ini
	@rm -rf tmp/waterfox-$(VERSION)/waterfox/update-settings.ini
	@rm -rf tmp/waterfox-$(VERSION)/waterfox/precomplete
	@rm -rf tmp/waterfox-$(VERSION)/waterfox/icons

# Build .deb package (Requires devscripts to be installed sudo apt install devscripts). Arch and based Linux needs -d flag.
debuild: tmp/waterfox_$(VERSION)_amd64.deb
tmp/waterfox_$(VERSION)_amd64.deb: tmp/waterfox-$(VERSION)/debian/changelog
	@cd tmp/waterfox-$(VERSION) && \
	 debuild -us -uc -d

debs:
	@mkdir -p debs

debs/waterfox_$(VERSION)_amd64.deb: tmp/waterfox_$(VERSION)_amd64.deb | debs
	@cp tmp/waterfox_$(VERSION)_amd64.deb debs

install:
	@sudo dpkg -i debs/waterfox_$(VERSION)_amd64.deb

build:
	./build_wf.sh

clean:
#	rm -rf ./tmp/version
	rm -rf ./tmp/waterfox-$(VERSION)/waterfox
	rm -rf ./tmp/waterfox-$(VERSION)/debian
	rm -rf ./tmp/waterfox-$(VERSION)/features
	rm -f ./tmp/*.deb
	rm -f ./tmp/waterfox_$(VERSION)_amd64.*
	rm -f ./tmp/waterfox_$(VERSION).*
