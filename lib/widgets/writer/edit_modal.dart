import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:once_upon_a_time/barrel.dart';

class EditModal extends StatefulWidget {
  final bool? isMulti;
  final int index;
  final Story newStory;
  final String content;

  const EditModal({
    super.key,
    required this.content,
    required this.index,
    required this.newStory,
    this.isMulti = false,
  });

  @override
  State<EditModal> createState() => _EditModalState();
}

class _EditModalState extends State<EditModal> {
  TextEditingController newContent = TextEditingController();

  @override
  void initState() {
    super.initState();

    newContent.text = widget.content;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.content),
            const SizedBox(height: 15),
            CustomInput(
              labelText: 'Content',
              cont: newContent,
              initialValue: widget.content,
              isMulti: widget.isMulti,
              onChanged: (value) {
                setState(() {
                  newContent.text = value;
                });
              },
              onEnter: (_) {},
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: newContent.text == widget.content
                    ? null
                    : () {
                        List<String> updatedChapters = widget.newStory.chapters
                            .toList();
                        updatedChapters[widget.index] = newContent.text;
                        context.read<StoryBloc>().add(
                          UpdateNewStory(
                            newStory: widget.newStory.copyWith(
                              chapters: updatedChapters,
                            ),
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                child: Text(
                  'Update',
                  style: TextStyle(
                    color: newContent.text == widget.content
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
