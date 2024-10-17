//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <meeting_flutter/meeting_flutter_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) meeting_flutter_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "MeetingFlutterPlugin");
  meeting_flutter_plugin_register_with_registrar(meeting_flutter_registrar);
}
