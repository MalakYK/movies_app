import 'package:equatable/equatable.dart';

class CastModel extends Equatable {
  final String? name;
  final String? characterName;
  final String? urlSmallImage;

  const CastModel({
    this.name,
    this.characterName,
    this.urlSmallImage,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      name: json['name'] as String?,
      characterName: json['character_name'] as String?,
      urlSmallImage: json['url_small_image'] as String?,
    );
  }

  @override
  List<Object?> get props => [name, characterName, urlSmallImage];
}

class MovieModel extends Equatable {
  final int id;
  final String title;
  final String? titleLong;
  final String? year;
  final double rating;
  final int likeCount;

  final String? mediumCoverImage;
  final String? largeCoverImage;
  final String? backgroundImage;

  final String? summary;
  final String? runtime;

  final List<String> genres;

  final String? language;
  final String? ytTrailerCode;

  final List<String> screenshots;
  final List<CastModel>? cast;

  const MovieModel({
    required this.id,
    required this.title,
    this.titleLong,
    this.year,
    this.rating = 0,
    this.likeCount = 0,
    this.mediumCoverImage,
    this.largeCoverImage,
    this.backgroundImage,
    this.summary,
    this.runtime,
    this.genres = const [],
    this.language,
    this.ytTrailerCode,
    this.screenshots = const [],
    this.cast,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final rawScreenshots = <String>[];
    final screenshotKeys = [
      'large_screenshot_image1',
      'large_screenshot_image2',
      'large_screenshot_image3',
    ];

    for (final key in screenshotKeys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        rawScreenshots.add(value);
      }
    }
    final screenshots = rawScreenshots.toSet().toList();
    final summaryText = (json['description_full'] as String?)?.trim().isNotEmpty == true
        ? json['description_full'] as String
        : (json['summary'] as String?)?.trim().isNotEmpty == true
        ? json['summary'] as String
        : json['synopsis'] as String?;

    return MovieModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      titleLong: json['title_long'] as String?,
      year: json['year']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      mediumCoverImage: json['medium_cover_image'] as String?,
      largeCoverImage: json['large_cover_image'] as String?,
      backgroundImage: json['background_image'] as String?,
      summary: summaryText,
      runtime: json['runtime']?.toString(),
      genres: (json['genres'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          const [],
      language: json['language'] as String?,
      ytTrailerCode: json['yt_trailer_code'] as String?,
      screenshots: screenshots,
      cast: json['cast'] != null
          ? (json['cast'] as List)
          .map((e) => CastModel.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    year,
    rating,
    likeCount,
    mediumCoverImage,
    largeCoverImage,
    backgroundImage,
    summary,
    runtime,
    genres,
    language,
    ytTrailerCode,
    screenshots,
    cast,
  ];
}