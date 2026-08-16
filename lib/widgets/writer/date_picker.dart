import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';
import 'package:once_upon_a_time/barrel.dart';
import 'package:vph_web_date_picker/vph_web_date_picker.dart';

class DatePicker extends StatefulWidget {
  final bool? isDisabled;
  final FocusNode? node;
  final Function(DateTime?) onSave;
  final String label;
  final String? initValue;
  final TextEditingController? cont;

  const DatePicker({
    super.key,
    required this.label,
    required this.onSave,
    this.cont,
    this.initValue,
    this.isDisabled = false,
    this.node,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  bool isEnteringDate = false;
  DateTime? date;
  FocusNode dateNode = FocusNode();
  GlobalKey dateKey = GlobalKey();
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.cont != null) {
      dateController = widget.cont!;
    }
    if (widget.initValue != null) {
      dateController.text = widget.initValue!;
    }
    if (widget.node != null) {
      dateNode = widget.node!;
    }

    dateNode.addListener(() {
      handleDateFocus(context);
    });
  }

  @override
  void dispose() {
    dateNode.removeListener(() {
      handleDateFocus(context);
    });
    if (widget.node == null) {
      dateNode.dispose();
    }
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        SingleActivator(LogicalKeyboardKey.tab): () => handleDateFocus(context),
      },
      child: SizedBox(
        width: 150,
        child: Stack(
          children: [
            SizedBox(
              width: 150,
              child: SimpleInput(
                controller: dateController,
                key: dateKey,
                labelText: isEnteringDate && date == null
                    ? 'mm/dd/yyyy'
                    : widget.label,
              ),
            ),
            const SizedBox(width: 5),
            Positioned(
              right: 0,
              top: 2,
              child: IconButton(
                icon: Icon(Icons.calendar_month),
                onPressed: () async {
                  DateTime initDate =
                      DateFormat('MM/dd/yyyy').tryParse(dateController.text) !=
                          null
                      ? DateFormat('MM/dd/yyyy').tryParse(dateController.text)!
                      : DateTime.now();
                  final pickedDateRange = await showWebDatePicker(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.inverseSurface,
                    context: dateKey.currentContext!,
                    autoCloseOnDateSelect: true,
                    initialDate: initDate,
                    width: 300,
                  );
                  if (pickedDateRange != null) {
                    dateController.text = pickedDateRange.start
                        .toString()
                        .split(' ')[0];
                    setState(() {
                      dateController.text = DateFormat(
                        'MM/dd/yyyy',
                      ).format(DateTime.parse(dateController.text));
                    });
                    if (context.mounted) {
                      handleDateFocus(context);
                    } else {
                      Logger().e('Error mounting context and handling date');
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleDateFocus(BuildContext context) {
    setState(() {
      isEnteringDate = true;
    });
    if (!dateNode.hasFocus) {
      String dateText = dateController.text;
      if (DateFormat('MM/dd/yy').tryParse(dateText) != null) {
        setState(() {
          date = DateFormat('MM/dd/yy').parse(dateText);
          dateController.text = DateFormat.yMd().format(date!);
        });
      } else if (DateFormat('MM-dd-yy').tryParse(dateText) != null) {
        setState(() {
          date = DateFormat('MM/dd/yy').parse(dateText);
          dateController.text = DateFormat.yMd().format(date!);
        });
      } else if (DateFormat('MM/dd/yyyy').tryParse(dateText) != null) {
        setState(() {
          date = DateFormat('MM/dd/yyyy').parse(dateController.text);
          dateController.text = DateFormat.yMd().format(date!);
        });
      } else if (DateFormat('MM-dd-yyyy').tryParse(dateText) != null) {
        setState(() {
          date = DateFormat('MM-dd-yyyy').parse(dateController.text);
          dateController.text = DateFormat.yMd().format(date!);
        });
      } else if (dateController.text != '') {
        if (!dateText.contains((RegExp('/'))) &&
            !dateText.contains((RegExp('-'))) &&
            dateText.length >= 6) {
          String updatedDate =
              '${dateText.substring(0, 2)}/${dateText.substring(2, 4)}/${dateText.substring(4)}';

          if (DateFormat('MM/dd/yy').tryParse(updatedDate) != null) {
            setState(() {
              date = DateFormat('MM/dd/yy').parse(updatedDate);
              dateController.text = DateFormat.yMd().format(date!);
            });
          } else {
            handleBadDate(context);
          }
        } else {
          handleBadDate(context);
        }
      } else {
        setState(() {
          date = null;
        });
      }
      setState(() {
        isEnteringDate = false;
      });
    }

    if (date != null && !isEnteringDate) {
      widget.onSave(date);
    }
  }

  void handleBadDate(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text('Please provide an appropriate date.')),
      );
    setState(() {
      date = null;
      dateController.clear();
    });
    widget.onSave(date);
  }
}
