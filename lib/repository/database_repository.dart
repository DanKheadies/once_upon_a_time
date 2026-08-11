// import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
import 'package:logger/web.dart';
import 'package:once_upon_a_time/barrel.dart';

class DatabaseRepository {
  final FirebaseFirestore _firebaseFirestore;
  // final http.Client _client;
  final Logger _log;

  DatabaseRepository({
    FirebaseFirestore? firebaseFirestore,
    // http.Client? client,
    Logger? logger,
  }) : // _client = client ?? http.Client(),
       _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance,
       _log = logger ?? Logger();

  /// (Firebase) Get a list of stories
  Future<List<Story>> getStories(bool? showArchived) async {
    List<Story> storiesList = [];

    try {
      late QuerySnapshot<Map<String, dynamic>> doc;
      if (showArchived!) {
        doc = await _firebaseFirestore.collection('stories').get();
      } else {
        doc = await _firebaseFirestore
            .collection('stories')
            .where('isArchived', isEqualTo: false)
            .get();
      }

      for (var snap in doc.docs) {
        storiesList.add(Story.fromSnapshot(snap));
      }
    } catch (err) {
      _log.e('getStories error', error: err);
    }
    return storiesList;
  }

  /// (Firebase) Update an area via id.
  Future<Story> createStory({required Story newStory}) async {
    DocumentReference docRef = await _firebaseFirestore
        .collection('stories')
        .add({});
    await _firebaseFirestore
        .collection('stories')
        .doc(docRef.id)
        .set(newStory.copyWith(id: docRef.id).toJson());
    return newStory.copyWith(id: docRef.id);
  }

  /// (Firebase) Update an area via id.
  Future<void> updateStory({required Story story}) async {
    return _firebaseFirestore
        .collection('stories')
        .doc(story.id)
        .update(story.toJson());
  }

  // /// (Firebase) Temp - Seed organizations collection
  // Future<void> uploadOrgs({
  //   required List<Organization> orgs,
  //   required String areaFirebaseName,
  // }) async {
  //   try {
  //     for (var org in orgs) {
  //       DocumentReference orgDocRef = await _firebaseFirestore
  //           .collection('${areaFirebaseName}Organizations')
  //           .add({});
  //       await _firebaseFirestore
  //           .collection('${areaFirebaseName}Organizations')
  //           .doc(orgDocRef.id)
  //           .set(org.copyWith(id: orgDocRef.id).toJson());
  //     }
  //   } catch (err) {
  //     _log.e('uploadOrgs error', error: err);
  //   }
  // }
}
