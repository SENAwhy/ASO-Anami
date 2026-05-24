import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/http_client_service.dart';
import '../core/rule_engine/rule_executor.dart';
import '../core/rule_engine/anime_models.dart';
import '../core/rule_engine/rule_loader.dart';

/// HTTP 客户端 Provider (单例)
final httpClientProvider = Provider<HttpClientService>((ref) {
  return HttpClientService();
});

/// 规则执行器 Provider — 基于当前活跃规则源
final ruleExecutorProvider = Provider<RuleExecutor?>((ref) {
  final ruleSource = ref.watch(activeRuleSourceProvider);
  if (ruleSource == null) return null;

  final http = ref.watch(httpClientProvider);
  return RuleExecutor(ruleSource, http);
});

/// 首页分类/列表数据 Provider
final browseListProvider =
    FutureProvider.family<List<AnimeItem>, String>((ref, categoryPath) async {
  final executor = ref.watch(ruleExecutorProvider);
  if (executor == null) throw Exception('规则源未加载');

  return executor.fetchCategoryList(categoryPath, 1);
});

/// 搜索 Provider
final searchProvider =
    FutureProvider.family<List<AnimeItem>, String>((ref, keyword) async {
  if (keyword.trim().isEmpty) return [];

  final executor = ref.watch(ruleExecutorProvider);
  if (executor == null) throw Exception('规则源未加载');

  return executor.searchAnime(keyword);
});

/// 详情 Provider
final detailProvider =
    FutureProvider.family<AnimeDetail, String>((ref, animeId) async {
  final executor = ref.watch(ruleExecutorProvider);
  if (executor == null) throw Exception('规则源未加载');

  return executor.fetchDetail(animeId);
});

/// 播放地址 Provider
final playUrlProvider =
    FutureProvider.family<String, String>((ref, episodeId) async {
  final executor = ref.watch(ruleExecutorProvider);
  if (executor == null) throw Exception('规则源未加载');

  return executor.resolvePlayUrl(episodeId);
});
