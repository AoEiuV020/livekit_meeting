import 'dart:convert';

import 'package:flutter/widgets.dart';

class LivekitDemoOptions {
  final String? serverUrl;
  final String? room;
  final String? name;
  LivekitDemoOptions({
    this.serverUrl,
    this.room,
    this.name,
  });

  LivekitDemoOptions copyWith({
    ValueGetter<String?>? serverUrl,
    ValueGetter<String?>? room,
    ValueGetter<String?>? name,
  }) {
    return LivekitDemoOptions(
      serverUrl: serverUrl != null ? serverUrl() : this.serverUrl,
      room: room != null ? room() : this.room,
      name: name != null ? name() : this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serverUrl': serverUrl,
      'room': room,
      'name': name,
    };
  }

  factory LivekitDemoOptions.fromMap(Map<String, dynamic> map) {
    return LivekitDemoOptions(
      serverUrl: map['serverUrl'],
      room: map['room'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory LivekitDemoOptions.fromJson(String source) =>
      LivekitDemoOptions.fromMap(json.decode(source));

  @override
  String toString() =>
      'LivekitDemoOptions(serverUrl: $serverUrl, room: $room, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LivekitDemoOptions &&
        other.serverUrl == serverUrl &&
        other.room == room &&
        other.name == name;
  }

  @override
  int get hashCode => serverUrl.hashCode ^ room.hashCode ^ name.hashCode;
}
