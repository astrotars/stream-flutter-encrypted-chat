import 'package:encryptedchat/account.dart';
import 'package:flutter/material.dart';

import 'api_service.dart';
import 'chat.dart';

class Users extends StatefulWidget {
  Users({Key key, @required this.account}) : super(key: key);

  final Account account;

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  Future<List> _users;

  @override
  void initState() {
    super.initState();
    _users = ApiService().users(widget.account);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: _users,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data
              .where((u) => u != widget.account.user)
              .map(
                (user) => ListTile(
                  title: Text(user),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Chat(
                          account: widget.account,
                          user: user,
                        ),
                      ),
                    );
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }
}
