/// 规则源 — 完整的番剧源规则定义
///
/// 每个规则源描述了一个第三方番剧网站的四个接口：
///   search   — 搜索番剧
///   category — 分类/列表浏览
///   detail   — 番剧详情(剧集列表)
///   play     — 视频播放地址解析
///
/// 规则文件以 JSON 格式存放在 assets/rules/ 目录下。
import 'package:json_annotation/json_annotation.dart';

part 'rule_models.g.dart';

/// 数据提取规则
///
/// 支持三种提取方式：
/// - CSS选择器 (selector)
/// - 正则表达式 (regex)
/// - JSONPath (jsonPath)
@JsonSerializable()
class ExtractRule {
  /// CSS 选择器，如 `.anime-list > li`
  final String? selector;

  /// 正则表达式提取
  final String? regex;

  /// 字段映射：JSON key → 字段名
  final Map<String, String>? fieldMapping;

  /// 后处理: `text`, `attr:src`, `attr:href`, `html`
  final String? postProcess;

  const ExtractRule({
    this.selector,
    this.regex,
    this.fieldMapping,
    this.postProcess,
  });

  factory ExtractRule.fromJson(Map<String, dynamic> json) =>
      _$ExtractRuleFromJson(json);
  Map<String, dynamic> toJson() => _$ExtractRuleToJson(this);
}

/// 搜索接口配置
@JsonSerializable()
class SearchConfig {
  /// 请求路径模板，{keyword} 替换为搜索关键词
  final String path;

  /// HTTP 方法
  final String method;

  /// 列表项选择器
  final String listItemSelector;

  /// 字段提取规则
  final Map<String, ExtractRule> fields;

  const SearchConfig({
    required this.path,
    this.method = 'GET',
    required this.listItemSelector,
    required this.fields,
  });

  factory SearchConfig.fromJson(Map<String, dynamic> json) =>
      _$SearchConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SearchConfigToJson(this);
}

/// 分类列表接口配置
@JsonSerializable()
class CategoryConfig {
  /// 请求路径模板，{page} 替换为页码
  final String path;

  final String method;
  final String listItemSelector;
  final Map<String, ExtractRule> fields;

  const CategoryConfig({
    required this.path,
    this.method = 'GET',
    required this.listItemSelector,
    required this.fields,
  });

  factory CategoryConfig.fromJson(Map<String, dynamic> json) =>
      _$CategoryConfigFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryConfigToJson(this);
}

/// 详情接口配置
@JsonSerializable()
class DetailConfig {
  /// 请求路径模板，{id} 替换为番剧 ID
  final String path;

  final String method;

  /// 剧集列表项选择器
  final String episodeListSelector;

  /// 字段提取规则
  final Map<String, ExtractRule> fields;

  /// 番剧摘要选择器 (可选)
  final String? summarySelector;

  const DetailConfig({
    required this.path,
    this.method = 'GET',
    required this.episodeListSelector,
    required this.fields,
    this.summarySelector,
  });

  factory DetailConfig.fromJson(Map<String, dynamic> json) =>
      _$DetailConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DetailConfigToJson(this);
}

/// 播放地址解析配置
@JsonSerializable()
class PlayConfig {
  /// 请求路径模板，{id} 替换为剧集 ID
  final String path;

  final String method;

  /// 视频地址提取规则
  final ExtractRule videoUrl;

  /// 可选：需要先解析的中间页面
  final ExtractRule? iframeUrl;

  const PlayConfig({
    required this.path,
    this.method = 'GET',
    required this.videoUrl,
    this.iframeUrl,
  });

  factory PlayConfig.fromJson(Map<String, dynamic> json) =>
      _$PlayConfigFromJson(json);
  Map<String, dynamic> toJson() => _$PlayConfigToJson(this);
}

/// 完整规则源定义
@JsonSerializable()
class RuleSource {
  /// 源唯一标识
  final String id;

  /// 源名称
  final String name;

  /// 网站基础 URL
  final String baseUrl;

  /// 搜索配置
  final SearchConfig? search;

  /// 分类配置
  final List<RuleCategory>? categories;

  /// 详情配置
  final DetailConfig? detail;

  /// 播放地址配置
  final PlayConfig? play;

  /// 请求头 (User-Agent 等)
  final Map<String, String>? headers;

  const RuleSource({
    required this.id,
    required this.name,
    required this.baseUrl,
    this.search,
    this.categories,
    this.detail,
    this.play,
    this.headers,
  });

  factory RuleSource.fromJson(Map<String, dynamic> json) =>
      _$RuleSourceFromJson(json);
  Map<String, dynamic> toJson() => _$RuleSourceToJson(this);
}

/// 规则分类
@JsonSerializable()
class RuleCategory {
  final String id;
  final String name;
  final String path;

  const RuleCategory({
    required this.id,
    required this.name,
    required this.path,
  });

  factory RuleCategory.fromJson(Map<String, dynamic> json) =>
      _$RuleCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$RuleCategoryToJson(this);
}
