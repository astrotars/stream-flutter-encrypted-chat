import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'services/virgil_service.dart';

class EncryptedMessage extends StatefulWidget {
  EncryptedMessage({Key key, @required this.message}) : super(key: key);

  final Message message;

  @override
  _EncryptedMessageState createState() => _EncryptedMessageState();
}

class _EncryptedMessageState extends State<EncryptedMessage> {
  bool isMine;
  String _text;

  @override
  void initState() {
    isMine = StreamChat.of(context).user.id == widget.message.user.id;

    decryptText().then((text) {
      setState(() {
        _text = text;
      });
    });
    super.initState();
  }

  Future<String> decryptText() async {
    if (isMine) {
      return virgil.decryptMine(widget.message.text);
    } else {
      return virgil.decryptTheirs(widget.message.user.id, widget.message.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_text != null) {
      final textAlign = isMine ? TextAlign.right : TextAlign.left;
      final color = isMine ? Colors.blueGrey : Colors.blue;

      return Padding(
        padding: EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1),
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: ListTile(
            title: Text(
              _text,
              textAlign: textAlign,
            ),
            subtitle: Text(
              widget.message.user.id,
              textAlign: textAlign,
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
