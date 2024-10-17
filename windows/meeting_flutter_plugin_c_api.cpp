#include "include/meeting_flutter/meeting_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "meeting_flutter_plugin.h"

void MeetingFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  meeting_flutter::MeetingFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
