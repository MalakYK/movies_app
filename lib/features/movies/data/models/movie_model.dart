import 'package:equatable/equatable.dart';

class MovieModel extends Equatable {
  final int id;
  final String title;
  final String? titleLong;
  final String? year;
  final double rating;
  final String? mediumCoverImage;
  final String? largeCoverImage;
  final String? backgroundImage;
  final String? summary;
  final String? runtime;
  final List<String> genres;
  final String? language;
  final String? ytTrailerCode;

  const MovieModel({
    required this.id,
    required this.title,
    this.titleLong,
    this.year,
    this.rating = 0,
    this.mediumCoverImage,
    this.largeCoverImage,
    this.backgroundImage,
    this.summary,
    this.runtime,
    this.genres = const [],
    this.language,
    this.ytTrailerCode,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      titleLong: json['title_long'] as String?,
      year: json['year']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      mediumCoverImage: json['medium_cover_image'] as String?,
      largeCoverImage: json['large_cover_image'] as String?,
      backgroundImage: json['background_image'] as String?,
      summary: json['summary'] as String?,
      runtime: json['runtime']?.toString(),
      genres: (json['genres'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      language: json['language'] as String?,
      ytTrailerCode: json['yt_trailer_code'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, title, year, rating];
}
