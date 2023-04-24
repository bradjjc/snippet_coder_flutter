import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:youtube_webrtc/models/meeting_details.dart';
import 'package:youtube_webrtc/pages/meeting_page.dart';

class JoinScreen extends StatefulWidget {
  final MeetingDetails? meetingDetails;
  const JoinScreen({Key? key, this.meetingDetails}) : super(key: key);

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String userName = "";
  @override
  void initState() {
    super.initState();
  }

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Meeting'),
        backgroundColor: Colors.grey,
      ),
      body: Form(
        key: globalKey,
        child: formUi(),
      ),
    );
  }

  Widget formUi() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            FormHelper.inputFieldWidget(
              context,
              "userId",
              "Enter your Name",
              (val) {
                if (val.isEmpty) {
                  return "Name can't be empty";
                }
                // else null;
              },
              (onSaved) {
                userName = onSaved;
              },
              borderRadius: 10,
              borderFocusedErrorColor: Colors.blue,
              borderColor: Colors.blue,
              hintColor: Colors.grey,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: FormHelper.submitButton(
                    "Join",
                    () {
                      if (validateAndSave()) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MeetingPage(
                              meetingId: widget.meetingDetails!.id!,
                              name: userName,
                              meetingDetails: widget.meetingDetails!,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
