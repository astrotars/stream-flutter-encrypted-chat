import 'dart:convert';

import 'package:http/http.dart' as http;

import 'account.dart';

class ApiService {
  // android only, for both platforms use something like: https://ngrok.com/
  static const _baseUrl = 'http://10.0.2.2:8080';

  Future<Map> login(String user) async {
    var authResponse =
        await http.post('$_baseUrl/v1/authenticate', body: {'user': user});
    var authToken = json.decode(authResponse.body)['authToken'];
    var streamResponse = await http.post('$_baseUrl/v1/stream-credentials',
        headers: {'Authorization': 'Bearer $authToken'});
    var streamBody = json.decode(streamResponse.body);
    var streamToken = streamBody['token'];
    var streamApiKey = streamBody['apiKey'];

    return {
      'authToken': authToken,
      'streamToken': streamToken,
      'streamApiKey': streamApiKey,
    };
  }

  Future<List> users(Account account) async {
    var response = await http.get('$_baseUrl/v1/users',
        headers: {'Authorization': 'Bearer ${account.authToken}'});
    return json.decode(response.body);
  }
}
