import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:signalr_client/signalr_client.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:signalr_client/hub_connection_builder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //10.0.2.2
  final serverUrl = "http://10.0.2.2:5000/streamHub";
  late HubConnection hubConnection;
  double width = 100.0, height = 100.0;
  late Offset position;
  @override
  void initState() {
    super.initState();
    initSignalR();
    position = Offset(0.0, -20.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Draggable(
              feedback: Container(
                width: width,
                height: height,
                color: Colors.red[900],
                child: Center(
                  child: Text(
                    'Move me!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              child: Container(
                width: width,
                height: height,
                color: Colors.blue,
                child: Center(
                  child: Text(
                    'Move me!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              onDraggableCanceled: (velocity, offset) async {
                if (hubConnection.state == HubConnectionState.Connected) {
                  await hubConnection.invoke("MoveViewFromServer",
                      args: <Object>[offset.dx, offset.dy]);
                  setState(() {
                    position = offset;
                  });
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            hubConnection.state == HubConnectionState.Disconnected
                ? await hubConnection.start()
                : await hubConnection.stop();
            setState(() {
              print(hubConnection.state == HubConnectionState.Disconnected
                  ? "stop"
                  : "start");
            });
          },
          tooltip: 'Start/Stop',
          child: hubConnection.state == HubConnectionState.Disconnected
              ? Icon(Icons.play_arrow)
              : Icon(Icons.stop)),
    );
  }

  void initSignalR() {
    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
    // print(hubConnection.state);
    hubConnection.onclose((error) {
      print('Connection closed.');
    });
    //hubConnection.onclose(({Exception? error}) => print('Connection Closed'));
    hubConnection.on("ReceiveNewPosition", _handleNewPosition);
  }

  _handleNewPosition(List<Object> args) {
    // print(args);
    setState(() {
      position = Offset(
          double.parse(args[0].toString()), double.parse(args[1].toString()));
    });
  }
}
