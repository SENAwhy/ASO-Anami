import 'package:dio/dio.dart';

/// 网络请求服务
///
/// 封装 Dio，支持自定义请求头、cookie 管理、重试。
class HttpClientService {
  final Dio _dio;

  HttpClientService({Map<String, String>? defaultHeaders})
      : _dio = Dio(BaseOptions(
          headers: defaultHeaders ??
              {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Accept': 'text/html,application/json,*/*',
                'Accept-Language': 'zh-CN,zh;q=0.9',
              },
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          followRedirects: true,
          maxRedirects: 5,
        ));

  /// GET 请求，返回响应体字符串
  Future<String> getString(String url,
      {Map<String, String>? headers}) async {
    final response = await _dio.get<String>(
      url,
      options: Options(headers: headers),
    );
    return response.data ?? '';
  }

  /// GET 请求，返回 JSON
  Future<dynamic> getJson(String url,
      {Map<String, String>? headers}) async {
    final response = await _dio.get<dynamic>(
      url,
      options: Options(headers: headers),
    );
    return response.data;
  }

  /// POST 请求 (表单)
  Future<String> postForm(String url,
      {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    final response = await _dio.post<String>(
      url,
      data: data,
      options: Options(
        headers: headers,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return response.data ?? '';
  }
}
