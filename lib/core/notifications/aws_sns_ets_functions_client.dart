import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

mixin AWSSNSEtsFunctionsClient {
  static const String _createPlatformEndpointFunction =
      'https://createplatformendpoint-dpvjwynfaq-uc.a.run.app';
  static const String _getEndpointAttributesFunction =
      'https://getendpointattributes-dpvjwynfaq-uc.a.run.app';
  static const String _setEndpointAttributesFunction =
      'https://setendpointattributes-dpvjwynfaq-uc.a.run.app';
  static const String _deleteEndpointFunction =
      'https://deleteendpoint-dpvjwynfaq-uc.a.run.app';

  static Future<Map<String, dynamic>> createPlatformEndpoint(
      String region, String token, String universalCode) async {
    final response = await _callFunction(
        _createPlatformEndpointFunction, region,
        token: token, universalCode: universalCode);
    return response;
  }

  static Future<Map<String, dynamic>> getEndpointAttributes(
      String region, String endpointArn) async {
    final response = await _callFunction(_getEndpointAttributesFunction, region,
        endpointArn: endpointArn);
    return response;
  }

  static Future<Map<String, dynamic>> setEndpointAttributes(String region,
      String endpointArn, String token, String universalCode) async {
    final response = await _callFunction(_setEndpointAttributesFunction, region,
        endpointArn: endpointArn, token: token, universalCode: universalCode);
    print(response);
    return response;
  }

  static Future<Map<String, dynamic>> deleteEndpoint(
      String region, String endpointArn) async {
    final response = await _callFunction(_deleteEndpointFunction, region,
        endpointArn: endpointArn);

    return response;
  }

  static Future<Map<String, dynamic>> _callFunction(
      String functionName, String region,
      {String endpointArn, String token, String universalCode}) async {
    final url =
        '$functionName?region=$region${endpointArn != null ? '&endpointArn=$endpointArn' : ''}${token != null ? '&token=$token' : ''}${universalCode != null ? '&universalCode=$universalCode' : ''}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to call function $functionName');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
