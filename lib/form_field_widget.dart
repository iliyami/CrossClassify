import 'package:cross_classify_sdk/cross_classify.dart';
import 'package:flutter/material.dart';

class ControllableFormFieldWidget extends StatefulWidget {
  final Widget controllableWidget;
  final FormFieldConfig formFieldConfig;
  const ControllableFormFieldWidget({
    super.key,
    required this.formFieldConfig,
    required this.controllableWidget,
  });

  @override
  State<ControllableFormFieldWidget> createState() =>
      _ControllableFormFieldWidgetState();
}

class _ControllableFormFieldWidgetState
    extends State<ControllableFormFieldWidget> {
  final CrossClassify _tracker = CrossClassify.instance;

  @override
  void initState() {
    super.initState();
    _tracker.addFormField(
      widget.formFieldConfig,
    );
  }

  @override
  Widget build(BuildContext context) => widget.controllableWidget;

  @override
  void dispose() {
    _tracker.removeFormField(widget.formFieldConfig.id);
    super.dispose();
  }
}
