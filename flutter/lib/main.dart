import 'package:encryptedchat/services/virgil_service.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'account.dart';
import 'services/backend_service.dart';
import 'users.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamEncryptedChatDemo(),
    );
  }
}

class StreamEncryptedChatDemo extends StatefulWidget {
  @override
  _StreamEncryptedChatDemoState createState() => _StreamEncryptedChatDemoState();
}

class _StreamEncryptedChatDemoState extends State<StreamEncryptedChatDemo> {
  final _userController = TextEditingController();
  Account _account;

  Future _login(BuildContext context) async {
    if (_userController.text.length > 0) {
      var user = _userController.text;

      var credentials = await backend.login(user);

      final client = Client(credentials['streamApiKey'], logLevel: Level.INFO);
      await client.setUser(User(id: user), credentials['streamToken']);

      await virgil.init(user, credentials['virgilToken']);

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
