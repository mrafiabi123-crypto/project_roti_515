import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

/// Actual implementation for Flutter Web.
void registerWebIframe() {
  ui_web.platformViewRegistry.registerViewFactory(
    'google-maps-embed',
    (int viewId) => web.HTMLIFrameElement()
      ..src = 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d15819.489127411204!2d112.0491274!3d-7.5879815!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x2e78462b01f05971%3A0x3e097356de4244fa!2sKemlokelogi!5e0!3m2!1sid!2sid!4v1713113959000!5m2!1sid!2sid'
      ..style.border = 'none'
      ..style.borderRadius = '32px'
      ..width = '100%'
      ..height = '100%',
  );
}
