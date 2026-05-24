import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rule_models.dart';

/// 规则引擎状态
class RuleEngineState {
  /// 已加载的规则源列表
  final List<RuleSource> sources;

  /// 当前选中的源 ID
  final String? activeSourceId;

  /// 加载状态
  final bool isLoading;

  /// 错误信息
  final String? error;

  const RuleEngineState({
    this.sources = const [],
    this.activeSourceId,
    this.isLoading = false,
    this.error,
  });

  RuleEngineState copyWith({
    List<RuleSource>? sources,
    String? activeSourceId,
    bool? isLoading,
    String? error,
  }) {
    return RuleEngineState(
      sources: sources ?? this.sources,
      activeSourceId: activeSourceId ?? this.activeSourceId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 获取当前活跃的规则源
  RuleSource? get activeSource {
    if (activeSourceId == null) return null;
    try {
      return sources.firstWhere((s) => s.id == activeSourceId);
    } catch (_) {
      return sources.isNotEmpty ? sources.first : null;
    }
  }
}

/// 规则引擎 Notifier
class RuleEngineNotifier extends StateNotifier<RuleEngineState> {
  RuleEngineNotifier() : super(const RuleEngineState());

  /// 从 assets/rules/ 加载所有规则文件
  Future<void> loadRules() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 读取规则索引文件，获取所有规则文件列表
      final indexContent =
          await rootBundle.loadString('assets/rules/index.json');
      final index = json.decode(indexContent) as Map<String, dynamic>;
      final fileNames =
          (index['files'] as List<dynamic>).map((e) => e as String).toList();

      final List<RuleSource> sources = [];
      for (final fileName in fileNames) {
        try {
          final content =
              await rootBundle.loadString('assets/rules/$fileName');
          final jsonMap = json.decode(content) as Map<String, dynamic>;
          sources.add(RuleSource.fromJson(jsonMap));
        } catch (e) {
          // 跳过解析失败的规则文件
          continue;
        }
      }

      state = RuleEngineState(
        sources: sources,
        activeSourceId: sources.isNotEmpty ? sources.first.id : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '规则加载失败: $e',
      );
    }
  }

  /// 切换当前规则源
  void setActiveSource(String sourceId) {
    state = state.copyWith(activeSourceId: sourceId);
  }
}

/// Riverpod Provider
final ruleEngineProvider =
    StateNotifierProvider<RuleEngineNotifier, RuleEngineState>((ref) {
  final notifier = RuleEngineNotifier();
  // 初始化时加载规则
  Future.microtask(() => notifier.loadRules());
  return notifier;
});

/// 便捷 Provider — 获取当前活跃规则源
final activeRuleSourceProvider = Provider<RuleSource?>((ref) {
  return ref.watch(ruleEngineProvider).activeSource;
});
