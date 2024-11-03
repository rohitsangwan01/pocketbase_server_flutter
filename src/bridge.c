#include <stdlib.h>

// Define FlutterBridge as a function pointer type without nullability
// specifiers
typedef void (*FlutterBridge)(const char *command, const char *data);

// Declare the function pointer variable
FlutterBridge flutterBridge;

// Helper function to invoke the FlutterBridge callback
void callFlutterBridgeHelper(const char *command, const char *data) {
  if (flutterBridge != NULL) {
    flutterBridge(command, data);
  }
}