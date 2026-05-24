import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/rule_engine/anime_models.dart';
import '../providers.dart';

/// 搜索页
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  String _query = '';

  void _search() {
    setState(() {
      _query = _searchController.text.trim();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.isNotEmpty
        ? ref.watch(searchProvider(_query))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: const InputDecoration(
            hintText: '搜索番剧...',
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _search(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _search,
          ),
        ],
      ),
      body: _query.isEmpty
          ? const Center(
              child: Text('输入关键词搜索', style: TextStyle(color: Colors.grey)),
            )
          : results == null
              ? const Center(child: CircularProgressIndicator())
              : results.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('搜索失败: $e')),
                  data: (items) => items.isEmpty
                      ? const Center(child: Text('未找到相关番剧'))
                      : ListView.builder(
                          itemCount: items.length,
                          padding: const EdgeInsets.all(12),
                          itemBuilder: (context, index) {
                            return _SearchResultItem(item: items[index]);
                          },
                        ),
                ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final AnimeItem item;

  const _SearchResultItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: {
            'animeId': item.id,
            'sourceId': item.sourceId,
            'title': item.title,
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: item.coverUrl.isNotEmpty
                    ? Image.network(
                        item.coverUrl,
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 80,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Icon(Icons.movie, size: 24),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 80,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Icon(Icons.movie, size: 24),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.summary != null && item.summary!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.shortSummary,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
