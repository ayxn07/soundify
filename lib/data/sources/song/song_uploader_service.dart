import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class SongUploaderService {
  Future<String> uploadSongAndCreateDoc({
    required String localAudioPath,
    required String title,
    required String artist,
    required num durationSeconds,
    required DateTime releaseDate,
    String? localCoverPath,
    required bool isPublic,
  });
}

class SongUploaderServiceImpl implements SongUploaderService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<String> uploadSongAndCreateDoc({
    required String localAudioPath,
    required String title,
    required String artist,
    required num durationSeconds,
    required DateTime releaseDate,
    String? localCoverPath,
    required bool isPublic,
  }) async {
    final uid = _auth.currentUser!.uid;
    final fileName = '$artist - $title';
    final audioPath = isPublic
        ? 'songs/$fileName.mp3'
        : 'userContent/$uid/songs/$fileName.mp3';
    final coverPath = isPublic
        ? 'covers/$fileName.jpg'
        : 'userContent/$uid/covers/$fileName.jpg';

    //upload Audio
    await _storage.ref(audioPath).putFile(File(localAudioPath));

    //upload cover
    String? storedCover;
    if (localCoverPath != null) {
      await _storage.ref(coverPath).putFile(File(localCoverPath));
      storedCover = coverPath;
    }

    //create Firestore doc
    final doc = await _firestore.collection('Songs').add({
      'title': title,
      'artist': artist,
      'duration': durationSeconds,
      'releaseDate': Timestamp.fromDate(releaseDate),
      'ownerUid': uid,
      'isPublic': isPublic,
      'storageAudioPath': audioPath,
      'storageCoverPath': storedCover,
    });
    return doc.id;
  }
}
