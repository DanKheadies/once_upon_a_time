import 'package:flutter/material.dart';
// import 'package:once_upon_a_time/barrel.dart';

class WriterTab extends StatelessWidget {
  final dynamic activeTab;
  final dynamic tabId;
  final String tabName;
  final Function(dynamic) updateTab;

  const WriterTab({
    super.key,
    required this.activeTab,
    required this.tabId,
    required this.tabName,
    required this.updateTab,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: InkWell(
        onTap: activeTab == tabId ? null : () => updateTab(tabId),
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: activeTab == tabId
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          child: Center(
            child: Text(
              tabName,
              // style: Theme.of(context).textTheme.titleMedium!.copyWith(
              //   color: Theme.of(context).colorScheme.surface,
              //   fontWeight: FontWeight.w500,
              // ),
              style: TextStyle(
                color: activeTab == tabId
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
