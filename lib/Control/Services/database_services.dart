import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' as database_firestore;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sars/Model/announcement.dart';
import 'package:sars/Model/ticket.dart';
import 'package:sars/Model/user.dart';

class DatabaseFeatures {
  String? uidUser;

  final database_firestore.FirebaseFirestore _databaseCollection =
      database_firestore.FirebaseFirestore.instance;

  DatabaseFeatures({this.uidUser});

  Future createNewUserInfo(User u) async {
    return await _databaseCollection.collection('user').doc(uidUser).set({
      'fullname': u.name,
      'email': u.email,
      'address': u.address,
      'role': 'r',
      'phonenumber': u.phone,
      'profilePictureURL':
          'https://firebasestorage.googleapis.com/v0/b/sars-e6e88.appspot.com/o/resident%2Fprofile%2Ficons8_users_500px.png?alt=media&token=8f0b847f-63a1-4463-9761-dcc93c5b7958',
      'gender': u.gander,
      'secret': u.secret,
      'username': u.userName,
      'userID': uidUser
    });
  }

  Future<List<String>> uploadFiles(List<File> _attachmentsTicket) async {
    List<String> imageUrls = await Future.wait(
        _attachmentsTicket.map((_attachment) => uploadFile(_attachment)));
    return imageUrls;
  }

  Future<String> uploadFile(File _attachment) async {
    String shortenPath = _attachment.path.split('com.services.sars/cache')[1];
    dynamic storageReference;
    if (shortenPath.contains('.jpg')) {
      storageReference =
          FirebaseStorage.instance.ref().child('/resident/images/$shortenPath');
    } else {
      storageReference =
          FirebaseStorage.instance.ref().child('/resident/video/$shortenPath');
    }
    dynamic uploadTask = storageReference.putFile(_attachment);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future pushNewTicket(Ticket t) async {
    if (t.attachmentsFiles.isNotEmpty) {
      t.attachmentsFilesUrlData = await uploadFiles(t.attachmentsFiles);
    }
    return await _databaseCollection.collection('ticket').doc().set({
      'dateTime': database_firestore.Timestamp.fromDate(t.dateTime),
      'description': t.description,
      'typeOfTicket': t.type,
      'status': t.status,
      'location': t.location,
      'attachments': t.attachmentsFilesUrlData,
      'feedback': t.feeddback,
      'rate': t.rate,
      'userID': uidUser,
      'userName': t.userName,
      'privacy': t.privacy,
      'remark': t.remark
    });
  }

  List<Announcement> announcementListData(
      database_firestore.QuerySnapshot snp) {
    return snp.docChanges.map((data) {
      return Announcement(
          dateTime: DateTime.tryParse(data.doc['date']) ?? DateTime.now(),
          contain: data.doc['description'] ?? '',
          title: data.doc['title'] ?? '');
    }).toList();
  }

  Stream<List<Announcement>> get announcementFromFirebase {
    return _databaseCollection
        .collection('announcement')
        .snapshots()
        .map(announcementListData);
  }

  List<Ticket> ticketListData(database_firestore.QuerySnapshot snp) {
    return snp.docChanges.map(
      (data) {
        return Ticket(
            attachmentsFilesUrlData: List<String>.from(data.doc['attachments']),
            dateTime: DateTime.parse(data.doc['dateTime'].toDate().toString()),
            description: data.doc['description'] ?? '',
            feeddback: data.doc['feedback'] ?? '',
            location: data.doc['location'] ?? '',
            rate: data.doc['rate'] ?? 0,
            status: data.doc['status'] ?? 0,
            type: data.doc['typeOfTicket'] ?? '',
            attachmentsFiles: [],
            userName: data.doc['userName'] ?? '',
            userId: data.doc['userID'] ?? '',
            privacy: data.doc['privacy'] ?? 'Private');
      },
    ).toList();
  }

  Stream<List<Ticket>> get ticketFromFirebase {
    return _databaseCollection
        .collection('ticket')
        .snapshots()
        .map(ticketListData);
  }

  Future<User> getTarget() async {
    return await _databaseCollection
        .collection('user')
        .doc(uidUser)
        .get()
        .then((database_firestore.DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map mapingData = Map.castFrom(documentSnapshot.data() as Map);
        return User(
            address: mapingData['address'] ?? '',
            name: mapingData['fullname'] ?? '',
            phone: mapingData['phonenumber'] ?? '',
            pictureUrl: mapingData['profilePictureURL'] ?? '',
            email: mapingData['email'] ?? '',
            role: mapingData['role'] ?? '',
            gander: mapingData['gender'] ?? '',
            secret: mapingData['secret'] ?? '',
            userName: mapingData['username'] ?? '',
            uid: mapingData['userID'] ?? '');
      }
      return User();
    });
  }
}
