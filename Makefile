SCHEME=Signal

.PHONY: dependencies
dependencies: pod-setup fetch-ringrtc
	# This is just the commit of origin/main when I made this change. 
	# If necessary in the future, one can tie this to some dependency version indicator and check it is up to date in XCode.
	echo "72431ae93040fdf28ec231fb9b70e6e903d2dfee" > $(CURDIR)/.dependencies_last_updated

.PHONY: pod-setup
pod-setup:
	git submodule foreach --recursive "git clean -xfd"
	git submodule foreach --recursive "git reset --hard"
	./Scripts/setup_private_pods
	git submodule update --init --progress

.PHONY: fetch-ringrtc
fetch-ringrtc:
	$(CURDIR)/Pods/SignalRingRTC/bin/set-up-for-cocoapods

.PHONY: test
test: dependencies
	bundle exec fastlane scan --scheme ${SCHEME}

.PHONY: release
release:
	@echo This command has been deprecated by Xcode Cloud.
