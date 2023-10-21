import 'dart:async';

import 'package:cross_classify_sdk/models/form_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:uuid/uuid.dart';
export 'package:matomo_tracker/matomo_tracker.dart';

RouteObserver<ModalRoute<void>> get crossClassifyObserver => matomoObserver;

class CrossClassify {
  CrossClassify._();
  static final instance = CrossClassify._();

  final _baseUrl = 'https://api.crossclassify.com/collect';
  final _matomoEndpoint = '/matomo.php';

  bool _initialized = false;
  bool get initialized => _initialized;

  final List<FormFieldModel> formFields = [];
  final _formInterval = const Duration(seconds: 10);
  Timer? _timer;
  late final DateTime _startTime;
  late final String? _formName;
  late final PerformanceInfo? _performanceInfo;
  late final String _pageViewId;
  Duration? _formHesitationTime;

  Future<void> initialize({required String apiKey, required int siteId}) async {
    if (_initialized) {
      //TODO handle all exptions properly
      throw Exception('Already Initialized!');
    }

    await MatomoTracker.instance.initialize(
      siteId: siteId,
      url: _baseUrl + _matomoEndpoint,
      customHeaders: {'x-api-key': apiKey},
      verbosityLevel: kDebugMode ? Level.all : Level.off,
    );

    _initialized = true;
  }

  void initForm({
    required String pvId,
    required String? formName,
    required PerformanceInfo? performanceInfo,
  }) {
    _checkServiceInitialization();
    _startTime = DateTime.now();
    _pageViewId = pvId;
    _formName = formName;
    _performanceInfo = performanceInfo;
  }

  void _checkServiceInitialization() {
    if (_initialized == false) {
      throw Exception('''The Cross Classify service has not been started yet!
          Call CrossClassify.instance.initialize to initialize the service.''');
    }
  }

  void setPageViewId(String id) => _pageViewId = id;

  void _setDispatchTimer() {
    _timer = Timer.periodic(_formInterval, (timer) {
      trackForm();
    });
  }

  void addFormField(FormFieldConfig config) {
    _checkServiceInitialization();
    final formField = FormFieldModel(
      id: config.id,
      trackContent: config.trackContent,
      controller: config.controller,
      node: config.node,
      faFt: config.formFieldType,
      faFn: config.formFieldType,
    );
    if (formFields.isEmpty) {
      _setDispatchTimer();
      _subscribeFormHesitationTime(formField);
    }

    _registerFocusNode(formField);
    _registerTextController(formField);
    formFields.add(formField);
  }

  void _registerTextController(FormFieldModel formField) {
    return formField.controller.addListener(() {
      final text = formField.controller.text;
      if (formField.faCn != text) {
        formField.faFts = _timeSinceStart().inMilliseconds;
        formField.faFch++;
      }
      if (formField.faFht == null && text.isNotEmpty) {
        formField.faFht = _timeSinceStart().inMilliseconds;
      }
      if (formField.faCn != null && formField.faCn!.length > text.length) {
        formField.faFd++;
      }
      formField.faCn = text;
    });
  }

  void _registerFocusNode(FormFieldModel formField) {
    formField.node.addListener(() {
      if (formField.node.hasFocus) {
        formField.faFf++;
        formField.faFcu++;
      }
    });
  }

  void _subscribeFormHesitationTime(FormFieldModel formField) {
    formField.controller.addListener(() {
      if (_formHesitationTime == null && formField.controller.text.isNotEmpty) {
        _formHesitationTime = _timeSinceStart();
        formField.faFht = _formHesitationTime!.inMilliseconds;
      }
    });
  }

  void _disposeNodeController(int index) {
    formFields[index].controller.dispose();
    formFields[index].node.dispose();
  }

  void removeFormField(String id) {
    final index = formFields.indexWhere((element) => element.id == id);
    if (formFields.isEmpty) {
      _disposeDispatchTimer();
    }
    formFields[index].controller.clear();
    formFields.removeAt(index);
  }

  void onFormSubmit() {
    trackForm();
    _disposeDispatchTimer();
  }

  void _disposeDispatchTimer() {
    _timer?.cancel();
  }

  void _calculateFieldsContentData() {
    for (var field in formFields) {
      final text = field.controller.text;
      if (field.trackContent) {
        field.faCn = text;
      } else {
        field.faCn = null;
      }
      if (text.isEmpty) {
        field.faFb = true;
      } else {
        field.faFb = false;
      }
      field.faFs = text.length;
    }
  }

  void trackForm() {
    _calculateFieldsContentData();
    final FormModel formModel = FormModel(
      faSt: _startTime.millisecondsSinceEpoch.toString(),
      faVid: _pageViewId,
      faTs: _getTimeSpent(),
      faHt: _formHesitationTime?.inMilliseconds.toString(),
      faFields: formFields,
    );
    // for (final fields in formFields) {
    //   debugPrint('type: ${fields.faFt} - content: ${fields.faCn}');
    //   debugPrint('node changes: ${fields.faFf}');
    //   debugPrint('changes: ${fields.faFch}');
    //   debugPrint('Left blank: ${fields.faFb}');
    //   debugPrint('deletes: ${fields.faFd}');
    //   debugPrint('field hesitation time: ${fields.faFht}');
    //   debugPrint('field spent time: ${fields.faFts}');
    // }
    MatomoTracker.instance.trackCustomAction(
      actionName: _formName,
      pvId: _pageViewId,
      performanceInfo: _performanceInfo,
      customActions: formModel.toJson(),
    );
  }

  String _getTimeSpent() =>
      (DateTime.now().difference(_startTime)).inMilliseconds.toString();

  Duration _timeSinceStart() {
    return DateTime.now().difference(_startTime);
  }

  void dispose() {
    _disposeDispatchTimer();
    for (var i = 0; i < formFields.length; i++) {
      _disposeNodeController(i);
    }
  }
}

class FormFieldConfig {
  FormFieldConfig({
    required this.formFieldType,
    required this.trackContent,
    required this.controller,
    required this.node,
  }) : id = const Uuid().v4();
  final String id;
  final String formFieldType;
  final bool trackContent;
  TextEditingController controller;
  final FocusNode node;
}
