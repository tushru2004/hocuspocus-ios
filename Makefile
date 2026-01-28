.PHONY: help install-wda test-vpn test-smoke

# iPhone device ID (get with: xcrun xctrace list devices)
IPHONE_DEVICE_ID ?= 00008020-0004695621DA002E
WDA_PROJECT_PATH = ~/.appium/node_modules/appium-xcuitest-driver/node_modules/appium-webdriveragent

help:
	@echo "iOS E2E Test Commands (run on MacBook Air)"
	@echo ""
	@echo "  make install-wda    - Install WebDriverAgent on iPhone (required once after cert expires)"
	@echo "  make test-vpn       - Run VPN filtering tests"
	@echo "  make test-smoke     - Run smoke tests"
	@echo ""
	@echo "After install-wda, trust the certificate on iPhone:"
	@echo "  Settings → General → VPN & Device Management → Trust"

install-wda:
	@echo "Installing WebDriverAgent on iPhone..."
	@echo "Make sure iPhone is unlocked and connected via USB"
	cd $(WDA_PROJECT_PATH) && xcodebuild test-without-building \
		-project WebDriverAgent.xcodeproj \
		-scheme WebDriverAgentRunner \
		-destination 'id=$(IPHONE_DEVICE_ID)' \
		PRODUCT_BUNDLE_IDENTIFIER="com.tushru2004.WebDriverAgentRunner" \
		DEVELOPMENT_TEAM="2TF5QH3WTY" \
		CODE_SIGN_IDENTITY="Apple Development: tushru2004@icloud.com (2TF5QH3WTY)" \
		ALLOW_PROVISIONING_UPDATES=YES \
		2>&1 | tail -20 || echo "If you see 'Certificate not trusted', go to Settings → General → VPN & Device Management and trust it"

test-vpn:
	cd tests && python3 -m pytest e2e_prod/test_verify_vpn.py -v --timeout=180

test-smoke:
	cd tests && python3 -m pytest e2e_prod/ -v -k "smoke" --timeout=60
