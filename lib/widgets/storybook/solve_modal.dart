import 'dart:math';

import 'package:flutter/material.dart';
import 'package:once_upon_a_time/barrel.dart';

class SolveModal extends StatefulWidget {
  final Story story;

  const SolveModal({super.key, required this.story});

  @override
  State<SolveModal> createState() => _SolveModalState();
}

class _SolveModalState extends State<SolveModal> {
  bool isWrongPOV = false;
  bool isWrongStory = false;
  String povHint = '';
  String povSolved = '';
  String storyHint = '';
  String storySolved = '';
  TextEditingController povCont = TextEditingController();
  TextEditingController storyCont = TextEditingController();

  @override
  void dispose() {
    povCont.dispose();
    storyCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (storySolved != '') ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                child: Text(
                  storySolved,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ],
            if (storySolved == '') ...[
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: SimpleInput(
                      controller: storyCont,
                      labelText: 'What story is it?',
                      isWrong: isWrongStory,
                      selectOnTap: true,
                      onChanged: (_) => setState(() {
                        isWrongStory = false;
                      }),
                      onEnter: storyCont.text == ''
                          ? null
                          : (_) => solveStory(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: storyCont.text == '' ? null : solveStory,
                    child: Text(
                      'Solve',
                      style: TextStyle(
                        color: storyCont.text == ''
                            ? Theme.of(context).colorScheme.surface
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 8),
                child: Row(
                  children: [
                    Text(
                      storyHint == '' ? 'Hint' : storyHint,
                      style: TextStyle(
                        color: storyHint == ''
                            ? Theme.of(context).dialogTheme.backgroundColor
                            : Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        List<String> hintList = [];
                        String hint = storyHint.toLowerCase();
                        if (widget.story.titleHints != null) {
                          hintList = widget.story.titleHints!.toList();
                          int index = hintList.indexWhere((h) => h == hint);
                          if (index >= 0) {
                            hintList.removeAt(index);
                          }
                          if (hintList.isNotEmpty) {
                            int randomIndex = Random().nextInt(hintList.length);
                            hint = hintList[randomIndex].capitalizeWords();
                          }
                        }
                        setState(() {
                          storyHint = hint;
                        });
                      },
                      child: Text('Hint'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 25),
            if (povSolved != '') ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                child: Text(
                  povSolved,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ],
            if (povSolved == '') ...[
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: GestureDetector(
                      onDoubleTap: () {
                        povCont.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: povCont.value.text.length,
                        );
                      },
                      child: SimpleInput(
                        controller: povCont,
                        labelText: 'Whose point of view?',
                        isWrong: isWrongPOV,
                        selectOnTap: true,
                        onChanged: (_) => setState(() {
                          isWrongPOV = false;
                        }),
                        onEnter: povCont.text == '' ? null : (_) => solvePOV(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: povCont.text == '' ? null : solvePOV,
                    child: Text(
                      'Solve',
                      style: TextStyle(
                        color: povCont.text == ''
                            ? Theme.of(context).colorScheme.surface
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 8),
                child: Row(
                  children: [
                    Text(
                      povHint == '' ? 'Hint' : povHint,
                      style: TextStyle(
                        color: povHint == ''
                            ? Theme.of(context).dialogTheme.backgroundColor
                            : Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        List<String> hintList = [];
                        String hint = povHint.toLowerCase();
                        if (widget.story.povHints != null) {
                          hintList = widget.story.povHints!.toList();
                          int index = hintList.indexWhere((h) => h == hint);
                          if (index >= 0) {
                            hintList.removeAt(index);
                          }
                          if (hintList.isNotEmpty) {
                            int randomIndex = Random().nextInt(hintList.length);
                            hint = hintList[randomIndex].capitalize();
                          }
                        }
                        setState(() {
                          povHint = hint;
                        });
                      },
                      child: Text('Hint'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void solvePOV() {
    bool isRight = false;
    String guess = povCont.text.toLowerCase();
    for (var pov in widget.story.pov) {
      if (pov.toLowerCase() == guess) {
        isRight = true;
      }
    }

    if (isRight) {
      setState(() {
        povSolved = 'Yup, it\'s ${widget.story.pov.first}.';
      });
    } else {
      setState(() {
        isWrongPOV = true;
      });
    }
  }

  void solveStory() {
    bool isApprox = false;
    String guess = storyCont.text.toLowerCase();

    if (widget.story.titleApproximates != null &&
        widget.story.titleApproximates!.isNotEmpty) {
      for (var approx in widget.story.titleApproximates!) {
        if (approx.toLowerCase() == guess) {
          isApprox = true;
        }
      }
    }

    if (widget.story.title.toLowerCase() == guess) {
      setState(() {
        storySolved = 'Huzzah, it is ${widget.story.title}.';
      });
    } else if (isApprox) {
      setState(() {
        storySolved = 'Close enough, it\'s ${widget.story.title}.';
      });
    } else {
      setState(() {
        isWrongStory = true;
      });
    }
  }
}
