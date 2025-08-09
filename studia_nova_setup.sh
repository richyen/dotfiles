#!/bin/bash
# ============================================================
# Studia Nova macOS Workstation Setup Script
# ------------------------------------------------------------
# Run in Terminal as:
#   sudo bash studia_nova_setup.sh
# ============================================================

ADMIN_FULLNAME="snadmin"
ADMIN_USERNAME="snadmin"
ADMIN_PASSWORD="studian0va"

STUDENT_FULLNAME="snstudent"
STUDENT_USERNAME="snstudent"
STUDENT_PASSWORD="snstudent"

WIFI_SSID="Studia Nova"
WIFI_PASSWORD="learn4Jesus"

COMPUTER_NAME="Riley’s Mac mini" # Change per student

echo "=== Creating administrator account: $ADMIN_USERNAME..."
sudo sysadminctl -addUser "$ADMIN_USERNAME" \
  -fullName "$ADMIN_FULLNAME" \
  -password "$ADMIN_PASSWORD" \
  -admin

echo "=== Renaming computer to: $COMPUTER_NAME..."
sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set LocalHostName "${COMPUTER_NAME// /}"
sudo scutil --set HostName "${COMPUTER_NAME// /}"

echo "=== Creating student account: $STUDENT_USERNAME..."
sudo sysadminctl -addUser "$STUDENT_USERNAME" \
  -fullName "$STUDENT_FULLNAME" \
  -password "$STUDENT_PASSWORD"

echo "=== Connecting to Wi-Fi: $WIFI_SSID..."
WIFI_DEVICE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2}')
sudo networksetup -setairportnetwork "$WIFI_DEVICE" "$WIFI_SSID" "$WIFI_PASSWORD"

echo "=== Installing Google Chrome..."
curl -L -o /tmp/chrome.dmg "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
hdiutil attach /tmp/chrome.dmg -nobrowse -quiet
sudo cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications/
hdiutil detach "/Volumes/Google Chrome" -quiet
rm /tmp/chrome.dmg

echo "=== Requesting Chrome as default browser..."
open -a "Google Chrome" --args --make-default-browser

echo "=== Cleaning up Dock..."
if ! command -v dockutil &>/dev/null; then
  echo "Installing dockutil..."
  if command -v brew &>/dev/null; then
    brew install dockutil
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install dockutil
  fi
fi
dockutil --remove all --no-restart
dockutil --add "/System/Applications/Finder.app" --no-restart
dockutil --add "/Applications/Google Chrome.app" --no-restart
killall Dock

# ============================================================
# Print MANUAL STEPS
# ============================================================
cat << "EOF"

==========================
 MANUAL SETUP CHECKLIST
==========================

1. Install Accountability Software
   - Download Covenant Eyes, Accountable2You, etc.
   - Install for the STUDENT account.
   - Sign in as the child for monitoring.

2. Chrome Privacy & Settings (in STUDENT account)
   - On first launch, click "Don’t Sign In".
   - Turn off: Ad topics, Site-suggested ads, Ad measurement.
   - Turn off: Chrome sign-in, password saving, payment methods, addresses.

3. Screen Time Setup
   - Passcode: 4316
   - Downtime: 5:00 PM – 8:00 AM daily
   - App Limits: Only allow Chrome, Preview, QuickTime
   - Communication Safety: ON
   - Content & Privacy: Limit adult websites, restrict apps/media

4. Store Restrictions
   - Movies: Don’t Allow
   - TV Shows: Don’t Allow
   - Apps: Don’t Allow

5. App & Feature Restrictions
   - Turn off allow for everything except required items.

==========================
END OF MANUAL CHECKLIST
==========================

EOF

echo "=== Setup complete! Please finish the above manual steps."
