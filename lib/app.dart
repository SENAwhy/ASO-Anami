import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/browse/browse_page.dart';
import 'features/search/search_page.dart';
import 'features/detail/detail_page.dart';
import 'features/player/player_page.dart';
import 'shared/theme.dart';

class AnamiApp extends StatelessWidget {
  const AnamiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anami',
      debugShowCheckedModeBanner: false,
      theme: AnamiTheme.light,
      darkTheme: AnamiTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const BrowsePage(),
        );

      case '/search':
        return MaterialPageRoute(
          builder: (_) => const SearchPage(),
        );

      case '/detail':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DetailPage(
            animeId: args['animeId'] as String,
            sourceId: args['sourceId'] as String,
            title: args['title'] as String,
          ),
        );

      case '/player':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PlayerPage(
            videoUrl: args['videoUrl'] as String,
            title: args['title'] as String,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const BrowsePage(),
        );
    }
  }
}
