class MeetingDetails {
  String? id;
  String? hostId;
  String? hostName;

  MeetingDetails({this.id, this.hostId, this.hostName});

  factory MeetingDetails.fromJson(dynamic json) {
    return MeetingDetails(
      id: json["id"],
      hostId: json["hostId"],
      hostName: json["hostName"],
    );
  }
}
