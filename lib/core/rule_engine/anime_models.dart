// 番剧采集业务数据模型
//
// 这些是应用层数据结构，独立于规则定义层。
// 规则引擎将不同源站的 HTML/JSON 统一转换为这些模型。

/// 番剧摘要 (列表/搜索结果项)
class AnimeItem {
  final String id;
  final String title;
  final String coverUrl;
  final String sourceId;
  final String? summary;
  final String? latestEpisode;

  const AnimeItem({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.sourceId,
    this.summary,
    this.latestEpisode,
  });

  /// 缩写摘要
  String get shortSummary =>
      summary != null && summary!.length > 80
          ? '${summary!.substring(0, 80)}...'
          : summary ?? '';
}

/// 剧集项
class EpisodeItem {
  final String id;
  final String title;
  final String playId;

  const EpisodeItem({
    required this.id,
    required this.title,
    required this.playId,
  });
}

/// 番剧详情
class AnimeDetail {
  final AnimeItem anime;
  final String? summary;
  final List<EpisodeItem> episodes;

  const AnimeDetail({
    required this.anime,
    this.summary,
    required this.episodes,
  });
}

/// 分类 (来自规则源的分类定义)
class SourceCategory {
  final String id;
  final String name;

  const SourceCategory({required this.id, required this.name});
}
