import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:once_upon_a_time/barrel.dart';

class SolveModal extends StatefulWidget {
  const SolveModal({super.key});

  @override
  State<SolveModal> createState() => _SolveModalState();
}

class _SolveModalState extends State<SolveModal> {
  TextEditingController solveCont = TextEditingController();

  @override
  void dispose() {
    solveCont.dispose();
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
            SimpleInput(
              controller: solveCont,
              labelText: 'What story is it?',
              // onChanged: (value) {
              //   setState(() {
              //     solveCont.text = value;
              //   });
              // },
              // onEnter: (_) {},
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: solveCont.text == ''
                    ? null
                    : () {
                        print(
                          context.read<StoryBloc>().state.currentStory.title,
                        );
                        // widget.onUpdate(newContent.text);
                        // Navigator.of(context).pop();
                      },
                child: Text(
                  'Solve',
                  style: TextStyle(
                    color: solveCont.text == ''
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
