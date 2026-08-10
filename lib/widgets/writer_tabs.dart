import 'package:flutter/material.dart';
import 'package:once_upon_a_time/barrel.dart';

class WriterTabs extends StatelessWidget {
  final double? height;
  final dynamic activeTab;
  final Function(dynamic) updateTab;
  final List<Map<String, dynamic>> tabs;

  const WriterTabs({
    super.key,
    required this.activeTab,
    required this.tabs,
    required this.updateTab,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Row(
        children: tabs
            .map(
              (tab) => WriterTab(
                tabId: tab.values.first,
                tabName: tab.keys.first,
                activeTab: activeTab,
                updateTab: updateTab,
              ),
            )
            .toList(),
      ),
    );
  }
}
