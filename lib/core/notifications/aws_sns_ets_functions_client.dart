/*
  create functions to send to the 3 endpoints defined in this file:
  /**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const {
  SNSClient,
  CreatePlatformEndpointCommand,
  GetEndpointAttributesCommand,
  SetEndpointAttributesCommand,
} = require("@aws-sdk/client-sns");


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

exports.createPlatformEndpoint = onRequest(async (request, response) => {
  logger.info("[createPlatformEndpoint]", {structuredData: true});
  const region = request.query.region;
  const token = request.query.token;
  const client = new SNSClient({region: region, credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY,
    secretAccessKey: process.env.AWS_SECRET_KEY}});
  const command = new CreatePlatformEndpointCommand({
    PlatformApplicationArn: process.env.PLATFORM_APPLICATION_ARN,
    Token: token,
  });
  response.send(await client.send(command));
});


exports.getEndpointAttributes = onRequest(async (request, response) => {
  logger.info("[getEndpointAttributes]", {structuredData: true});

  const region = request.query.region;
  const endpointArn = request.query.endpointArn;
  const client = new SNSClient({region: region, credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY,
    secretAccessKey: process.env.AWS_SECRET_KEY}});
  const command = new GetEndpointAttributesCommand({
    EndpointArn: endpointArn,
  });
  response.send(await client.send(command));
});


exports.setEndpointAttributes = onRequest(async (request, response) => {
  logger.info("[setEndpointAttributes]", {structuredData: true});

  const region = request.query.region;
  const endpointArn = request.query.endpointArn;
  const client = new SNSClient({region: region, credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY,
    secretAccessKey: process.env.AWS_SECRET_KEY}});

  const command = new SetEndpointAttributesCommand({
    EndpointArn: endpointArn,
    Attributes: {
      Token: request.query.token,
      Enabled: "true",
    },
  });
  response.send(await client.send(command));
});


*/
import 'package:http/http.dart' as http;

mixin AWSSNSEtsFunctionsClient {
  static const String _baseUrl =
      'http://127.0.0.1:5001/etsmobile-14206/us-central1/';
  static const String _createPlatformEndpointFunction =
      'createPlatformEndpoint';
  static const String _getEndpointAttributesFunction = 'getEndpointAttributes';
  static const String _setEndpointAttributesFunction = 'setEndpointAttributes';

  static Future createPlatformEndpoint(String region, String token) async {
    final response =
        await _callFunction(_createPlatformEndpointFunction, region, token);
    return response;
  }

  static Future getEndpointAttributes(String region, String endpointArn) async {
    final response = await _callFunction(
        _getEndpointAttributesFunction, region, endpointArn);
    return response;
  }

  static Future setEndpointAttributes(
      String region, String endpointArn, String token) async {
    final response = await _callFunction(
        _setEndpointAttributesFunction, region, endpointArn, token);
    return response;
  }

  static Future _callFunction(
      String functionName, String region, String endpointArn,
      [String token]) async {
    final url =
        '$_baseUrl$functionName?region=$region&endpointArn=$endpointArn${token != null ? '&token=$token' : ''}';
    final response = await http.get(Uri.parse(url));
    return response;
  }
}
