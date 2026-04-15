// Using conditional exports to avoid importing web-only libraries on mobile.
export 'web_loader_stub.dart'
    if (dart.library.js_interop) 'web_loader_web.dart'
    if (dart.library.html) 'web_loader_web.dart';
