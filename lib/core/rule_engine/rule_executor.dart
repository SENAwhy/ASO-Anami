import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

import '../network/http_client_service.dart';
import 'rule_models.dart';
import 'anime_models.dart';

/// 数据提取器
///
/// 根据 ExtractRule 从 HTML 或 JSON 中提取字段值。
class DataExtractor {
  /// 从 HTML 元素中提取字段值
  static String? extractFromElement(dom.Element element, ExtractRule rule) {
    if (rule.selector != null) {
      // 在当前元素内查找子元素
      final subElement = element.querySelector(rule.selector!);
      return _applyPostProcess(subElement, rule.postProcess);
    }
    // 无选择器，直接处理当前元素
    return _applyPostProcess(element, rule.postProcess);
  }

  /// 从 JSON 对象中提取字段值
  static String? extractFromJson(
      Map<String, dynamic> jsonObj, ExtractRule rule) {
    if (rule.fieldMapping != null) {
      // fieldMapping: { "jsonKey": "fieldName" }
      // 返回第一个匹配到的值
      for (final entry in rule.fieldMapping!.entries) {
        if (jsonObj.containsKey(entry.key)) {
          return jsonObj[entry.key]?.toString();
        }
      }
    }
    return null;
  }

  /// 后处理：text / attr:xxx / html
  static String? _applyPostProcess(dom.Element? element, String? postProcess) {
    if (element == null) return null;

    if (postProcess == null || postProcess == 'text') {
      return element.text.trim();
    }

    if (postProcess.startsWith('attr:')) {
      final attrName = postProcess.substring(5);
      return element.attributes[attrName]?.trim();
    }

    if (postProcess == 'html') {
      return element.innerHtml.trim();
    }

    return element.text.trim();
  }
}

/// 规则执行器
///
/// 根据规则源配置执行 HTTP 请求并提取数据，
/// 返回统一的 AnimeItem / EpisodeItem 等模型。
class RuleExecutor {
  final RuleSource _source;
  final HttpClientService _http;

  RuleExecutor(this._source, this._http);

  /// 搜索番剧
  ///
  /// 返回 AnimeItem 列表。
  Future<List<AnimeItem>> searchAnime(String keyword) async {
    if (_source.search == null) {
      throw Exception('${_source.name}: 未配置搜索接口');
    }

    final config = _source.search!;
    final url = _resolveUrl(
      config.path.replaceAll('{keyword}', Uri.encodeComponent(keyword)),
    );

    final html = await _http.getString(url, headers: _source.headers);
    final document = parse(html);
    final items = document.querySelectorAll(config.listItemSelector);

    final results = <AnimeItem>[];

    for (final element in items) {
      final id = DataExtractor.extractFromElement(
              element, config.fields['id'] ?? config.fields['detailUrl']!) ??
          '';
      final title = DataExtractor.extractFromElement(
              element, config.fields['title'] ?? config.fields['title']!) ??
          '';
      final coverUrl = DataExtractor.extractFromElement(
              element, config.fields['cover'] ?? config.fields['coverUrl']!) ??
          '';

      if (title.isNotEmpty && id.isNotEmpty) {
        results.add(AnimeItem(
          id: id,
          title: title,
          coverUrl: _ensureAbsoluteUrl(coverUrl),
          sourceId: _source.id,
        ));
      }
    }

    return results;
  }

  /// 获取分类列表
  ///
  /// 传入分类名和页码，返回 AnimeItem 列表。
  Future<List<AnimeItem>> fetchCategoryList(
      String categoryPath, int page) async {
    final config = _source.search; // 复用搜索配置
    if (config == null) {
      throw Exception('${_source.name}: 未配置列表接口');
    }

    final path = categoryPath.replaceAll('{page}', page.toString());
    final url = _resolveUrl(path);

    final html = await _http.getString(url, headers: _source.headers);
    final document = parse(html);
    final items = document.querySelectorAll(config.listItemSelector);

    final results = <AnimeItem>[];

    for (final element in items) {
      final id = DataExtractor.extractFromElement(
              element, config.fields['id'] ?? config.fields['detailUrl']!) ??
          '';
      final title = DataExtractor.extractFromElement(
              element, config.fields['title'] ?? config.fields['title']!) ??
          '';
      final coverUrl = DataExtractor.extractFromElement(
              element, config.fields['cover'] ?? config.fields['coverUrl']!) ??
          '';

      if (title.isNotEmpty && id.isNotEmpty) {
        results.add(AnimeItem(
          id: id,
          title: title,
          coverUrl: _ensureAbsoluteUrl(coverUrl),
          sourceId: _source.id,
        ));
      }
    }

    return results;
  }

