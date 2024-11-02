// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
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
                    final info = NetworkInfo();
                    String? localIp = await info.getWifiIP();
                    String path = (await getApplicationCacheDirectory()).path;
                    print("Starting Pocketbase");
                    await PocketbaseServerFlutter.start(
                      dataPath: path,
                      hostName: localIp ?? "127.0.0.1",
                      port: "5000",
                      enablePocketbaseApiLogs: true,
                    );
                    print("Pocketbase Stopped");
                  },
                  child: const Text("Start"),
                ),
                ElevatedButton(
                  onPressed: () {
                    PocketbaseServerFlutter.stop();
                  },
                  child: const Text("Stop"),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    print(await PocketbaseServerFlutter.pocketbaseVersion);
                  },
                  child: const Text("Version"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    print(await PocketbaseServerFlutter.isRunning);
                  },
                  child: const Text("IsRunning"),
                ),
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
