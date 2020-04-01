import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'account.dart';

class Chat extends StatefulWidget {
  Chat({Key key, @required this.account, @required this.user})
      : super(key: key);

  final Account account;
  final String user;

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _messageController = TextEditingController();
  Channel _channel;

  @override
  void initState() {
    super.initState();

    var users = [widget.account.user, widget.user];
    users.sort();
    var channelId = users.join("-");
    _channel = widget.account.streamClient.channel(
      'messaging',
      id: channelId,
      extraData: {'members': users},
    );

    _channel.watch();
  }

  void _sendMessage() {
    if (_messageController.text.length > 0) {
      _channel.sendMessage(Message(text: _messageController.text));
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

  Widget _messageBuilder(context, message, index) {
    final isCurrentUser = StreamChat
        .of(context)
        .user
        .id == message.user.id;
    final textAlign = isCurrentUser ? TextAlign.right : TextAlign.left;
    final color = isCurrentUser ? Colors.blueGrey : Colors.blue;

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
            message.text,
            textAlign: textAlign,
          ),
          subtitle: Text(
            message.user.id,
            textAlign: textAlign,
          ),
        ),
      ),
    );
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
