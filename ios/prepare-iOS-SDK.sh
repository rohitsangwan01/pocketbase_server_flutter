# chmod +x prepare-iOS-SDK.sh

#!/bin/sh
FRAMEWORK_NAME="PocketbaseMobile.xcframework"
Version="1.0.0"

#!/bin/sh
rm -fR ${FRAMEWORK_NAME}
rm -f ${FRAMEWORK_NAME}.zip

# Download the zip file
curl -L -o ${FRAMEWORK_NAME}.zip "https://github.com/rohitsangwan01/pocketbase_mobile/releases/download/${Version}/${FRAMEWORK_NAME}.zip"

# unzip PocketbaseMobile.xcframework.zip and extract the xcframework folder
unzip ${FRAMEWORK_NAME}.zip   

# Remove the zip file
rm -f ${FRAMEWORK_NAME}.zip