  /// 获取番剧详情 (剧集列表)
  Future<AnimeDetail> fetchDetail(String animeId) async {
    if (_source.detail == null) {
      throw Exception('${_source.name}: 未配置详情接口');
    }

    final config = _source.detail!;
    final url = _resolveUrl(config.path.replaceAll('{id}', animeId));

    final html = await _http.getString(url, headers: _source.headers);
    final document = parse(html);

    // 提取摘要
    String? summary;
    if (config.summarySelector != null) {
      final summaryEl = document.querySelector(config.summarySelector!);
      summary = summaryEl?.text.trim();
    }

    // 提取标题 (从页面标题)
    String title = document.querySelector('title')?.text.trim() ?? '';
    // 尝试从规则字段中获取封面
    String coverUrl = '';

    // 提取剧集列表
    final episodeElements =
        document.querySelectorAll(config.episodeListSelector);
    final episodes = <EpisodeItem>[];

    for (final element in episodeElements) {
      final episodeId = DataExtractor.extractFromElement(
              element, config.fields['id'] ?? config.fields['playId']!) ??
          '';
      final episodeTitle = DataExtractor.extractFromElement(
              element,
              config.fields['title'] ??
                  config.fields['episodeTitle']!) ??
          '';

      if (episodeId.isNotEmpty) {
        episodes.add(EpisodeItem(
          id: episodeId,
          title: episodeTitle.isNotEmpty ? episodeTitle : '第${episodes.length + 1}话',
          playId: episodeId,
        ));
      }
    }

    return AnimeDetail(
      anime: AnimeItem(
        id: animeId,
        title: title,
        coverUrl: _ensureAbsoluteUrl(coverUrl),
        sourceId: _source.id,
        summary: summary,
      ),
      summary: summary,
      episodes: episodes,
    );
  }

  /// 解析播放地址
  ///
  /// 返回视频流 URL (m3u8 / mp4)。
  Future<String> resolvePlayUrl(String episodeId) async {
    if (_source.play == null) {
      throw Exception('${_source.name}: 未配置播放地址解析');
    }

    final config = _source.play!;
    var url = _resolveUrl(config.path.replaceAll('{id}', episodeId));

    // 如果有 iframe 中间页，先获取 iframe 地址
    if (config.iframeUrl != null) {
      final html = await _http.getString(url, headers: _source.headers);
      final document = parse(html);

      // 用 iframeUrl 规则提取中间地址
      String? iframeSrc;
      if (config.iframeUrl!.selector != null) {
        final iframeEl =
            document.querySelector(config.iframeUrl!.selector!);
        iframeSrc = DataExtractor._applyPostProcess(
            iframeEl, config.iframeUrl!.postProcess);
      }

      if (iframeSrc != null && iframeSrc.isNotEmpty) {
        url = _ensureAbsoluteUrl(iframeSrc);
      }
    }

    // 请求最终页面，提取视频地址
    final html = await _http.getString(url, headers: _source.headers);
    final document = parse(html);

    String? videoUrl;
    if (config.videoUrl.selector != null) {
      final videoEl = document.querySelector(config.videoUrl.selector!);
      videoUrl =
          DataExtractor._applyPostProcess(videoEl, config.videoUrl.postProcess);
    }

    if (videoUrl == null || videoUrl.isEmpty) {
      throw Exception('无法解析播放地址');
    }

    return _ensureAbsoluteUrl(videoUrl);
  }

  /// 获取规则源分类列表
  List<SourceCategory> getCategories() {
    return _source.categories?.map((c) {
          return SourceCategory(id: c.id, name: c.name);
        }).toList() ??
        [];
  }

  // ---- 内部工具方法 ----

  String _resolveUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final base = _source.baseUrl;
    if (base.endsWith('/') && path.startsWith('/')) {
      return '$base${path.substring(1)}';
    }
    if (!base.endsWith('/') && !path.startsWith('/')) {
      return '$base/$path';
    }
    return '$base$path';
  }

  String _ensureAbsoluteUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('//')) return 'https:$url';
    // 相对路径
    final base = _source.baseUrl;
    if (url.startsWith('/')) {
      final uri = Uri.parse(base);
      return '${uri.scheme}://${uri.host}$url';
    }
    return '$base/$url';
  }
}
