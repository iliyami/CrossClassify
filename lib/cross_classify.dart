import 'package:flutter/foundation.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
export 'package:matomo_tracker/matomo_tracker.dart';

class CrossClassify {
  CrossClassify._();
  static final instance = CrossClassify._();

  final _baseUrl = 'https://api.crossclassify.com/collect';
  final _matomoEndpoint = '/matomo.php';

  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> initialize({required String apiKey, required int siteId}) async {
    if (_initialized) {
      throw UnimplementedError();
    }

    await MatomoTracker.instance.initialize(
      siteId: siteId,
      url: _baseUrl + _matomoEndpoint,
      customHeaders: {'x-api-key': apiKey},
      verbosityLevel: kDebugMode ? Level.all : Level.off,
    );

    _initialized = true;
  }
}
