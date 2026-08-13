import 'package:flutter/material.dart';

class HyperlinkText extends StatefulWidget {
  final bool? defaultColor;
  final bool? isDisabled;
  final FocusNode? node;
  final int? alpha;
  final String text;
  final void Function() onTap;
  final TextAlign? align;
  final TextStyle? style;

  const HyperlinkText({
    super.key,
    required this.text,
    required this.onTap,
    this.align,
    this.alpha = 255,
    this.defaultColor = true,
    this.isDisabled = false,
    this.node,
    this.style,
  });

  @override
  State<HyperlinkText> createState() => _HyperlinkTextState();
}

class _HyperlinkTextState extends State<HyperlinkText> {
  bool isClicked = false;
  bool isHovering = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.node != null) {
      focusNode = widget.node!;
    }

    focusNode.addListener(onFocusChange);
  }

  void onFocusChange() {
    setState(() {
      isHovering = true;
    });
  }

  @override
  void dispose() {
    focusNode.removeListener(onFocusChange);
    if (widget.node == null) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) => widget.isDisabled!
            ? null
            : setState(() {
                isHovering = true;
              }),
        onExit: (event) => widget.isDisabled!
            ? null
            : setState(() {
                isClicked = false;
                isHovering = false;
              }),
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (details) => widget.isDisabled!
              ? null
              : setState(() {
                  isClicked = true;
                }),
          onTapUp: (details) => widget.isDisabled!
              ? null
              : setState(() {
                  isClicked = false;
                }),
          onTapCancel: () => widget.isDisabled!
              ? null
              : setState(() {
                  isClicked = false;
                }),
          child: Text(
            widget.text,
            textAlign: widget.align,
            style:
                widget.style?.copyWith(
                  color: isClicked
                      ? Theme.of(context).colorScheme.surface
                      : isHovering
                      ? Theme.of(context).colorScheme.onPrimary
                      : widget.defaultColor!
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.surface.withAlpha(widget.alpha!),
                  decoration: focusNode.hasFocus
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ) ??
                Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: isClicked
                      ? Theme.of(context).colorScheme.surface
                      : isHovering
                      ? Theme.of(context).colorScheme.onPrimary
                      : widget.defaultColor!
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.surface.withAlpha(widget.alpha!),
                  decoration: focusNode.hasFocus
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
          ),
        ),
      ),
    );
  }
}
