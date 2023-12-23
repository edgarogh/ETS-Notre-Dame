// Package imports:
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:notredame/core/services/navigation_service.dart';

import 'navigation_service_mock.mocks.dart';

/// Mock for the [NavigationService]
@GenerateMocks([NavigationService])
class NavigationServiceMock extends MockNavigationService {}
