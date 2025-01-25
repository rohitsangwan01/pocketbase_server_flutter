// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase_server_flutter/pocketbase_server_flutter.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> logs = [];

  @override
  void initState() {
    PocketbaseServerFlutter.setEventCallback(callback: (event, data) {
      print("Event: $event");
      setState(() {
        logs.add("$event - $data");
      });
    });
    super.initState();
  }

  void startServer() async {
    final Directory staticDir = await getTemporaryDirectory();
    final String staticFolder = "${staticDir.path}/pb_static/";
    final String hooksFolder = "${staticDir.path}/pb_hooks/";
    final String dataFolder = "${staticDir.path}/pb_data/";

    await PocketbaseServerFlutter.copyAssetsFolderToPath(
      path: staticFolder,
      assetFolder: "pb_static",
      overwriteExisting: true,
    );

    await PocketbaseServerFlutter.copyAssetsFolderToPath(
      path: hooksFolder,
      assetFolder: "pb_hooks",
      overwriteExisting: true,
    );

    print("StaticDir: $staticFolder");
    print("HooksDir: $hooksFolder");
    print("DataDir: $dataFolder");

    // Serve this directory
    await PocketbaseServerFlutter.start(
      superUserEmail: "test@user.com",
      superUserPassword: "password",
      hostName: await PocketbaseServerFlutter.localIpAddress,
      port: "5000",
      enablePocketbaseApiLogs: true,
      dataPath: dataFolder,
      staticFilesPath: staticFolder,
      hookFilesPath: hooksFolder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Pocketbase Server"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Start pocketbase server from mobile",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      startServer();
                    },
                    child: const Text("Start")),
                ElevatedButton(
                    onPressed: () {
                      PocketbaseServerFlutter.stop();
                    },
                    child: const Text("Stop")),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Text(logs[index]);
                },
              ),
            )
          ],
        ));
  }
}
