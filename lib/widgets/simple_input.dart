import 'package:flutter/material.dart';

class SimpleInput extends StatelessWidget {
  final bool? isMulti;
  final bool? isWrong;
  final bool? nextOnEnter;
  final bool? obscureText;
  final bool? selectOnTap;
  final Function()? onTap;
  final Function(String)? onChanged;
  final Function(String)? onEnter;
  final String labelText;
  final TextEditingController controller;

  const SimpleInput({
    super.key,
    required this.controller,
    required this.labelText,
    this.onChanged,
    this.onEnter,
    this.onTap,
    this.isMulti = false,
    this.isWrong = false,
    this.nextOnEnter = true,
    this.obscureText = false,
    this.selectOnTap = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: isMulti!
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      onChanged: onChanged,
      onSubmitted: onEnter,
      onTap: selectOnTap!
          ? () {
              controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.value.text.length,
              );
            }
          : onTap,
      textInputAction: isMulti!
          ? TextInputAction.newline
          : nextOnEnter!
          ? TextInputAction.next
          : TextInputAction.done,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isWrong!
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
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
      obscureText: obscureText ?? false,
      style: TextStyle(color: Theme.of(context).colorScheme.surface),
      maxLines: obscureText! || !isMulti! ? 1 : null,
      minLines: isMulti! ? 3 : 1,
    );
  }
}
