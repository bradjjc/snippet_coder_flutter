import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:youtube_webrtc/utils/user.utils.dart';

// String baseUrl = "http://localhost:4000";
String baseUrl = "http://192.168.0.15:4000";
String MEETING_API_URL = "$baseUrl/api/meeting";
var client = http.Client();

Future<http.Response?> startMeeting() async {
  Map<String, String> requestHeaders = {'Content-Type': 'application/json'};

  var userId = await loadUserId();

  var response = await client.post(
    Uri.parse('$MEETING_API_URL/start'),
    headers: requestHeaders,
    body: jsonEncode({'hostId': userId, 'hostName': ''}),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    return null;
  }
}

Future<http.Response?> joinMeeting(String meetingId) async {
  var response =
      await http.get(Uri.parse('$MEETING_API_URL/join?meetingId=$meetingId'));

  if (response.statusCode >= 200 && response.statusCode < 400) {
    return response;
  }

  throw UnsupportedError('Not a valid MeetingId');
}
