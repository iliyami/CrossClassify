import 'package:cross_classify_sdk/cross_classify.dart';
import 'package:flutter/material.dart';
import 'package:matomo_tracker/utils/random_alpha_numeric.dart';

class TraceableForm extends StatefulWidget {
  const TraceableForm({super.key, required this.child});

  final Widget child;

  @override
  State<TraceableForm> createState() => _TraceableFormState();
}

class _TraceableFormState extends State<TraceableForm> {
  /// {@template TraceableClientFormMixin.pvId}
  /// A 6 character unique page view ID.
  ///
  /// Each unique ID represents one page view.
  ///
  /// The default implementation will generate one on widget creation
  /// (recommended).
  ///
  /// For more information see `pvId` in [CrossClassify.trackForm]
  /// {@endtemplate}
  @protected
  String get pvId => _pvId;
  final String _pvId = randomAlphaNumeric(6);
  CrossClassify get crossClassify => CrossClassify.instance;

  @override
  void initState() {
    super.initState();
    crossClassify.initForm(pvId);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    crossClassify.dispose();
    super.dispose();
  }
}
