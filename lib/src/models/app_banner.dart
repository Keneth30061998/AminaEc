import 'dart:convert';

AppBanner appBannerFromJson(String source) {
  return AppBanner.fromJson(
    Map<String, dynamic>.from(json.decode(source)),
  );
}

String appBannerToJson(AppBanner banner) {
  return json.encode(banner.toJson());
}

bool _parseBool(dynamic value) {
  if (value == true || value == 1) return true;
  if (value == false || value == 0) return false;

  final normalized = value?.toString().trim().toLowerCase();

  return normalized == '1' || normalized == 'true';
}

String? _nullableString(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();

  return text.isEmpty ? null : text;
}

class AppBanner {
  final String? id;
  final String title;
  final String message;
  final String? linkText;
  final String? linkUrl;
  final bool isActive;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppBanner({
    this.id,
    required this.title,
    required this.message,
    this.linkText,
    this.linkUrl,
    required this.isActive,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory AppBanner.fromJson(Map<String, dynamic> json) {
    return AppBanner(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      linkText: _nullableString(
        json['link_text'] ?? json['linkText'],
      ),
      linkUrl: _nullableString(
        json['link_url'] ?? json['linkUrl'],
      ),
      isActive: _parseBool(
        json['is_active'] ?? json['isActive'],
      ),
      updatedBy: json['updated_by']?.toString(),
      createdAt: DateTime.tryParse(
        json['created_at']?.toString() ?? '',
      ),
      updatedAt: DateTime.tryParse(
        json['updated_at']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'link_text': linkText,
      'link_url': linkUrl,
      'is_active': isActive ? 1 : 0,
    };
  }

  bool get hasLink {
    final value = linkUrl?.trim() ?? '';
    return value.isNotEmpty;
  }
}