import 'dart:convert'; // json encode/decode
import 'package:http/http.dart' as http;

class RequestController { 

  String path;
  String server;
  http.Response? _res;// nullable response object (intially null until request is sent via post/get)

  final Map<dynamic, dynamic> _body = {};
  final Map<String,String> _headers= {};
  dynamic _resultData;

  RequestController({required this.path, 
  // default value to point to own server address unless other 3rd party address specified
  this.server = "http://192.168.8.102"
 // this.server = "http://10.0.2.2" 
 // 10.0.2.2 is default ip address for EMULATED to device to point to the local device which runs the emulator
 // if your local device is connected to same network as server device use the server ip address
 // Emulated device by default share same network with the device it runs on
 // thus actual server ip address can also be used in emulated envorenment
  });

  setBody(Map<String, dynamic> data) {
    _body.clear();
    _body.addAll(data);
    _headers["Content-Type"] = "application/json; charset=UTF-8";
  }

  post() async {
    _res = await http.post(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }
  get() async {
    _res = await http.get(
      Uri.parse(server + path),
      headers: _headers,
    );
    _parseResult();
  }

  void _parseResult(){
    // parse result into json structure if possible
    try{
      print("raw response:${_res?.body}" );
      _resultData = jsonDecode(_res?.body?? ""); 
    }catch(ex){
      // otherwise the response body will be stored as is
      _resultData = _res?.body;
      print("exception in http result parsing ${ex}");
    }
  }

  dynamic result() {
    return _resultData;
  }
 

  int status() {
    return _res?.statusCode ?? 0; //return the http response code, if no request sent or response yet, 0 will be returned
  }
}
