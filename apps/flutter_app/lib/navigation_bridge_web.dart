import 'dart:js_interop';

@JS('memediaRegisterRoute')
external void _register(JSFunction handler);
@JS('memediaWriteRoute')
external void _write(JSString url, JSBoolean push);
void registerRoute(void Function(String) handler) =>
    _register(((JSString url) => handler(url.toDart)).toJS);
void writeRoute(String url, bool push) => _write(url.toJS, push.toJS);
