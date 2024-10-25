import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'livekit_demo_options.dart';

class GlobalOptions {
  final bool autoConnect;
  final LivekitDemoOptions? livekitDemoOptions;
  GlobalOptions({
    this.autoConnect = false,
    this.livekitDemoOptions,
  });

  GlobalOptions copyWith({
    bool? autoConnect,
    ValueGetter<LivekitDemoOptions?>? livekitDemoOptions,
  }) {
    return GlobalOptions(
      autoConnect: autoConnect ?? this.autoConnect,
      livekitDemoOptions: livekitDemoOptions != null ? livekitDemoOptions() : this.livekitDemoOptions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autoConnect': autoConnect,
      'livekitDemoOptions': livekitDemoOptions?.toMap(),
    };
  }

  factory GlobalOptions.fromMap(Map<String, dynamic> map) {
    return GlobalOptions(
      autoConnect: map['autoConnect'] ?? false,
      livekitDemoOptions: map['livekitDemoOptions'] != null ? LivekitDemoOptions.fromMap(map['livekitDemoOptions']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GlobalOptions.fromJson(String source) =>
      GlobalOptions.fromMap(json.decode(source));

  @override
  String toString() => 'GlobalOptions(autoConnect: $autoConnect, livekitDemoOptions: $livekitDemoOptions)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GlobalOptions &&
        other.autoConnect == autoConnect &&
        other.livekitDemoOptions == livekitDemoOptions;
  }

  @override
  int get hashCode => autoConnect.hashCode ^ livekitDemoOptions.hashCode;
}
