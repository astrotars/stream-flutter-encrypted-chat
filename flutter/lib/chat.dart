import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'account.dart';
import 'encrypted_message.dart';
import 'services/virgil_service.dart';

class Chat extends StatefulWidget {
  Chat({Key key, @required this.account, @required this.otherUser})
      : super(key: key);

  final Account account;
  final String otherUser;

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _messageController = TextEditingController();
  Channel _channel;

  @override
  void initState() {
    super.initState();

    var users = [widget.account.user, widget.otherUser];
    users.sort();
    var channelId = users.join("-");
    _channel = widget.account.streamClient.channel(
      'messaging',
      id: channelId,
      extraData: {'members': users},
    );

    _channel.watch();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.length > 0) {
      var encryptedText = await virgil.encrypt(widget.otherUser, _messageController.text);
      _channel.sendMessage(Message(text: encryptedText));
      _messageController.clear();
    }
  }

  Widget buildInput(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery
          .of(context)
          .padding
          .bottom),
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                style: TextStyle(fontSize: 15.0),
                controller: _messageController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),

          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.blueGrey, width: 0.5)),
        color: Colors.white,
      ),
    );
  }

  Widget _messageBuilder(context, message, _) {
    return EncryptedMessage(message: message);
  }

  @override
  Widget build(BuildContext context) {
    return StreamChat(
      client: widget.account.streamClient,
      child: StreamChannel(
        channel: _channel,
        child: Scaffold(
          appBar: ChannelHeader(
            onBackPressed: () {
              Navigator.of(context).pop();
            },
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: MessageListView(
                  messageBuilder: _messageBuilder,
                ),
              ),
              buildInput(context),
            ],
          ),
        ),
      ),
    );
  }
}
