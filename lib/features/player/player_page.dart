import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../providers.dart';

/// 视频播放页
///
/// 使用 media_kit 播放视频流，支持弹幕覆盖层。
class PlayerPage extends ConsumerStatefulWidget {
  final String videoUrl;

  /// 可选 videoUrl 直接指定，也可以 episodeId 由 provider 解析
  final String? episodeId;
  final String title;

  const PlayerPage({
    super.key,
    this.videoUrl = '',
    this.episodeId,
    required this.title,
  });

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  late final Player _player;
  late final VideoController _controller;

  String? _resolvedUrl;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _player = Player();
    _controller = VideoController(_player);

    _resolveAndPlay();
  }

  Future<void> _resolveAndPlay() async {
    try {
      String url;

      if (widget.videoUrl.isNotEmpty) {
        url = widget.videoUrl;
      } else if (widget.episodeId != null) {
        // 通过 provider 解析播放地址
        final executor = ref.read(ruleExecutorProvider);
        if (executor == null) {
          throw Exception('规则源未加载');
        }
        url = await executor.resolvePlayUrl(widget.episodeId!);
      } else {
        throw Exception('未提供视频地址');
      }

      setState(() {
        _resolvedUrl = url;
        _isLoading = false;
      });

      await _player.open(Media(url));
      await _player.play();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('正在解析播放地址...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _resolveAndPlay();
                        },
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // 视频播放区域
                    Center(
                      child: Video(
                        controller: _controller,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // 底部提示
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Text(
                        '可在此叠加弹幕层 | 当前: ${_resolvedUrl ?? ''}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          backgroundColor: Colors.black45,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // 弹幕占位区 (后续集成 flutter_danmaku)
                  ],
                ),
    );
  }
}
