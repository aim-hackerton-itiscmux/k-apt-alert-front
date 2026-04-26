import 'announcement.dart';

class AnnouncementsResponse {
  const AnnouncementsResponse({
    required this.count,
    required this.announcements,
    this.errors,
    this.dataAgeSeconds,
    this.fetchedAt,
  });

  final int count;
  final List<Announcement> announcements;
  final List<String>? errors;
  final int? dataAgeSeconds;
  final String? fetchedAt;

  factory AnnouncementsResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json['announcements'] as List?) ?? const [];
    final items = raw
        .whereType<Map>()
        .map((e) => Announcement.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);

    final errorsValue = json['errors'];
    List<String>? errors;
    if (errorsValue is List) {
      errors = errorsValue.map((e) => e.toString()).toList();
    } else if (errorsValue is String && errorsValue.isNotEmpty) {
      errors = [errorsValue];
    }

    int? ageSeconds;
    final ageRaw = json['data_age_seconds'];
    if (ageRaw is int) {
      ageSeconds = ageRaw;
    } else if (ageRaw is num) {
      ageSeconds = ageRaw.toInt();
    } else if (ageRaw is String) {
      ageSeconds = int.tryParse(ageRaw);
    }

    return AnnouncementsResponse(
      count: (json['count'] as num?)?.toInt() ?? items.length,
      announcements: items,
      errors: errors,
      dataAgeSeconds: ageSeconds,
      fetchedAt: json['fetched_at']?.toString(),
    );
  }
}
