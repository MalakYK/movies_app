import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../movies/data/models/movie_model.dart';

class HistoryRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  HistoryRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return firestore.collection('users').doc(uid).collection('history');
  }

  /// Reactive stream: automatically re-subscribes whenever the auth
  /// state changes (login / logout), instead of relying on the uid
  /// available at the moment this method was first called.
  Stream<List<MovieModel>> watchHistory() async* {
    await for (final user in auth.authStateChanges()) {
      if (user == null) {
        yield [];
      } else {
        final collection = firestore
            .collection('users')
            .doc(user.uid)
            .collection('history');

        yield* collection
            .orderBy('visitedAt', descending: true)
            .snapshots()
            .map(
              (snapshot) => snapshot.docs
              .map((doc) => MovieModel.fromJson(doc.data()))
              .toList(),
        );
      }
    }
  }

  Future<void> addToHistory(MovieModel movie) async {
    final collection = _collection;
    if (collection == null) return;

    await collection.doc(movie.id.toString()).set(
      {
        'id': movie.id,
        'title': movie.title,
        'title_long': movie.titleLong,
        'year': movie.year,
        'rating': movie.rating,
        'like_count': movie.likeCount,
        'medium_cover_image': movie.mediumCoverImage,
        'large_cover_image': movie.largeCoverImage,
        'background_image': movie.backgroundImage,
        'summary': movie.summary,
        'runtime': movie.runtime,
        'genres': movie.genres,
        'language': movie.language,
        'yt_trailer_code': movie.ytTrailerCode,
        'screenshots': movie.screenshots,
        'visitedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> remove(int movieId) async {
    final collection = _collection;
    if (collection == null) return;

    await collection.doc(movieId.toString()).delete();
  }

  Future<void> clear() async {
    final collection = _collection;
    if (collection == null) return;

    final snapshot = await collection.get();
    final batch = firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}