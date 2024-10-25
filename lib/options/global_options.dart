import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'livekit_demo_options.dart';

class GlobalOptions {
  final bool autoConnect;
  final LivekitDemoOptions? options;
  GlobalOptions({
    this.autoConnect = false,
    this.options,
  });

  GlobalOptions copyWith({
    bool? autoConnect,
    ValueGetter<LivekitDemoOptions?>? options,
  }) {
    return GlobalOptions(
      autoConnect: autoConnect ?? this.autoConnect,
      options: options != null ? options() : this.options,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autoConnect': autoConnect,
      'options': options?.toMap(),
    };
  }

  factory GlobalOptions.fromMap(Map<String, dynamic> map) {
    return GlobalOptions(
      autoConnect: map['autoConnect'] ?? false,
      options: map['options'] != null
          ? LivekitDemoOptions.fromMap(map['options'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GlobalOptions.fromJson(String source) =>
      GlobalOptions.fromMap(json.decode(source));

  @override
  String toString() =>
      'GlobalOptions(autoConnect: $autoConnect, options: $options)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GlobalOptions &&
        other.autoConnect == autoConnect &&
        other.options == options;
  }

  @override
  int get hashCode => autoConnect.hashCode ^ options.hashCode;
}
