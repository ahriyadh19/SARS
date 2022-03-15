import 'dart:io';

class Ticket {
  String? userName;
  String? remark = '';
  String? privacy = 'Private';
  String? videoURL;
  String userId;
  String type;
  String description;
  String location;
  String feeddback = '';
  int status = 0;
  int rate = 0;
  DateTime dateTime;
  List<File> attachmentsImages = [];
  List<String> attachmentsImagesUrlData = [];
  File? attachmentVideo;

  Ticket({
    required this.userId,
    required this.dateTime,
    required this.status,
    required this.type,
    required this.description,
    required this.location,
    required this.attachmentsImages,
    required this.attachmentsImagesUrlData,
    required this.feeddback,
    required this.rate,
    this.remark,
    this.privacy,
    this.userName,
    this.attachmentVideo,
    this.videoURL,
  });
  
  @override
  String toString() {
    return 'Ticket(userName: $userName, remark: $remark, privacy: $privacy, videoURL: $videoURL, userId: $userId, type: $type, description: $description, location: $location, feeddback: $feeddback, status: $status, rate: $rate, dateTime: $dateTime, attachmentsImages: $attachmentsImages, attachmentsImagesUrlData: $attachmentsImagesUrlData, attachmentVideo: $attachmentVideo)';
  }
}
