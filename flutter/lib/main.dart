import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'account.dart';
import 'api_service.dart';
import 'users.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  final _userController = TextEditingController();
  Account _account;

  Future _login(BuildContext context) async {
    if (_userController.text.length > 0) {
      var user = _userController.text;
      var credentials = await ApiService().login(user);

      final client = Client(credentials['streamApiKey'], logLevel: Level.INFO);
      await client.setUser(User(id: user), credentials['streamToken']);

      setState(() {
        _account = Account(
          user: user,
          authToken: credentials['authToken'],
          streamClient: client,
        );
      });
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid User'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var body;
    if (_account != null) {
      body = Users(account: _account);
    } else {
      body = Container(
        padding: EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: _userController,
              ),
              RaisedButton(
                onPressed: () => _login(context),
                child: Text("Login"),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Stream Encrypted Chat"),
      ),
      body: body,
    );
  }
}
