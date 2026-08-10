import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  final bool? isMulti;
  final bool? obscureText;
  final FocusNode? node;
  final Function(String)? onChanged;
  final Function(String)? onEnter;
  final String labelText;
  final String? initialValue;
  final TextEditingController? cont;

  const CustomInput({
    super.key,
    required this.labelText,
    this.onChanged,
    this.onEnter,
    this.cont,
    this.initialValue = '',
    this.isMulti = false,
    this.node,
    this.obscureText = false,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  FocusNode focusNode = FocusNode();
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.cont != null) {
      controller = widget.cont!;
    }

    if (widget.initialValue != null) {
      controller.text = widget.initialValue!;
    }

    if (widget.node != null) {
      focusNode = widget.node!;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    if (widget.node == null) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: widget.isMulti!
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      // onChanged: widget.onChanged,
      onChanged: (value) {
        controller.selection = TextSelection(
          baseOffset: controller.text.length,
          extentOffset: controller.text.length,
        );
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
      onSubmitted: widget.onEnter,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surface,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
      ),
      obscureText: widget.obscureText ?? false,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.surface,
      ),
      maxLines: widget.isMulti! ? null : 1,
      minLines: widget.isMulti! ? 3 : 1,
    );
  }
}
