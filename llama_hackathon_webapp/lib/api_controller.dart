import 'dart:convert';

// Packages
import 'package:http/http.dart' as http;

// URLs
// const String apiUrl = 'http://127.0.0.1:8000/api/';
// const String botUrl = 'http://0.0.0.0/';

// Headers
Map<String, String> headers = {'Content-Type': 'application/json'};

const String apiUrl = 'https://aldous-api-edd7aba482d5.herokuapp.com/api/';
const String botUrl = 'https://sea-turtle-app-3zj6d.ondigitalocean.app/';

class ApiService {
  static getBaseUrl(String service, String url) {
    switch (service) {
      case 'api':
        return Uri.parse(apiUrl + url);
      case 'bot':
        return Uri.parse(botUrl + url);
      default:
        return '';
    }
  }

  static Future get(
    String url, {
    required String service,
    int responseCode = 200,
  }) async {
    Uri uri = getBaseUrl(service, url);
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == responseCode) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        print('Error fetching data.');
        return {};
      }
    } catch (error) {
      print('Error fetching data.');
      return {};
    }
  }

  static Future post(
    String url, {
    required String service,
    int responseCode = 201,
    required Map<String, dynamic> body,
  }) async {
    Uri uri = getBaseUrl(service, url);
    try {
      final response =
          await http.post(uri, body: jsonEncode(body), headers: headers);
      if (response.statusCode == responseCode) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        print('Error posting data.');
        return {};
      }
    } catch (error) {
      print('Error posting data.');
      return {};
    }
  }

  static Future patch(
    String url, {
    required String service,
    int responseCode = 200,
    required Map<String, dynamic> body,
  }) async {
    Uri uri = getBaseUrl(service, url);
    try {
      final response =
          await http.patch(uri, body: jsonEncode(body), headers: headers);
      if (response.statusCode == responseCode) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        print('Error patching data.');
        return {};
      }
    } catch (error) {
      print('Error patching data.');
      return {};
    }
  }

  static Future delete(
    String url, {
    required String service,
    int responseCode = 204,
  }) async {
    Uri uri = getBaseUrl(service, url);
    try {
      final response = await http.delete(uri, headers: headers);
      if (response.statusCode == responseCode) {
        return true;
      } else {
        print('Error deleting data.');
        return false;
      }
    } catch (error) {
      print('Error deleting data.');
      return false;
    }
  }
}
