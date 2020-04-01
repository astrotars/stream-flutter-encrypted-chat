import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'account.dart';

class VirgilService {
  static const virgilChannel = const MethodChannel('io.getstream/virgil');

  Future initVirgil(String user, String virgilToken) async {
    return await virgilChannel.invokeMethod<bool>('initVirgil', {'user': user, 'token': virgilToken});
  }
}
