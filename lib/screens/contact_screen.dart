import 'package:cloud_functions/cloud_functions.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:once_upon_a_time/barrel.dart';

enum ContactStatus { error, initial, submittting, success }

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  ContactStatus status = ContactStatus.initial;
  TextEditingController emailCont = TextEditingController();
  TextEditingController messageCont = TextEditingController();
  TextEditingController nameCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(isPortrait: true),
      endDrawer: CustomDrawer(isStorybook: false),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // double height = constraints.maxHeight;
            double width = constraints.maxWidth;

            return Center(
              child: status == ContactStatus.error
                  ? Texxt(
                      'Something went wrong.',
                      // style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      //   color: Theme.of(context).colorScheme.surface,
                      // ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(25),
                      width: width < 850 ? width : 500,
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Texxt(
                              'Need to reach us?',
                              // style: Theme.of(context).textTheme.displaySmall!
                              //     .copyWith(
                              //       color: Theme.of(context).colorScheme.surface,
                              //     ),
                              useDark: false,
                            ),
                            const SizedBox(height: 25),
                            CustomInput(
                              cont: nameCont,
                              labelText: 'Name',
                              onChanged: (value) {
                                setState(() {
                                  nameCont.text = value;
                                });
                              },
                              onEnter: (_) {},
                            ),
                            const SizedBox(height: 15),
                            CustomInput(
                              cont: emailCont,
                              labelText: 'Email',
                              onChanged: (value) {
                                setState(() {
                                  emailCont.text = value;
                                });
                              },
                              onEnter: (_) {},
                            ),
                            const SizedBox(height: 15),
                            CustomInput(
                              cont: messageCont,
                              isMulti: true,
                              labelText: 'Message',
                              onChanged: (value) {
                                setState(() {
                                  messageCont.text = value;
                                });
                              },
                              onEnter: (_) {},
                            ),
                            const SizedBox(height: 40),
                            status == ContactStatus.submittting
                                ? const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: SizedBox(
                                      height: 35,
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed:
                                        status == ContactStatus.submittting
                                        ? null
                                        : () => submit(context),
                                    child: Text('Send'),
                                  ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  void clearInputs() {
    setState(() {
      // clearInput = true;
      // email = '';
      emailCont.clear();
      // message = '';
      messageCont.clear();
      // name = '';
      nameCont.clear();
      status = ContactStatus.initial;
    });

    // await Future.delayed(const Duration(milliseconds: 100), () {
    //   setState(() {
    //     clearInput = false;
    //   });
    // });
  }

  void submit(BuildContext context) async {
    setState(() {
      status = ContactStatus.submittting;
    });

    var scaffCont = ScaffoldMessenger.of(context);
    if (emailCont.text == '') {
      scaffCont
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Enter your email.')));
    } else if (nameCont.text == '') {
      scaffCont
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Enter your name.')));
    } else if (messageCont.text == '') {
      scaffCont
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Enter your message.')));
    } else if (EmailValidator.validate(emailCont.text)) {
      try {
        await FirebaseFunctions.instance.httpsCallable('contactMessage').call({
          'email': emailCont.text,
          'message': messageCont.text,
          'name': nameCont.text,
        });

        if (context.mounted) {
          scaffCont
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('Your message has been sent.')),
            );
        }

        clearInputs();
      } on FirebaseFunctionsException catch (error) {
        Logger().e('contact email firebase error', error: error);
        setState(() {
          status = ContactStatus.error;
        });
      } catch (err) {
        setState(() {
          status = ContactStatus.error;
        });
        Logger().e('contact email error', error: err);
      }
    } else {
      scaffCont
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Enter a valid email.')));
    }

    setState(() {
      status = ContactStatus.initial;
    });
  }
}
