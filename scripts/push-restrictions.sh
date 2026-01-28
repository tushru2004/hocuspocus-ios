#!/bin/bash
# Push Restrictions profile to iPhone via SimpleMDM
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# SimpleMDM API key
API_KEY="${SIMPLEMDM_API_KEY:-2IkV3x1TEpS9r6AGtmeyvLlBMvwHzCeJgQY4O8VyTtoss2KR6qVpEZcQqPlmLrLV}"
DEVICE_ID="2154382" # iPhone

PROFILE_PATH="/Users/tushar/code/hocuspocus-ios/profiles/hocuspocus-restrictions.mobileconfig"
PROFILE_NAME="Hocuspocus Restrictions"

echo "Using profile: ${PROFILE_PATH}"
echo "Target device: iPhone (ID: ${DEVICE_ID})"

# Check for existing profile with same name
echo "Checking for existing profile..."
EXISTING_PROFILE=$(curl -s -u "${API_KEY}:" \
  "https://a.simplemdm.com/api/v1/custom_configuration_profiles" | \
  python3 -c "import sys, json; data=json.load(sys.stdin)['data']; profiles=[p for p in data if p['attributes']['name']=='${PROFILE_NAME}']; print(profiles[0]['id'] if profiles else '')" 2>/dev/null)

if [ -n "$EXISTING_PROFILE" ]; then
    echo "Deleting existing profile (ID: $EXISTING_PROFILE)..."
    curl -s -X DELETE -u "${API_KEY}:" \
      "https://a.simplemdm.com/api/v1/custom_configuration_profiles/${EXISTING_PROFILE}" > /dev/null
    sleep 2
fi

# Upload new profile
echo "Uploading restrictions profile to SimpleMDM..."
PROFILE_ID=$(curl -s -X POST \
  -u "${API_KEY}:" \
  -F "name=${PROFILE_NAME}" \
  -F "mobileconfig=@${PROFILE_PATH}" \
  "https://a.simplemdm.com/api/v1/custom_configuration_profiles" | \
  python3 -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")

echo "Profile uploaded (ID: $PROFILE_ID)"

# Get device name from SimpleMDM for display
SIMPLEMDM_DEVICE_NAME=$(curl -s -u "${API_KEY}:" \
  "https://a.simplemdm.com/api/v1/devices/${DEVICE_ID}" | \
  python3 -c "import sys, json; print(json.load(sys.stdin)['data']['attributes']['device_name'])" 2>/dev/null)

# Push to device
echo "Pushing profile to: $SIMPLEMDM_DEVICE_NAME (ID: $DEVICE_ID)..."
curl -s -X POST -u "${API_KEY}:" \
  "https://a.simplemdm.com/api/v1/custom_configuration_profiles/${PROFILE_ID}/devices/${DEVICE_ID}" > /dev/null

echo ""
echo "==========================================="
echo "Restrictions profile pushed to $SIMPLEMDM_DEVICE_NAME!"
echo "==========================================="
echo "The 'Erase All Content and Settings' option should now be disabled."
