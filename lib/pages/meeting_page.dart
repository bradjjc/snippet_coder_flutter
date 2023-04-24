import 'package:flutter/material.dart';
import 'package:youtube_webrtc/api/meeting_api.dart';
import 'package:youtube_webrtc/models/meeting_details.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_wrapper/flutter_webrtc_wrapper.dart';
import 'package:youtube_webrtc/pages/home_screen.dart';
import 'package:youtube_webrtc/widgets/control_panel.dart';
import 'package:youtube_webrtc/widgets/remote_connection.dart';

import '../utils/user.utils.dart';

class MeetingPage extends StatefulWidget {
  final String meetingId;
  final String name;
  final MeetingDetails meetingDetails;
  const MeetingPage(
      {Key? key,
      required this.meetingId,
      required this.name,
      required this.meetingDetails})
      : super(key: key);

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final _localRenderer = RTCVideoRenderer();
  final Map<String, dynamic> mediaConstraints = {"audio": true, "video": true};
  bool isConnectionFailed = false;
  WebRTCMeetingHelper? meetingHelper;
  String urlHost = "http://localhost:4000";

  @override
  void initState() {
    super.initState();
    initRenderers();
    startMeeting();
  }

  void startMeeting() async {
    final String userId = await loadUserId();
    print("urlHost: $urlHost");
    meetingHelper = WebRTCMeetingHelper(
      // url: urlHost,
      // url: "stun:stun.l.google.com:19302",
      url: baseUrl,
      meetingId: widget.meetingDetails.id,
      userId: userId,
      name: widget.name,
    );

    MediaStream _localStrim =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localRenderer.srcObject = _localStrim;
    meetingHelper!.stream = _localStrim;

    print("????????");
    print("???????? length ${meetingHelper!.connections.length}");

    meetingHelper!.on(
      'open',
      context,
      (ev, context) {
        print("meetingHelper!.on: open");
        setState(() {
          isConnectionFailed = false;
        });
      },
    );

    print("???????? open");

    meetingHelper!.on(
      'connection',
      context,
      (ev, context) {
        print("meetingHelper!.on: connection");
        setState(() {
          isConnectionFailed = false;
        });
      },
    );

    print("???????? connection");

    meetingHelper!.on(
      'user-left',
      context,
      (ev, context) {
        print("meetingHelper!.on: user-left");
        // popUp 참여자가 나갔을때
        setState(() {
          isConnectionFailed = false;
        });
      },
    );

    print("???????? user-left");

    meetingHelper!.on(
      'video-toggle',
      context,
      (ev, context) {
        print("meetingHelper!.on: video-toggle");
        setState(() {});
      },
    );

    print("???????? video-toggle");

    meetingHelper!.on(
      'audio-toggle',
      context,
      (ev, context) {
        print("meetingHelper!.on: audio-toggle");
        setState(() {});
      },
    );

    print("???????? audio-toggle");

    meetingHelper!.on(
      'meeting-ended',
      context,
      (ev, context) {
        print("meetingHelper!.on: meeting-ended");
        onMeetingEnd();
      },
    );

    meetingHelper!.on(
      'connection-setting-changed',
      context,
      (ev, context) {
        print("meetingHelper!.on: connection-setting-change");
        setState(() {
          isConnectionFailed = false;
        });
      },
    );

    meetingHelper!.on(
      'stream-changed',
      context,
      (ev, context) {
        print("meetingHelper!.on: stream-changed");
        setState(() {
          isConnectionFailed = false;
        });
      },
    );

    setState(() {});
    print("???????? end");
  }

  initRenderers() async {
    await _localRenderer.initialize();
  }

  void onMeetingEnd() {
    if (meetingHelper != null) {
      meetingHelper!.endMeeting();
      meetingHelper = null;
      goToHomePage();
    }
  }

  void goToHomePage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  void onAudioToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleAudio();
      });
    }
  }

  void onVideoToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleVideo();
      });
    }
  }

  void handleReconnect() {
    if (meetingHelper != null) {
      return meetingHelper!.reconnect();
    }
  }

  bool isAudioEnabled() {
    return meetingHelper != null ? meetingHelper!.audioEnabled! : false;
  }

  bool isVideoEnabled() {
    return meetingHelper != null ? meetingHelper!.videoEnabled! : false;
  }

  @override
  void deactivate() {
    super.deactivate();
    _localRenderer.dispose();
    if (meetingHelper != null) {
      meetingHelper!.destroy();
      meetingHelper = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: _buildMeetingRoom(),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        videoEnabled: isVideoEnabled(),
        audioEnabled: isAudioEnabled(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconnect,
        onMeetingEnd: onMeetingEnd,
      ),
    );
  }

  _buildMeetingRoom() {
    return Stack(
      children: [
        meetingHelper != null && meetingHelper!.connections.isNotEmpty
            ? GridView.count(
                crossAxisCount: meetingHelper!.connections.length < 3 ? 1 : 2,
                children:
                    List.generate(meetingHelper!.connections.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(1),
                    child: RemoteConnection(
                      renderer: meetingHelper!.connections[index].renderer,
                      connection: meetingHelper!.connections[index],
                    ),
                  );
                }),
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "참여자를 기다리고 있습니다.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
        Positioned(
          bottom: 10,
          right: 0,
          child: SizedBox(
            width: 150,
            height: 200,
            child: RTCVideoView(_localRenderer),
          ),
        ),
      ],
    );
  }
}
