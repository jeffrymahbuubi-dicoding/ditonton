import 'dart:convert';
import 'dart:io';

import 'package:core/utils/ssl_pinning.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';

class _MemoryBundle extends AssetBundle {
  _MemoryBundle(this.files);

  final Map<String, List<int>> files;

  @override
  Future<ByteData> load(String key) async {
    final bytes = files[key];
    if (bytes == null) {
      throw FlutterError('Unable to load asset: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

void main() {
  final pinnedPem = File('../certificates/certificates.pem').readAsBytesSync();

  group('SslPinning.createClient', () {
    test('builds an IOClient from the pinned certificate file', () async {
      final bundle = _MemoryBundle({
        'certificates/certificates.pem': pinnedPem,
      });

      final client = await SslPinning.createClient(bundle: bundle);

      expect(client, isA<IOClient>());
      client.close();
    });

    test('reads the asset named by assetPath', () async {
      final bundle = _MemoryBundle({'other/pinned.pem': pinnedPem});

      final client = await SslPinning.createClient(
        assetPath: 'other/pinned.pem',
        bundle: bundle,
      );

      expect(client, isA<IOClient>());
      client.close();
    });

    test('throws a TlsException when the file is not a certificate', () {
      final bundle = _MemoryBundle({
        'certificates/certificates.pem': utf8.encode('not a certificate'),
      });

      expect(
        SslPinning.createClient(bundle: bundle),
        throwsA(isA<TlsException>()),
      );
    });

    test('throws when the asset does not exist', () {
      final bundle = _MemoryBundle({});

      expect(
        SslPinning.createClient(bundle: bundle),
        throwsA(isA<FlutterError>()),
      );
    });
  });
}
