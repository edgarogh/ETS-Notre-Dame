import 'package:aws_sns_api/sns-2010-03-31.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/notifications/aws_keys.dart';
import 'package:notredame/core/services/preferences_service.dart';
import 'package:notredame/locator.dart';

class ArnEndpointHandler {
  final _supportedRegionsList = [
    'us-east-1',
    'us-west-1',
    'us-west-2',
    'sa-east-1',
    'eu-west-1',
    'ap-southeast-1',
    'ap-southeast-2',
    'ap-northeast-1',
    'us-gov-west-1'
  ];
  final PreferencesService _preferencesService = locator<PreferencesService>();

  AwsClientCredentials _credentials;
  String _region;
  String _platformApplicationArn;
  String _endpointArn;

  Future<void> loadAwsConfig() async {
    _credentials = AwsClientCredentials(
        accessKey: AWSKeys.accessKey, secretKey: AWSKeys.secretKey);

    _platformApplicationArn = AWSKeys.platformApplicationArn;

    _endpointArn =
        await _preferencesService.getString(PreferencesFlag.awsEndpointArn);

    _region = _platformApplicationArn.split(':')[3];
    print(_platformApplicationArn);
    print(_region);
  }

  Future saveAWSEndpoint(String awsEndpointArn) async {
    await _preferencesService.setString(
        PreferencesFlag.awsEndpointArn, awsEndpointArn);
  }

  Future createOrUpdateEndpoint(String token) async {
    if (kDebugMode) {
      print("[createOrUpdateEndpoint]");
    }

    if (!_endpointArnIsValid()) {
      await createEndpoint(token);
    } else {
      await updateEndpoint(token);
    }
  }

  Future updateEndpoint(String token) async {
    if (kDebugMode) {
      print("[updateEndpoint]");
    }
    if (!_supportedRegionsList.contains(_region)) {
      throw Exception('Region $_region is not supported');
    }
    print(_credentials);
    final sns = SNS(region: _region, credentials: _credentials);

    final endpoint = await sns.getEndpointAttributes(endpointArn: _endpointArn);
    final needUpdate = endpoint.attributes['Token'] != token ||
        endpoint.attributes['Enabled'] != 'true';

    if (needUpdate) {
      await sns.setEndpointAttributes(attributes: {
        'Token': token,
        'Enabled': 'true',
      }, endpointArn: _endpointArn);
      saveAWSEndpoint(_endpointArn);
    }
  }

  Future createEndpoint(String token) async {
    if (kDebugMode) {
      print("[createEndpoint] token: $token");
    }

    if (!_supportedRegionsList.contains(_region)) {
      throw Exception('Region $_region is not supported');
    }

    print(_credentials.accessKey);
    print(_credentials.secretKey);
    final sns = SNS(region: _region, credentials: _credentials);

    final result = await sns.createPlatformEndpoint(
        platformApplicationArn: _platformApplicationArn, token: token);

    _endpointArn = result.endpointArn;
    saveAWSEndpoint(_endpointArn);
  }

  bool _endpointArnIsValid() {
    return _endpointArn != null && _endpointArn.isNotEmpty;
  }
}
