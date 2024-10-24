import 'dart:convert';

import 'package:flutter/widgets.dart';

class LivekitDemoOptions {
  final String? serverUrl;
  final String? room;
  final String? name;
  final bool autoConnect;
  LivekitDemoOptions({
    this.serverUrl,
    this.room,
    this.name,
    this.autoConnect = false,
  });

  LivekitDemoOptions copyWith({
    ValueGetter<String?>? serverUrl,
    ValueGetter<String?>? room,
    ValueGetter<String?>? name,
    bool? autoConnect,
  }) {
    return LivekitDemoOptions(
      serverUrl: serverUrl != null ? serverUrl() : this.serverUrl,
      room: room != null ? room() : this.room,
      name: name != null ? name() : this.name,
      autoConnect: autoConnect ?? this.autoConnect,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serverUrl': serverUrl,
      'room': room,
      'name': name,
      'autoConnect': autoConnect,
    };
  }

  factory LivekitDemoOptions.fromMap(Map<String, dynamic> map) {
    return LivekitDemoOptions(
      serverUrl: map['serverUrl'],
      room: map['room'],
      name: map['name'],
      autoConnect: map['autoConnect'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory LivekitDemoOptions.fromJson(String source) =>
      LivekitDemoOptions.fromMap(json.decode(source));

  @override
  String toString() {
    return 'LivekitDemoOptions(serverUrl: $serverUrl, room: $room, name: $name, autoConnect: $autoConnect)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LivekitDemoOptions &&
        other.serverUrl == serverUrl &&
        other.room == room &&
        other.name == name &&
        other.autoConnect == autoConnect;
  }

  @override
  int get hashCode {
    return serverUrl.hashCode ^
        room.hashCode ^
        name.hashCode ^
        autoConnect.hashCode;
  }
}
