import 'package:flutter/material.dart';
import 'package:once_upon_a_time/barrel.dart';

class StoryDetailsRow extends StatelessWidget {
  final bool? isArchived;
  final double? labelWidth;
  final double? padding;
  final double? width;
  final List<String>? values;
  final String label;
  final String value;
  final void Function()? onHyperlink;

  const StoryDetailsRow({
    super.key,
    required this.label,
    required this.value,
    this.isArchived = false,
    this.labelWidth = 100,
    this.onHyperlink,
    this.padding = 12,
    this.values = const [],
    this.width = 250,
  });

  @override
  Widget build(BuildContext context) {
    List<String> sortedValues = [];
    if (values!.isNotEmpty) {
      sortedValues = values!.toList();
      sortedValues.sort((a, b) => a.compareTo(b));
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding!,
        vertical: padding! / 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth!,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface.withAlpha(125),
              ),
            ),
          ),
          values!.isNotEmpty
              ? SizedBox(
                  width: width,
                  child: sortedValues.isNotEmpty
                      ? _buildValues(context, sortedValues)
                      : const SizedBox(),
                )
              : SizedBox(
                  width: width,
                  child: onHyperlink != null
                      ? HyperlinkText(
                          text: isArchived! ? 'Yes, Activate' : 'No, Archive',
                          onTap: onHyperlink!,
                        )
                      : Text(value),
                ),
        ],
      ),
    );
  }

  Widget _buildValues(BuildContext context, List<String> sortedValues) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: sortedValues.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(sortedValues[index]),
        );
      },
    );
  }
}
