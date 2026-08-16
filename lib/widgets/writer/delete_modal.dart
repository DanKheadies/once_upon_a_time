import 'dart:async';

import 'package:flutter/material.dart';
import 'package:once_upon_a_time/barrel.dart';

class DeleteModal extends StatefulWidget {
  final Future<bool> Function() onDelete;
  final String title;

  const DeleteModal({super.key, required this.onDelete, required this.title});

  @override
  State<DeleteModal> createState() => _DeleteModalState();
}

class _DeleteModalState extends State<DeleteModal> {
  bool hadProblem = false;
  bool hasDeleted = false;
  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(25),
        width: 350,
        child: hadProblem
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Something went wrong.'),
                  const SizedBox(height: 35),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('RIP'),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasDeleted) ...[
                    Text('${widget.title} has been deleted.'),
                    const SizedBox(height: 35),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Otay'),
                      ),
                    ),
                  ],
                  if (!hasDeleted) ...[
                    Text('Are you sure you want to delete ${widget.title}?'),
                    const SizedBox(height: 35),
                    if (isDeleting) ...[LinearProgressIndicator()],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!isDeleting) ...[
                          HyperlinkText(
                            text: 'Nevermind',
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isDeleting = true;
                              });

                              bool didDelete = await widget.onDelete();

                              setState(() {
                                hasDeleted = didDelete;
                                hadProblem = !didDelete;
                              });
                            },
                            child: Text('Yes'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
