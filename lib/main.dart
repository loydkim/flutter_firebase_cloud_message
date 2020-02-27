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

  String iOSDevice = 'fTWxoNCsmUnBq8u0Hg8N23:APA91bFVTksDSrIpKls-cpjOX9DgIA0o8PPOW3Q9hK85lW3dbwuwou1Oe2arF5AR9troLP9Rc58hmQmpIsnAdFIiKXVlrPR0Srk0aTMyN3oxMAMfMZRGlx0MK8v6ObkaqCMBo3fnHReh';
  String androidSimul = 'cyZ82l8LemE:APA91bF613ps1ImMPpVCP3_1nhpciCFWUPRj2IVqokD1U-sNnrvqrmnStSAh4wh-8ciRyhYwz1ft6TqIPlrHufLL076lhgNs9fXSUtVwAz5NyLgcjFLCOtWIFy8lxO0g04-6lz1hqvpD';

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

  final String serverToken = 'AAAA0Qrw2uU:APA91bGBg4Y9rQ4Pyjsxn2xX8H0iYOMwni8UdcCPNjnlwkL4i7q3L8ZBKtDX6P7vqx3kFz6zurY0GQegY2MJ0n1abWitegqU9-3D9csh6eCPwp2iuoFrfWSSKK-AjqZiwiPVjs4k5eem';

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
