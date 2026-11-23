import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class SslPinning {
  const SslPinning._();

  static Future<http.Client> createClient({
    String assetPath = 'certificates/certificates.pem',
    AssetBundle? bundle,
  }) async {
    final data = await (bundle ?? rootBundle).load(assetPath);
    final context = SecurityContext(withTrustedRoots: false)
      ..setTrustedCertificatesBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    return IOClient(HttpClient(context: context));
  }
}
