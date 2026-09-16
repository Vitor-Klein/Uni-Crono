import 'dart:convert';

class PushMessage {
  const PushMessage({
    required this.title,
    required this.body,
    required this.link,
    required this.imageUrl,
    required this.timestamp,
    this.read = false,
  });

  final String title;
  final String body;
  final String link;
  final String imageUrl;
  final DateTime timestamp;
  final bool read;

  bool get hasContent => title.isNotEmpty || body.isNotEmpty || link.isNotEmpty;

  PushMessage copyWith({bool? read}) {
    return PushMessage(
      title: title,
      body: body,
      link: link,
      imageUrl: imageUrl,
      timestamp: timestamp,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'link': link,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
    };
  }

  String encode() => jsonEncode(toJson());

  factory PushMessage.fromJson(Map<String, dynamic> json) {
    return PushMessage(
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      link: (json['link'] as String?) ?? '',
      imageUrl: (json['imageUrl'] as String?) ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      // Messages persisted before this field existed have no 'read' key —
      // they count as already read, so updating the app doesn't
      // flood the inbox with false "unread" messages.
      read: (json['read'] as bool?) ?? true,
    );
  }

  factory PushMessage.fromEncoded(String encoded) {
    return PushMessage.fromJson(jsonDecode(encoded) as Map<String, dynamic>);
  }
}
