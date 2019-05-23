#VERSION = $(shell cat tmp/version/version_display.txt)
VERSION = $(eval VERSION := $(shell cat tmp/version/version_display.txt))$(VERSION)
github-dir := ../github

build-hinki: \
	tmp/waterfox-$(VERSION)/features \
	tmp/waterfox-$(VERSION)/debian/changelog \
	debs/waterfox_$(VERSION)_amd64.deb \
  | tmp/version/version_display.txt

# depend to re-evaluate.
# not the first target.
Makefile: tmp/version/version_display.txt

tmp/version/version_display.txt: | tmp/version
	@cd tmp/version && \
	 ln -s ../../$(github-dir)/browser/config/version_display.txt

tmp/version:
	@mkdir -p tmp/version

# geht erst, wenn version_display.txt existiert
tmp/waterfox-$(VERSION): | tmp/version/version_display.txt
	mkdir -p $@

tmp/waterfox-$(VERSION)/debian: | waterfox tmp/waterfox-$(VERSION)
	cp -r waterfox $@

tmp/waterfox-$(VERSION)/waterfox: $(github-dir)/objdir/dist/bin | tmp/waterfox-$(VERSION)
	@rm -rf $@
	@cp -rL $(github-dir)/objdir/dist/bin tmp/waterfox-$(VERSION)/waterfox

tmp/waterfox-$(VERSION)/features: | tmp/waterfox-$(VERSION)/waterfox
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
tmp/waterfox_$(VERSION)_amd64.deb: tmp/waterfox-$(VERSION)/debian/changelog | tmp/waterfox-$(VERSION)/waterfox tmp/waterfox-$(VERSION)/features
	@cd tmp/waterfox-$(VERSION) && \
	 debuild -us -uc -d

debs:
	@mkdir -p debs

debs/waterfox_$(VERSION)_amd64.deb: tmp/waterfox_$(VERSION)_amd64.deb | debs
	@cp tmp/waterfox_$(VERSION)_amd64.deb debs

install:
	@echo 'installing "waterfox_$(VERSION)_amd64.deb"'
	@sudo dpkg -i debs/waterfox_$(VERSION)_amd64.deb

clean:
	rm -rf ./tmp/version
	rm -rf ./tmp/waterfox-$(VERSION)/waterfox
	rm -rf ./tmp/waterfox-$(VERSION)/debian
	rm -rf ./tmp/waterfox-$(VERSION)/features
	rm -f ./tmp/*.deb
	rm -f ./tmp/waterfox_$(VERSION)_amd64.*
	rm -f ./tmp/waterfox_$(VERSION).*
