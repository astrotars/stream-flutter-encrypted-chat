import 'package:flutter/foundation.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class Account {
  Account({
    @required this.user,
    @required this.authToken,
    @required this.streamClient,
  });

  String user;
  String authToken;
  Client streamClient;
}
