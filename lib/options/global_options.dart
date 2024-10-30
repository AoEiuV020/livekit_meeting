import 'flag_options.dart';
import 'livekit_demo_options.dart';

class GlobalOptions {
  final FlagOptions flagOptions;
  final bool autoConnect;
  final LivekitDemoOptions? livekitDemoOptions;
  GlobalOptions({
    required this.flagOptions,
    this.autoConnect = false,
    this.livekitDemoOptions,
  });
}
