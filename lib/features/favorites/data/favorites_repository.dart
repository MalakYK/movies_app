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

  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User is not signed in.');
    }
    return firestore.collection('users').doc(uid).collection('favorites');
  }

  Stream<List<MovieModel>> watchFavorites() {
    return _collection.orderBy('addedAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => MovieModel.fromJson(doc.data()))
          .toList(),
    );
  }

  Future<void> add(MovieModel movie) {
    return _collection.doc(movie.id.toString()).set({
      'id': movie.id,
      'title': movie.title,
      'title_long': movie.titleLong,
      'year': movie.year,
      'rating': movie.rating,
      'medium_cover_image': movie.mediumCoverImage,
      'large_cover_image': movie.largeCoverImage,
      'background_image': movie.backgroundImage,
      'summary': movie.summary,
      'runtime': movie.runtime,
      'genres': movie.genres,
      'language': movie.language,
      'yt_trailer_code': movie.ytTrailerCode,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> remove(int movieId) {
    return _collection.doc(movieId.toString()).delete();
  }

  Future<bool> isFavorite(int movieId) async {
    final doc = await _collection.doc(movieId.toString()).get();
    return doc.exists;
  }
}
