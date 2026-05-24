import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/rule_engine/anime_models.dart';
import '../providers.dart';

/// 番剧详情页 — 展示剧集列表
class DetailPage extends ConsumerWidget {
  final String animeId;
  final String sourceId;
  final String title;

  const DetailPage({
    super.key,
    required this.animeId,
    required this.sourceId,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(detailProvider(animeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('加载失败: $e', textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
        data: (detail) => _DetailContent(detail: detail),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final AnimeDetail detail;

  const _DetailContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 番剧信息区
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (detail.anime.coverUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  detail.anime.coverUrl,
                  width: 100,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 140,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child: const Icon(Icons.movie, size: 36),
                  ),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.anime.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (detail.summary != null &&
                      detail.summary!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      detail.summary!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 剧集列表标题
        Text(
          '剧集列表 (${detail.episodes.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        // 剧集列表
        ...detail.episodes.map(
          (ep) => Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: Text(ep.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _playEpisode(context, ep, detail.anime.title);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _playEpisode(
      BuildContext context, EpisodeItem episode, String animeTitle) {
    Navigator.pushNamed(context, '/player', arguments: {
      'episodeId': episode.playId,
      'title': '${animeTitle} - ${episode.title}',
    });
  }
}
