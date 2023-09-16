# Pocketbase Server Flutter

Start [Pocketbase](https://pocketbase.io/) Server directly from Android/IOS with flutter 


## Setup

### Android

Should work out of the box 

### IOS

If getting error related to `Undefined symbol`, Make sure to run `pod install` on ios directory, open IOS project in XCode

Click on `Pods`, Then select `pocketbase_server_flutter` from Targets list, and select `Build Phases`


Then in `Link Binary With Libraries` section, click on `+` button and search for `libresolv.tbd` and choose from result and click on Add



## Usage

Start pocketbaseServer 

```dart
PocketbaseMobileFlutter.start(
  hostName: await PocketbaseMobileFlutter.localIpAddress,
  port: "8080",
  dataPath: null,
  enablePocketbaseApiLogs: true,
);
```

Stop pocketbaseServer

```dart
PocketbaseMobileFlutter.stop();
```

Listen to pocketbaseServer events, setup eventCallback

```dart
PocketbaseMobileFlutter.setEventCallback(
    callback: (event, data){
        // Handle event and data
    },
);
```

Some helper methods

```dart
// To check if pocketBase is running (not reliable)
PocketbaseMobileFlutter.isRunning

// To check pocketbaseMobile version
PocketbaseMobileFlutter.pocketbaseMobileVersion

// To get the ipAddress of mobile ( to run pocketbase with this hostname )
PocketbaseMobileFlutter.localIpAddress
```

## Resources

https://pocketbase.io/

Built with: 
https://github.com/rohitsangwan01/pocketbase_mobile
https://github.com/rohitsangwan01/pocketbase_android
https://github.com/rohitsangwan01/pocketbase_ios