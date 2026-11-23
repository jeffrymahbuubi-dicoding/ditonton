import 'package:core/core.dart';
import 'package:ditonton/app.dart';
import 'package:ditonton/injection.dart' as di;
import 'package:ditonton/monitoring/monitoring.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Monitoring.init();
  final client = await SslPinning.createClient();
  di.init(client: client);
  runApp(
    MyApp(navigatorObservers: [routeObserver, Monitoring.analyticsObserver()]),
  );
}
