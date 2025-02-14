# Pocketbase Server Flutter

[![pocketbase_server version](https://img.shields.io/pub/v/pocketbase_server_flutter?label=pocketbase_server_flutter)](https://pub.dev/packages/pocketbase_server_flutter)

Run [Pocketbase](https://pocketbase.io/) Server directly from Android/IOS with flutter

![Screenshot 2023-09-16 at 12 09 12 PM](https://github.com/rohitsangwan01/pocketbase_server_flutter/assets/59526499/4fa49d31-b9f6-4161-8f6b-050c2dea6d2a)

## Usage

Checkout [Pocketbase Server](https://github.com/rohitsangwan01/pocketbase_server_flutter_app) example app

### Start pocketbaseServer

```dart
PocketbaseServerFlutter.start(
  superUserEmail: "test@user.com",
  superUserPassword: "password",
  hostName: await PocketbaseServerFlutter.localIpAddress,
  port: "8080",
);
```

### Advanced Usage

```dart
// Get path to load resources using `path_provider`
final Directory staticDir = await getTemporaryDirectory();

// Directory to load static files (Optional)
final String staticFolder = "${staticDir.path}/pb_static/";

// Directory to load js hook files (Optional)
final String hooksFolder = "${staticDir.path}/pb_hooks/";

// Directory to save sqlite files and default data
final String dataFolder = "${staticDir.path}/pb_data/";

// add `pb_static` and `pb_hooks` folder in assets of your project, and load all files from assets to given path
await PocketbaseServerFlutter.copyAssetsFolderToPath(
  path: staticFolder,
  assetFolder: "pb_static",
  overwriteExisting: true,
)

await PocketbaseServerFlutter.copyAssetsFolderToPath(
  path: hooksFolder,
  assetFolder: "pb_hooks",
  overwriteExisting: true,
);

PocketbaseServerFlutter.start(
  superUserEmail: "test@user.com",
  superUserPassword: "password",
  hostName: await PocketbaseServerFlutter.localIpAddress,
  port: "8080",
  enablePocketbaseApiLogs: true,
  dataPath: dataFolder,
  staticFilesPath: staticFolder,
  hookFilesPath: hooksFolder,
);
```

Stop pocketbaseServer

```dart
PocketbaseServerFlutter.stop();
```

Listen to pocketbaseServer events, setup eventCallback

```dart
PocketbaseServerFlutter.setEventCallback(
    callback: (event, data){
        // Handle event and data
    },
);
```

Some helper methods

```dart
// To check if pocketBase is running (not reliable)
PocketbaseServerFlutter.isRunning

// To check pocketbaseMobile version
PocketbaseServerFlutter.pocketbaseMobileVersion

// To get the ipAddress of mobile ( to run pocketbase with this hostname )
PocketbaseServerFlutter.localIpAddress
```

## Mobile Setup

- IOS

If getting error related to `Undefined symbol`, Make sure to run `pod install` on ios directory, open IOS project in XCode

Click on `Pods`, Then select `pocketbase_server_flutter` from Targets list, and select `Build Phases`

![Screenshot 2023-09-16 at 11 19 30 AM](https://github.com/rohitsangwan01/pocketbase_server_flutter/assets/59526499/95a13223-252c-4a1d-a0de-4c85fbe32b81)

Then in `Link Binary With Libraries` section, click on `+` button and search for `libresolv.tbd` and choose from result and click on Add

![image](https://github.com/rohitsangwan01/pocketbase_server_flutter/assets/59526499/412fda4d-48b4-44df-88dc-6134c1339518)

- Android

Should work out of the box

## Desktop Setup

Desktop requires `pocketbaseExecutable` path in `start()`

To get `pocketbaseExecutable` in app, add the executable in Assets and on runtime copy it from assets to another path using path_provider
Or download the executable on Runtime

- MacOS

Edit your `Runner/**.entitlements` file

```plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>com.apple.security.app-sandbox</key>
		<false />
		<key>com.apple.security.cs.allow-jit</key>
		<true />
		<key>com.apple.security.network.client</key>
		<true />
		<key>com.apple.security.network.server</key>
		<true />
	</dict>
</plist>
```

- Windows, Linux

Should work out of the box

## Resources

https://pocketbase.io/

Built with: [pocketbase_mobile](https://github.com/rohitsangwan01/pocketbase_mobile)

## Note

This is for running Pocketbase server from mobile, to connect with pocketbase server, use official [pocketbase](https://pub.dev/packages/pocketbase) client plugin
