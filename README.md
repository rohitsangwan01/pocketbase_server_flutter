# Pocketbase Server Flutter

[![pocketbase_server version](https://img.shields.io/pub/v/pocketbase_server_flutter?label=pocketbase_server_flutter)](https://pub.dev/packages/pocketbase_server_flutter)

Run [Pocketbase](https://pocketbase.io/) Server directly from Android/IOS with flutter

![Screenshot 2023-09-16 at 12 09 12 PM](https://github.com/rohitsangwan01/pocketbase_server_flutter/assets/59526499/4fa49d31-b9f6-4161-8f6b-050c2dea6d2a)

## Usage

Checkout [Pocketbase Server](https://github.com/rohitsangwan01/pocketbase_server_flutter_app) example app

Start pocketbaseServer

```dart
PocketbaseServerFlutter.start(
  hostName: "127.0.0.1",
  port: "8080",
  dataPath: "CachePath",
  enablePocketbaseApiLogs: true,
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

// To check Pocketbase version
PocketbaseServerFlutter.pocketbaseVersion
```

## Setup

- IOS

If getting error related to `Undefined symbol`, Make sure to run `pod install` on ios directory, open IOS project in XCode

Click on `Pods`, Then select `pocketbase_server_flutter` from Targets list, and select `Build Phases`

![Screenshot 2023-09-16 at 11 19 30 AM](https://github.com/rohitsangwan01/pocketbase_server_flutter/assets/59526499/95a13223-252c-4a1d-a0de-4c85fbe32b81)

Then in `Link Binary With Libraries` section, click on `+` button and search for `libresolv.tbd` and choose from result and click on Add

![image](https://github.com/rohitsangwan01/pocketbase_server_flutter/assets/59526499/412fda4d-48b4-44df-88dc-6134c1339518)

- Android

Should work out of the box

## Resources

https://pocketbase.io/

Built with: [pocketbase_mobile](https://github.com/rohitsangwan01/pocketbase_mobile), [pocketbase_android](https://github.com/rohitsangwan01/pocketbase_android), [pocketbase_ios](https://github.com/rohitsangwan01/pocketbase_ios)

## To Build

Compile for all platforms, and generate ffi bindings

```sh
cd src
make all
cd ..
dart pub run ffigen --config ffigen.yaml
```

## Note

This is for running Pocketbase server from mobile, to connect with pocketbase server, use official [Pocketbase](https://pub.dev/packages/pocketbase) client plugin
