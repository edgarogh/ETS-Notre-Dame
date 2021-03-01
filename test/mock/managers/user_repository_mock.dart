// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';

// SERVICE
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/models/mon_ets_user.dart';
import 'package:notredame/core/models/profile_student.dart';
import 'package:notredame/core/models/program.dart';
import 'package:notredame/core/utils/api_exception.dart';

/// Mock for the [UserRepository]
class UserRepositoryMock extends Mock implements UserRepository {
  /// When [monETSUser] is called will return [userToReturn]
  static void stubMonETSUser(UserRepositoryMock mock, MonETSUser userToReturn) {
    when(mock.monETSUser).thenAnswer((_) => userToReturn);
  }

  /// Stub the authentication, when [username] is used will return [toReturn].
  /// By default validate the authentication
  static void stubAuthenticate(UserRepositoryMock mock, String username,
      {bool toReturn = true}) {
    when(mock.authenticate(username: username, password: anyNamed('password')))
        .thenAnswer((_) async => toReturn);
  }

  /// Stub the silent authentication, return [toReturn]
  /// By default validate the silent authentication
  static void stubSilentAuthenticate(UserRepositoryMock mock,
      {bool toReturn = true}) {
    when(mock.silentAuthenticate()).thenAnswer((_) async => toReturn);
  }

  /// Stub the getPassword function, return [passwordToReturn]
  static void stubGetPassword(
      UserRepositoryMock mock, String passwordToReturn) {
    when(mock.getPassword()).thenAnswer((_) async => passwordToReturn);
  }

  /// Stub the getPassword function to throw [exceptionToReturn]
  static void stubGetPasswordException(UserRepositoryMock mock,
      {ApiException exceptionToReturn =
          const ApiException(prefix: UserRepository.tag, message: "")}) {
    when(mock.getPassword()).thenThrow(exceptionToReturn);
  }

  /// Stub the getter [ProfileStudent] of [mock] when called will return [toReturn].
  static void stubProfileStudent(UserRepositoryMock mock,
      {ProfileStudent toReturn}) {
    when(mock.info).thenReturn(toReturn);
  }

  /// Stub the function [getInfo] of [mock] when called will return [toReturn].
  static void stubGetInfo(UserRepositoryMock mock,
      {ProfileStudent toReturn, bool fromCacheOnly}) {
    when(mock.getInfo(
            fromCacheOnly: fromCacheOnly ?? anyNamed("fromCacheOnly")))
        .thenAnswer((_) async => toReturn);
  }

  /// Stub the function [getInfo] of [mock] when called will throw [toThrow].
  static void stubGetInfoException(UserRepositoryMock mock,
      {Exception toThrow =
          const ApiException(prefix: 'ApiException', message: ''),
      bool fromCacheOnly}) {
    when(mock.getInfo(
            fromCacheOnly: fromCacheOnly ?? anyNamed("fromCacheOnly")))
        .thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50))
            .then((value) => throw toThrow));
  }

  /// Stub the getter [coursesActivities] of [mock] when called will return [toReturn].
  static void stubPrograms(UserRepositoryMock mock,
      {List<Program> toReturn = const []}) {
    when(mock.programs).thenReturn(toReturn);
  }

  /// Stub the function [getPrograms] of [mock] when called will return [toReturn].
  static void stubGetPrograms(UserRepositoryMock mock,
      {List<Program> toReturn = const [], bool fromCacheOnly}) {
    when(mock.getPrograms(
            fromCacheOnly: fromCacheOnly ?? anyNamed("fromCacheOnly")))
        .thenAnswer((_) async => toReturn);
  }

  /// Stub the function [getPrograms] of [mock] when called will throw [toThrow].
  static void stubGetProgramsException(UserRepositoryMock mock,
      {Exception toThrow =
          const ApiException(prefix: 'ApiException', message: ''),
      bool fromCacheOnly}) {
    when(mock.getPrograms(
            fromCacheOnly: fromCacheOnly ?? anyNamed("fromCacheOnly")))
        .thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50))
            .then((value) => throw toThrow));
  }
}