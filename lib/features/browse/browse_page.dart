import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/rule_engine/anime_models.dart';
import '../../core/rule_engine/rule_loader.dart';
import '../providers.dart';

/// 首页 — 番剧浏览
class BrowsePage extends ConsumerWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ruleState = ref.watch(ruleEngineProvider);
    final source = ruleState.activeSource;
    final categories =
        source?.categories?.map((c) => SourceCategory(id: c.path, name: c.name)).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(source?.name ?? 'Anami'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: ruleState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ruleState.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(ruleState.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => ref.read(ruleEngineProvider.notifier).loadRules(),
                          child: const Text('重新加载'),
                        ),
                      ],
                    ),
                  ),
                )
              : categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inbox, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('暂无规则源'),
                          const SizedBox(height: 8),
                          Text('已加载 ${ruleState.sources.length} 个源',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => ref.read(ruleEngineProvider.notifier).loadRules(),
                            child: const Text('重新加载规则'),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        // 部分加载失败警告
                        if (ruleState.error != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            color: Colors.orange.shade100,
                            child: Text(ruleState.error!,
                              style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                            ),
                          ),
                        // 源切换区域
                        if (ruleState.sources.length > 1)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Wrap(
                              spacing: 8,
                              children: ruleState.sources.map((s) {
                                final isActive = s.id == source?.id;
                                return ChoiceChip(
                                  label: Text(s.name),
                                  selected: isActive,
                                  onSelected: (_) =>
                                      ref.read(ruleEngineProvider.notifier).setActiveSource(s.id),
                                );
                              }).toList(),
                            ),
                          ),
                        // 分类列表
                        ...categories.map(
                          (cat) => _CategorySection(
                            category: cat,
                          ),
                        ),
                      ],
                    ),
    );
  }
}

/// 单个分类区域
class _CategorySection extends ConsumerWidget {
  final SourceCategory category;

  const _CategorySection({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeList = ref.watch(browseListProvider(category.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            category.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 200,
          child: animeList.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Text('加载失败: $e',
                style: const TextStyle(color: Colors.red, fontSize: 11),
              ),
            ),
            data: (items) => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _AnimeCard(item: item);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// 番剧卡片
class _AnimeCard extends StatelessWidget {
  final AnimeItem item;

  const _AnimeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail', arguments: {
          'animeId': item.id,
          'sourceId': item.sourceId,
          'title': item.title,
        });
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.coverUrl.isNotEmpty
                  ? Image.network(
                      item.coverUrl,
                      width: 140,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 140,
                        height: 180,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Icon(Icons.movie, size: 40),
                      ),
                    )
                  : Container(
                      width: 140,
                      height: 180,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: const Icon(Icons.movie, size: 40),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
