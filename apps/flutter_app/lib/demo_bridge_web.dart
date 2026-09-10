import 'dart:js_interop';

@JS('memediaRegisterDemo')
external void _register(JSFunction handler);
@JS('memediaDemoStatus')
external void _status(JSString value);
void registerDemo(void Function(String) handler) {
  if (Uri.base.queryParameters['demo'] == '1') {
    _register(((JSString action) => handler(action.toDart)).toJS);
  }
}

void demoStatus(String value) {
  if (Uri.base.queryParameters['demo'] == '1') _status(value.toJS);
}
