import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Pocketbase Server"),
        ),
        body: Column(
          children: [
            const Text("Start pocketbase server from mobile"),
            const Divider(),
            ElevatedButton(
                onPressed: () async {
                  await PocketbaseServerFlutter.start(
                    hostName: await PocketbaseServerFlutter.localIpAddress,
                    port: "5000",
                    enablePocketbaseApiLogs: true,
                  );
                },
                child: const Text("Start")),
            ElevatedButton(
                onPressed: () {
                  PocketbaseServerFlutter.stop();
                },
                child: const Text("Start")),
          ],
        ));
  }
}
