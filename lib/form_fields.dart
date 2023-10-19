import 'package:cross_classify_sdk/cross_classify.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TrackableFormWidget extends StatefulWidget {
  final String id;
  final Widget formWidget;
  final FormFieldConfig formFieldConfig;
  TrackableFormWidget({
    super.key,
    required this.formFieldConfig,
    required this.formWidget,
  }) : id = const Uuid().v4();

  @override
  State<TrackableFormWidget> createState() => _TrackableFormWidgetState();
}

class _TrackableFormWidgetState extends State<TrackableFormWidget> {
  final CrossClassify _tracker = CrossClassify.instance;

  @override
  void initState() {
    super.initState();
    _tracker.addFormField(widget.id, widget.formFieldConfig);
  }

  @override
  Widget build(BuildContext context) {
    return widget.formWidget;
  }

  @override
  void dispose() {
    _tracker.removeFormField(widget.id);
    super.dispose();
  }
}
