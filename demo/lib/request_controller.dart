import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestController { 

  String path;
  String server;
  http.Response? _res;

  RequestController({required this.path, this.server = "http://10.0.2.2"});

  final Map<dynamic, dynamic> _body = {};

  setBody(Map<String, dynamic> data) {
    _body.clear();
    _body.addAll(data);
  }

  post() async {
    _res = await http.post(
      Uri.parse(server + path),
      body: jsonEncode(_body),
    );
  }
  get() async {
    _res = await http.get(
      Uri.parse(server + path),
    );
  }

  dynamic result() {
    return _res?.body;
  }

  Map<String, dynamic> JSONResult() {
    try {
      return jsonDecode(_res?.body ?? "");
    } catch (ex) {
      return {};
    }
  }

  int status() {
    return _res?.statusCode ?? 0;
  }
}
