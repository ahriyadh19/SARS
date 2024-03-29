import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' as database_firestore;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sars/Model/announcement.dart';
import 'package:sars/Model/ticket.dart';
import 'package:sars/Model/user.dart';
import 'package:uuid/uuid.dart';

class DatabaseFeatures {
  String? uidUser;
  String urlImage = '';

  final database_firestore.FirebaseFirestore _databaseCollection =
      database_firestore.FirebaseFirestore.instance;

  DatabaseFeatures({this.uidUser});

  Future createNewUserInfo(User u) async {
    return await _databaseCollection.collection('user').doc(uidUser).set({
      'fullname': u.name,
      'email': u.email!.trim(),
      'address': u.address,
      'role': 'r',
      'phonenumber': u.phone,
      'profilePictureURL':
          'https://firebasestorage.googleapis.com/v0/b/sars-e6e88.appspot.com/o/resident%2Fprofile%2Ficons8_users_500px.png?alt=media&token=8f0b847f-63a1-4463-9761-dcc93c5b7958',
      'gender': u.gander,
      'username': u.userName,
      'userID': uidUser
    });
  }

  Future<List<String>> uploadFiles(List<File> _attachmentsTicket) async {
    List<String> imageUrls = await Future.wait(
        _attachmentsTicket.map((_attachment) => uploadFile(_attachment, 0)));
    return imageUrls;
  }

  Future<String> uploadFile(File _attachment, int op) async {
    String shortenPath = _attachment.path.split('com.services.sars/cache')[1];
    dynamic storageReference;
    if (shortenPath.contains('.jpg')) {
      if (op == 0) {
        storageReference = FirebaseStorage.instance
            .ref()
            .child('/resident/images/$shortenPath');
      } else {
        storageReference = FirebaseStorage.instance
            .ref()
            .child('/resident/profile/$shortenPath');
      }
    } else {
      storageReference =
          FirebaseStorage.instance.ref().child('/resident/video/$shortenPath');
    }
    dynamic uploadTask = storageReference.putFile(_attachment);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future pushNewTicket(Ticket t) async {
    t.ticketID = const Uuid().v4().split('-').join();
    if (t.attachmentsImages.isNotEmpty) {
      t.attachmentsImagesUrlData = await uploadFiles(t.attachmentsImages);
    }
    if (t.attachmentVideo != null) {
      t.videoURL = await uploadFile(t.attachmentVideo!, 0);
    }
    return await _databaseCollection.collection('ticket').doc(t.ticketID).set({
      'ticketID': t.ticketID,
      'dateTime': database_firestore.Timestamp.fromDate(t.dateTime),
      'description': t.description,
      'typeOfTicket': t.type,
      'status': '${t.status}',
      'location': t.location,
      'attachmentImages': t.attachmentsImagesUrlData,
      'attachmentvideo': t.videoURL,
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
            attachmentsImagesUrlData:
                List<String>.from(data.doc['attachmentImages']),
            dateTime: DateTime.parse(data.doc['dateTime'].toDate().toString()),
            description: data.doc['description'] ?? '',
            ticketID: data.doc['ticketID'],
            feeddback: data.doc['feedback'],
            location: data.doc['location'] ?? '',
            rate: data.doc['rate'],
            status: int.parse(data.doc['status']),
            type: data.doc['typeOfTicket'] ?? '',
            attachmentsImages: [],
            userName: data.doc['userName'] ?? '',
            userId: data.doc['userID'] ?? '',
            remark: data.doc['remark'] ?? '',
            videoURL: data.doc['attachmentvideo'] ?? '',
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

  Future<User> getTarget(String id) async {
    return await _databaseCollection
        .collection('user')
        .doc(id)
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
            userName: mapingData['username'] ?? '',
            uid: mapingData['userID'] ?? '');
      }
      return User();
    });
  }

  Future editTicketPrivacy(String idTicket, String val) async {
    return await _databaseCollection
        .collection('ticket')
        .doc(idTicket)
        .update({'privacy': val});
  }

  Future cancelTicket(String idTicket, String val) async {
    return await _databaseCollection
        .collection('ticket')
        .doc(idTicket)
        .update({'status': '${4}', 'remark': val});
  }

  Future updateRateAndFeedback(
      {required String? idTicket, String? feedback, int? rate}) async {
    return await _databaseCollection
        .collection('ticket')
        .doc(idTicket)
        .update({'rate': rate, 'feedback': feedback});
  }

  Future updateUserNameForUser(String newVal) async {
    return await _databaseCollection
        .collection('user')
        .doc(uidUser)
        .update({'fullname': newVal});
  }

  Future updateUserName(String newVal) async {
    await updateUserNameForUser(newVal);
    _databaseCollection.collection('ticket').get().then(
      (value) {
        for (int i = 0; i < value.docs.length; i++) {
          if (value.docs.elementAt(i).data()['userID'].toString() == uidUser) {
            updateUserNameForTicket(value.docs.elementAt(i).id, newVal);
          }
        }
      },
    );
  }

  Future updateUserNameForTicket(String tickitIDt, String newVal) async {
    return await _databaseCollection
        .collection('ticket')
        .doc(tickitIDt)
        .update({'userName': newVal});
  }

  Future updateUserPhone(String newVal) async {
    return await _databaseCollection
        .collection('user')
        .doc(uidUser)
        .update({'phonenumber': newVal});
  }

  Future updateUserAddress(String newVal) async {
    return await _databaseCollection
        .collection('user')
        .doc(uidUser)
        .update({'address': newVal});
  }

  updateUserIMageProfile(File image) async {
    urlImage = await uploadFile(image, 1);
    return await _databaseCollection
        .collection('user')
        .doc(uidUser)
        .update({'profilePictureURL': urlImage});
  }

  updateUserEmail(String newVal) async {
    return await _databaseCollection
        .collection('user')
        .doc(uidUser)
        .update({'email': newVal});
  }

  getURlImage() {
    return urlImage;
  }
}
