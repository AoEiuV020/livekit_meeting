#ifndef FLUTTER_PLUGIN_MEETING_FLUTTER_PLUGIN_H_
#define FLUTTER_PLUGIN_MEETING_FLUTTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace meeting_flutter {

class MeetingFlutterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  MeetingFlutterPlugin();

  virtual ~MeetingFlutterPlugin();

  // Disallow copy and assign.
  MeetingFlutterPlugin(const MeetingFlutterPlugin&) = delete;
  MeetingFlutterPlugin& operator=(const MeetingFlutterPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace meeting_flutter

#endif  // FLUTTER_PLUGIN_MEETING_FLUTTER_PLUGIN_H_
