import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
export 'package:matomo_tracker/matomo_tracker.dart';

RouteObserver<ModalRoute<void>> get crossClassifyObserver => matomoObserver;

class CrossClassify {
  CrossClassify._();
  static final instance = CrossClassify._();

  final _baseUrl = 'https://api.crossclassify.com/collect';
  final _matomoEndpoint = '/matomo.php';

  bool _initialized = false;
  bool get initialized => _initialized;

  final Map<String, FormFieldConfig> formFields = {};
  final _formInterval = const Duration(seconds: 30);
  Timer? _timer;

  Future<void> initialize({required String apiKey, required int siteId}) async {
    if (_initialized) {
      //TODO
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

  void _setDispatchTimer() {
    _timer = Timer.periodic(_formInterval, (timer) {
      _apiCall();
    });
  }

  void addFormField(String key, FormFieldConfig formFieldModel) {
    if (formFields[key] != null) {
      //TODO Refactor all exceptions
      throw Exception("There is an existing form with this key!");
    }
    if (formFields.isEmpty) {
      _setDispatchTimer();
    }
    formFields[key] = formFieldModel;
  }

  void removeFormField(String key) {
    final model = formFields.remove(key);
    if (model == null) {
      throw Exception("There is not a form field model with this key!");
    } else {
      if (formFields.isEmpty) {
        _disposeDispatchTimer();
      }
      model.controller.dispose();
    }
  }

  void onFormSubmit() {
    _apiCall();
    _disposeDispatchTimer();
  }

  void dispose() {
    _disposeDispatchTimer();
    for (final element in formFields.entries) {
      element.value.controller.dispose();
    }
  }

  void _disposeDispatchTimer() {
    _timer?.cancel();
  }

  void _apiCall() {
    for (final fields in formFields.entries) {
      print('${fields.value.formFieldType}: ${fields.value.controller.text}');
    }
  }
}

class FormFieldConfig {
  FormFieldConfig({
    required this.formFieldType,
    required this.trackContent,
    required this.controller,
  });
  final String formFieldType;
  final bool trackContent;
  final TextEditingController controller;
}

class FormFieldTrackModel {
  FormFieldTrackModel({
    // required this.fa_fn,
    // this.fa_cn,
    this.totalTimeSpent,
    this.hesitationTime,
    this.leftBlank,
    this.numberOfChanges,
    this.numberOfFocus,
    this.numberOfDeletes,
    this.numberOfCursor,
    this.formType,
    this.size,
  });

  // final String fa_fn;
  // String? fa_cn;
  int? totalTimeSpent; // total time spent
  int? hesitationTime; // hesitation time
  bool? leftBlank; // left blank
  int? numberOfChanges; // number of changes
  int? numberOfFocus; // number of focus
  int? numberOfDeletes; // number of deletes
  int? numberOfCursor; // number of cursor
  String? formType; // type
  int? size; // size
}
