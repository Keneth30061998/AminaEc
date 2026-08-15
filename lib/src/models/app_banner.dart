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

double _parseSize(dynamic value) {
  final parsed = double.tryParse(value?.toString() ?? '');
  if (parsed == null || parsed < 18 || parsed > 48) return 30;
  return parsed;
}

class AppBanner {
  final String? id;
  final String title;
  final String message;
  final String? imageUrl;
  final String textColor; // white | black | gold | indigo
  final String textStyle; // strong | modern | elegant | condensed
  final double textSize;
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
    this.imageUrl,
    this.textColor = 'white',
    this.textStyle = 'strong',
    this.textSize = 30,
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
      imageUrl: _nullableString(json['image_url'] ?? json['imageUrl']),
      textColor: _nullableString(json['text_color'] ?? json['textColor']) ?? 'white',
      textStyle: _nullableString(json['text_style'] ?? json['textStyle']) ?? 'strong',
      textSize: _parseSize(json['text_size'] ?? json['textSize']),
      linkText: _nullableString(json['link_text'] ?? json['linkText']),
      linkUrl: _nullableString(json['link_url'] ?? json['linkUrl']),
      isActive: _parseBool(json['is_active'] ?? json['isActive']),
      updatedBy: json['updated_by']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'image_url': imageUrl,
      'text_color': textColor,
      'text_style': textStyle,
      'text_size': textSize.round(),
      'link_text': linkText,
      'link_url': linkUrl,
      'is_active': isActive ? 1 : 0,
    };
  }

  bool get hasLink => (linkUrl?.trim() ?? '').isNotEmpty;
  bool get hasImage => (imageUrl?.trim() ?? '').isNotEmpty;
}
