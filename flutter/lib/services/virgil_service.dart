import 'package:flutter/services.dart';

final VirgilService virgil = VirgilService._singleton();

class VirgilService {
  VirgilService._singleton();

  static const virgilChannel = const MethodChannel('io.getstream/virgil');

  Future init(String user, String virgilToken) async {
    return await virgilChannel.invokeMethod<bool>('initVirgil', {'user': user, 'token': virgilToken});
  }

  Future<String> encrypt(String user, String text) async {
    return await virgilChannel.invokeMethod<String>('encrypt', {'otherUser': user, 'text': text});
  }

  Future<String> decryptMine(String text) async {
    return await virgilChannel.invokeMethod<String>('decryptMine', {'text': text});
  }

  Future<String> decryptTheirs(String otherUser, String text) async {
    return await virgilChannel.invokeMethod<String>('decryptTheirs', {'text': text, 'otherUser': otherUser});
  }
}
