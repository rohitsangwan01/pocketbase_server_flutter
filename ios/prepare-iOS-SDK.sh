# chmod +x prepare-iOS-SDK.sh

#!/bin/sh
REPO_NAME="pocketbase_ios"
FRAMEWORK_NAME="PocketbaseMobile.xcframework"

#!/bin/sh
rm -fR ${REPO_NAME}
mkdir ${REPO_NAME}
git clone https://github.com/rohitsangwan01/${REPO_NAME}

# unzip PocketbaseMobile.xcframework.zip and extract the xcframework folder
unzip ${REPO_NAME}/${FRAMEWORK_NAME}.zip -d ${REPO_NAME}  

 # Keep only the xcframework folder
find ./${REPO_NAME} -mindepth 1 -maxdepth 1 -not -name ${FRAMEWORK_NAME} -exec rm -rf '{}' \;  