import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify_app_clone/data/models/song/song.dart';
import 'package:spotify_app_clone/domain/entities/song/song.dart';
import 'package:spotify_app_clone/domain/usecases/song/is_favorite_song.dart';

import '../../../service_locator.dart';

abstract class SongFirebaseService {
  Future<Either> getNewSongs();
  Future<Either> getPlayList();
  Future<Either> addOrRemoveFavoriteSongs(String songId);
  Future<bool> isFavoriteSong(String songId);
  Future<Either> getUserFavoriteSongs();
}

class SongFirebaseServiceImpl implements SongFirebaseService {
  @override
  Future<Either> getNewSongs() async {
    try {
      final fs = FirebaseFirestore.instance;
      final uid = FirebaseAuth.instance.currentUser?.uid;

      final List<QueryDocumentSnapshot<Map<String, dynamic>>> buckets = [];

      // Public
      final pub = await fs
          .collection('Songs')
          .where('isPublic', isEqualTo: true)
          .orderBy('releaseDate', descending: true)
          .limit(4)
          .get();
      buckets.addAll(pub.docs);

      // My private (optional top-up)
      if (uid != null) {
        final priv = await fs
            .collection('Songs')
            .where('isPublic', isEqualTo: false)
            .where('ownerUid', isEqualTo: uid)
            .orderBy('releaseDate', descending: true)
            .limit(4) // safe, we’ll de-dupe & re-sort anyway
            .get();
        buckets.addAll(priv.docs);
      }

      // De-dupe by doc id, then map to entities
      final seen = <String>{};
      final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final d in buckets) {
        if (seen.add(d.id)) docs.add(d);
      }

      // Sort again by releaseDate desc (because we merged lists)
      docs.sort((a, b) {
        final ta =
            (a.data()['releaseDate'] as Timestamp?)?.toDate() ?? DateTime(0);
        final tb =
            (b.data()['releaseDate'] as Timestamp?)?.toDate() ?? DateTime(0);
        return tb.compareTo(ta);
      });

      final songs = <SongEntity>[];
      for (final d in docs.take(4)) {
        final data = d.data();
        final m = SongModel.fromJson(data);
        final fav = await sl<IsFavoriteSongUseCase>().call(params: d.id);
        m.isFavorite = fav;
        m.songId = d.id;
        songs.add(m.toEntity());
      }

      return Right(songs);
    } catch (e) {
      return Left("An error occurred, Please try again later.");
    }
  }

  @override
  Future<Either> getPlayList() async {
    try {
      final fs = FirebaseFirestore.instance;
      final uid = FirebaseAuth.instance.currentUser?.uid;

      final buckets = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

      final pub = await fs
          .collection('Songs')
          .where('isPublic', isEqualTo: true)
          .orderBy('releaseDate', descending: true)
          .get();
      buckets.addAll(pub.docs);

      if (uid != null) {
        final priv = await fs
            .collection('Songs')
            .where('isPublic', isEqualTo: false)
            .where('ownerUid', isEqualTo: uid)
            .orderBy('releaseDate', descending: true)
            .get();
        buckets.addAll(priv.docs);
      }

      // De-dupe by id
      final seen = <String>{};
      final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final d in buckets) {
        if (seen.add(d.id)) docs.add(d);
      }

      // Sort once after merge
      docs.sort((a, b) {
        final ta =
            (a.data()['releaseDate'] as Timestamp?)?.toDate() ?? DateTime(0);
        final tb =
            (b.data()['releaseDate'] as Timestamp?)?.toDate() ?? DateTime(0);
        return tb.compareTo(ta);
      });

      final songs = <SongEntity>[];
      for (final d in docs) {
        final data = d.data();
        final m = SongModel.fromJson(data);
        final fav = await sl<IsFavoriteSongUseCase>().call(params: d.id);
        m.isFavorite = fav;
        m.songId = d.id;
        songs.add(m.toEntity());
      }

      return Right(songs);
    } catch (e) {
      return Left("An error occurred, Please try again later.");
    }
  }

  @override
  Future<Either> addOrRemoveFavoriteSongs(String songId) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      late bool isFavorite;
      var user = firebaseAuth.currentUser;
      String uid = user!.uid;
      QuerySnapshot favoriteSongs = await firebaseFirestore
          .collection('Users')
          .doc(uid)
          .collection('Favorites')
          .where('songId', isEqualTo: songId)
          .get();

      if (favoriteSongs.docs.isNotEmpty) {
        await favoriteSongs.docs.first.reference.delete();
        isFavorite = false;
      } else {
        await firebaseFirestore
            .collection('Users')
            .doc(uid)
            .collection('Favorites')
            .add({'songId': songId, 'addedDate': Timestamp.now()});
        isFavorite = true;
      }
      return Right(isFavorite);
    } catch (e) {
      return Left("An error occurred, Please try again later.");
    }
  }

  @override
  Future<bool> isFavoriteSong(String songId) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      var user = firebaseAuth.currentUser;
      String uid = user!.uid;
      QuerySnapshot favoriteSongs = await firebaseFirestore
          .collection('Users')
          .doc(uid)
          .collection('Favorites')
          .where('songId', isEqualTo: songId)
          .get();

      if (favoriteSongs.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either> getUserFavoriteSongs() async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      var user = firebaseAuth.currentUser;
      List<SongEntity> favoriteSongs = [];
      String uid = user!.uid;
      QuerySnapshot favoritesSnapshot = await firebaseFirestore
          .collection('Users')
          .doc(uid)
          .collection('Favorites')
          .get();
      for (var element in favoritesSnapshot.docs) {
        String songId = element['songId'];
        var song = await firebaseFirestore
            .collection('Songs')
            .doc(songId)
            .get();
        SongModel songModel = SongModel.fromJson(song.data()!);
        songModel.isFavorite = true;
        songModel.songId = songId;
        favoriteSongs.add(songModel.toEntity());
      }
      return Right(favoriteSongs);
    } catch (e) {
      return Left("An error occurred");
    }
  }
}
