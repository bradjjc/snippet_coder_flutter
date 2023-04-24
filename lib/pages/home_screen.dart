import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:http/http.dart';
import 'package:youtube_webrtc/models/meeting_details.dart';
import 'package:youtube_webrtc/pages/join_screen.dart';
import '../api/meeting_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String meetingId = '';
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

  void validateMeeting(String meetingId) async {
    try {
      Response? response = await joinMeeting(meetingId);
      var data = json.decode(response!.body);
      final meetingDetails = MeetingDetails.fromJson(data["data"]);
      goToJoinScreen(meetingDetails);
    } catch (err) {
      FormHelper.showSimpleAlertDialog(
        context,
        'Meeting App',
        'Invalid Meeting Id',
        'OK',
        () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  goToJoinScreen(MeetingDetails meetingDetails) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => JoinScreen(
                  meetingDetails: meetingDetails,
                )));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting App'),
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
            const Text(
              'Meeting App',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            FormHelper.inputFieldWidget(
              context,
              "meetingId",
              "Enter your Meeting Id",
              (val) {
                if (val.isEmpty) {
                  return "Meeting Id can't be empty";
                }
                // else null;
              },
              (onSaved) {
                meetingId = onSaved;
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
                    "Join Meeting",
                    () {
                      if (validateAndSave()) {
                        validateMeeting(meetingId);
                      }
                    },
                  ),
                ),
                Flexible(
                  child: FormHelper.submitButton(
                    "Start Meeting",
                    () async {
                      var response = await startMeeting();
                      final body = json.decode(response!.body);
                      meetingId = body['data'];
                      validateMeeting(meetingId);
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
