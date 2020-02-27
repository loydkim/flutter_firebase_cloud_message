import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(title: 'Firebase Cloud Message'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TextEditingController _textController = TextEditingController();

  String iOSDevice = 'Your iOS Token(Physical device)';
  String androidSimul = 'Your Android Token';

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings());
    }
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Get Token',
                  style: TextStyle(fontSize: 20)),
              onPressed: () {
                _firebaseMessaging.getToken().then((val) {
                  print('Token: '+val);
                });
              },
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 260,
              child: TextFormField(
                validator: (input) {
                  if(input.isEmpty) {
                    return 'Please type an message';
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Message'
                ),
                controller: _textController,
              ),
            ),
            SizedBox(height: 20),
            RaisedButton(
              child: Text('Send a message to Android',
              style: TextStyle(fontSize: 20)),
              onPressed: () {
                sendAndRetrieveMessage(androidSimul);
              },
            ),
            SizedBox(height: 20),
            RaisedButton(
              child: Text('Send a message to iOS',
                  style: TextStyle(fontSize: 20)),
              onPressed: () {
                sendAndRetrieveMessage(iOSDevice);
              },
            )
          ],
        ),
      ),
    );
  }

  final String serverToken = 'Your firebase console server string.';

  Future<Map<String, dynamic>> sendAndRetrieveMessage(String token) async {
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': _textController.text,
            'title': 'FlutterCloudMessage'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': token,
        },
      ),
    );

    _textController.text = '';
    final Completer<Map<String, dynamic>> completer =
    Completer<Map<String, dynamic>>();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );

    return completer.future;
  }
}
