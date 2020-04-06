import 'dart:convert';

import 'package:http/http.dart' as http;

final BackendService backend = BackendService._singleton();

class BackendService {
  BackendService._singleton();

  String authToken;
  String streamToken;
  String streamApiKey;
  String virgilToken;

  // android only, for both platforms use something like: https://ngrok.com/
  static const _baseUrl = 'http://10.0.2.2:8080';

  Future<Map<String, String>> login(String user) async {
    var authResponse = await http.post('$_baseUrl/v1/authenticate', body: {'user': user});
    authToken = json.decode(authResponse.body)['authToken'];

    var streamResponse =
        await http.post('$_baseUrl/v1/stream-credentials', headers: {'Authorization': 'Bearer $authToken'});
    var streamBody = json.decode(streamResponse.body);
    streamToken = streamBody['token'];
    streamApiKey = streamBody['apiKey'];

    var virgilResponse =
        await http.post('$_baseUrl/v1/virgil-credentials', headers: {'Authorization': 'Bearer $authToken'});
    virgilToken = json.decode(virgilResponse.body)['token'];

    return {
      'authToken': authToken,
      'streamToken': streamToken,
      'streamApiKey': streamApiKey,
      'virgilToken': virgilToken,
    };
  }

  Future<List> users() async {
    var response = await http.get('$_baseUrl/v1/users', headers: {'Authorization': 'Bearer $authToken'});
    return json.decode(response.body);
  }
}
