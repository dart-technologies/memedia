import 'dart:js_interop';

@JS('localStorage.getItem')
external JSString? _read(JSString key);
@JS('localStorage.setItem')
external void _save(JSString key, JSString value);
String? readPreferences() {
  try {
    return _read('memedia.explorer.v2'.toJS)?.toDart;
  } catch (_) {
    return null;
  }
}

void savePreferences(String value) {
  try {
    _save('memedia.explorer.v2'.toJS, value.toJS);
  } catch (_) {}
}
