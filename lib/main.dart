import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_project/MQTTClientManager.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Connect MQTTX'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _lightstatus = false;
  bool _doorstatus = false;

  MQTTClientManager mqttClientManager = MQTTClientManager();
  final String pubTopic = "Test Flutter Port 1883 Localhost Open Door";

  final String pubTopic2 = "Test Flutter Port 1883 Localhost turn on the light";

  @override
  void initState() {
    setupMqttClient();
    setupUpdatesListener();
    super.initState();
  }

  // void _incrementCounter() {
  //   setState(() {
  //     _lightstatus != _lightstatus;
  //     mqttClientManager.publishMessage(
  //         pubTopic2,  "Light Status is ${_lightstatus}");
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var a = 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Flexible(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SwitchListTile(
                      title: Text("Open The Door"),
                      subtitle:
                          a != 2 ? Text("Please Open The Door") : Text("test"),
                      value: _doorstatus,
                      onChanged: (bool value) {
                        setState(() {
                          _doorstatus = value;
                          mqttClientManager.publishMessage(
                              pubTopic, "You Door Status is ${_doorstatus}");
                        });
                      }),
                  SwitchListTile(
                      title: Text("Open The Light"),
                      subtitle: Text("Please Open The Light "),
                      value: _lightstatus,
                      onChanged: (bool value) {
                        setState(() {
                          _lightstatus = value;
                          mqttClientManager.publishMessage(
                              pubTopic2, "You Light Status is ${_lightstatus}");
                        });
                        // if(_lightstatus){
                        // }
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect();
    mqttClientManager.subscribe(pubTopic);
    mqttClientManager.subscribe(pubTopic2);
  }

  void setupUpdatesListener() {
    mqttClientManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
      //  final pt2 =
      //     MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      // print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt2\n');
    });
  }

  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
  }

  void showToast(String msg, {int? duration, int? gravity}) {
    Toast.show(msg, duration: duration, gravity: gravity);
  }
}
