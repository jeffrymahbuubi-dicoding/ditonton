import 'package:core/utils/routes.dart';
import 'package:material_ui/material_ui.dart';

class AppDrawer extends StatelessWidget {
  static const moviesRoute = homeMoviesRoute;

  const AppDrawer({required this.currentRoute, super.key});

  final String currentRoute;

  void _open(BuildContext context, String route) {
    if (route == currentRoute) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundImage: const AssetImage(
                'assets/circle-g.png',
                package: 'core',
              ),
              backgroundColor: Colors.grey.shade900,
            ),
            accountName: const Text('Ditonton'),
            accountEmail: const Text('ditonton@dicoding.com'),
            decoration: BoxDecoration(color: Colors.grey.shade900),
          ),
          ListTile(
            key: const Key('movies_drawer_item'),
            leading: const Icon(Icons.movie),
            title: const Text('Movies'),
            onTap: () => _open(context, moviesRoute),
          ),
          ListTile(
            key: const Key('tv_series_drawer_item'),
            leading: const Icon(Icons.tv),
            title: const Text('TV Series'),
            onTap: () => _open(context, homeTvSeriesRoute),
          ),
          ListTile(
            key: const Key('watchlist_drawer_item'),
            leading: const Icon(Icons.save_alt),
            title: const Text('Watchlist'),
            onTap: () {
              Navigator.pushNamed(context, watchlistRoute);
            },
          ),
          ListTile(
            key: const Key('about_drawer_item'),
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pushNamed(context, aboutRoute);
            },
          ),
        ],
      ),
    );
  }
}
