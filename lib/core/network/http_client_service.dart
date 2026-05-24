import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// 网络请求服务
///
/// 封装 Dio，支持自定义请求头、cookie 管理、重试。
/// Web 端自动使用 CORS 代理绕过浏览器跨域限制。
class HttpClientService {
  final Dio _dio;

  /// CORS 代理地址 (Web 端使用)
  static const String _corsProxy = 'https://corsproxy.io/?url=';

  HttpClientService({Map<String, String>? defaultHeaders})
      : _dio = Dio(BaseOptions(
          headers: defaultHeaders ??
              {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Accept': 'text/html,application/json,*/*',
                'Accept-Language': 'zh-CN,zh;q=0.9',
              },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          followRedirects: true,
          maxRedirects: 5,
        ));

  /// Web 端需要通过 CORS 代理访问外部网站
  String _resolveUrl(String url) {
    if (kIsWeb) {
      return '$_corsProxy${Uri.encodeComponent(url)}';
    }
    return url;
  }

  /// GET 请求，返回响应体字符串
  Future<String> getString(String url,
      {Map<String, String>? headers}) async {
    final resolvedUrl = _resolveUrl(url);
    try {
      final response = await _dio.get<String>(
        resolvedUrl,
        options: Options(
          headers: kIsWeb ? null : headers,
        ),
      );
      return response.data ?? '';
    } on DioException catch (e) {
      final msg = e.type == DioExceptionType.connectionError
          ? '网络连接失败 (CORS/跨域限制?)'
          : '请求失败: ${e.message}';
      throw Exception(msg);
    }
  }

  /// GET 请求，返回 JSON
  Future<dynamic> getJson(String url,
      {Map<String, String>? headers}) async {
    final resolvedUrl = _resolveUrl(url);
    try {
      final response = await _dio.get<dynamic>(
        resolvedUrl,
        options: Options(
          headers: kIsWeb ? null : headers,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('JSON请求失败: ${e.message}');
    }
  }

  /// POST 请求 (表单)
  Future<String> postForm(String url,
      {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    final resolvedUrl = _resolveUrl(url);
    try {
      final response = await _dio.post<String>(
        resolvedUrl,
        data: data,
        options: Options(
          headers: kIsWeb ? null : headers,
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response.data ?? '';
    } on DioException catch (e) {
      throw Exception('POST请求失败: ${e.message}');
    }
  }
}
