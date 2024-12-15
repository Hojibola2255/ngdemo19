import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/random_user_list_res.dart';
import 'http_helper.dart';

//https://randomuser.me/api?results=10&page=2

class Network {
  static bool isTester = true;
  static String SERVER_DEV = "randomuser.me";
  static String SERVER_PROD = "randomuser.me";

  static final client = InterceptedClient.build(
    interceptors: [HttpInterceptor()],
    retryPolicy: HttpRetryPolicy(),
  );

  static String getServer() {
    if (isTester) return SERVER_DEV;
    return SERVER_PROD;
  }

  /* Http Requests */
  static Future<String?> GET(String api, Map<String, String> params) async {
    try {
      var uri = Uri.https(getServer(), api, params);
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        _throwException(response);
      }
    } on SocketException catch (_) {
      // if the network connection fails
      rethrow;
    }
  }

  static Future<String?> POST(String api, Map<String, String> params) async {
    try {
      var uri = Uri.https(getServer(), api, params);
      var response = await client.post(uri, body: jsonEncode(params));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        _throwException(response);
      }
    } on SocketException catch (_) {
      // if the network connection fails
      rethrow;
    }
  }

  static Future<String?> PUT(String api, Map<String, String> params) async {
    try {
      var uri = Uri.https(getServer(), api, params);
      var response = await client.put(uri, body: jsonEncode(params));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body;
      } else {
        _throwException(response);
      }
    } on SocketException catch (_) {
      // if the network connection fails
      rethrow;
    }
  }

  static Future<String?> DEL(String api, Map<String, String> params) async {
    try {
      var uri = Uri.https(getServer(), api, params);
      var response = await client.delete(uri);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        _throwException(response);
      }
    } on SocketException catch (_) {
      // if the network connection fails
      rethrow;
    }
  }

  static _throwException(Response response) {
    String reason = response.reasonPhrase!;
    switch (response.statusCode) {
      case 400:
        throw BadRequestException(reason);
      case 401:
        throw InvalidInputException(reason);
      case 403:
        throw UnauthorisedException(reason);
      case 404:
        throw FetchDataException(reason);
      case 500:
      default:
        throw FetchDataException(reason);
    }
  }

  static Future<String?> MUL(
      String api, File file, Map<String, String> params) async {
    try {
      var uri = Uri.https(getServer(), api); // http or https
      var request = MultipartRequest('POST', uri);
      request.headers['x-api-key'] = HttpInterceptor.API_KEY;
      request.headers['Content-Type'] = 'multipart/form-data';

      request.files.add(
        http.MultipartFile(
          'file',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split("/").last,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      request.fields.addAll(params);

      StreamedResponse streamedResponse = await request.send();
      var response = await Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        return response.body;
      } else {
        _throwException(response);
      }
    } on SocketException catch (_) {
      // if the network connection fails
      rethrow;
    }
  }

  /* Http Apis*/
  static String API_RANDOM_USER_LIST = "/api";

  /* Http Params */
  static Map<String, String> paramsEmpty() {
    Map<String, String> params = {};
    return params;
  }

  //limit=20&page=0&order=DESC
  static Map<String, String> paramsRandomUserList(int page) {
    Map<String, String> params = {};
    params.addAll({'results': "20", 'page': page.toString()});
    return params;
  }

/* Http Parsing */

  static RandomUserListRes parseRandomUserList(String response) {
    dynamic json = jsonDecode(response);
    return RandomUserListRes.fromJson(json);
  }
}