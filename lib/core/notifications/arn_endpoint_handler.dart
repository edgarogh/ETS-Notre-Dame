import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/notifications/aws_sns_ets_functions_client.dart';
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
  final FlutterSecureStorage _secureStorage = locator<FlutterSecureStorage>();

  String _region;
  String _endpointArn;

  Future<void> loadAwsConfig() async {
    _endpointArn =
        await _preferencesService.getString(PreferencesFlag.awsEndpointArn);

    _region = 'us-east-1';
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

    final res = await AWSSNSEtsFunctionsClient.getEndpointAttributes(
        _region, _endpointArn);

    final universalCode =
        await _secureStorage.read(key: UserRepository.usernameSecureKey);
    final attributes = res['Attributes'] as Map<String, dynamic>;
    final needUpdate = attributes['Token'] != token ||
        attributes['Enabled'] != 'true' ||
        attributes['CustomUserData'] != 'ENS\\$universalCode';
    if (needUpdate) {
      await AWSSNSEtsFunctionsClient.setEndpointAttributes(
          _region, _endpointArn, token, universalCode);
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

    final universalCode =
        await _secureStorage.read(key: UserRepository.usernameSecureKey);

    final result = await AWSSNSEtsFunctionsClient.createPlatformEndpoint(
        _region, token, universalCode);

    _endpointArn = result['EndpointArn'] as String;
    saveAWSEndpoint(_endpointArn);
  }

  Future deleteEndpoint() async {
    if (kDebugMode) {
      print("[deleteEndpoint]");
    }

    if (!_endpointArnIsValid()) {
      throw Exception('EndpointArn is not valid');
    }

    await AWSSNSEtsFunctionsClient.deleteEndpoint(_region, _endpointArn);
    _endpointArn = null;
    await _preferencesService
        .removePreferencesFlag(PreferencesFlag.awsEndpointArn);
  }

  bool _endpointArnIsValid() {
    return _endpointArn != null && _endpointArn.isNotEmpty;
  }
}
