import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../movies/data/models/movie_model.dart';

class FavoritesRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FavoritesRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return firestore.collection('users').doc(uid).collection('favorites');
  }

  Stream<List<MovieModel>> watchFavorites() async* {
    await for (final user in auth.authStateChanges()) {
      if (user == null) {
        yield [];
      } else {
        final collection = firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites');
        yield* collection
            .orderBy('addedAt', descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return MovieModel.fromJson({
              'id': data['id'],
              'title': data['title'] ?? '',
              'title_long': data['title_long'],
              'year': data['year']?.toString(),
              'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
              'like_count': data['like_count'] ?? 0,
              'medium_cover_image': data['medium_cover_image'],
              'large_cover_image': data['large_cover_image'],
              'background_image': data['background_image'],
              'summary': data['summary'],
              'runtime': data['runtime'],
              'genres': List<String>.from(data['genres'] ?? []),
              'language': data['language'],
              'yt_trailer_code': data['yt_trailer_code'],
              'screenshots': List<String>.from(data['screenshots'] ?? []),
            });
          }).toList();
        });
      }
    }
  }

  Future<void> add(MovieModel movie) async {
    final collection = _collection;
    if (collection == null) return;

    await collection.doc(movie.id.toString()).set({
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
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> remove(int movieId) async {
    final collection = _collection;
    if (collection == null) return;

    await collection.doc(movieId.toString()).delete();
  }

  Future<bool> isFavorite(int movieId) async {
    final collection = _collection;
    if (collection == null) return false;

    final doc = await collection.doc(movieId.toString()).get();
    return doc.exists;
  }
}