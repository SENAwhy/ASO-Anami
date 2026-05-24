import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 MediaKit (桌面端视频播放必需)
  MediaKit.ensureInitialized();

  // 初始化 Hive 本地存储
  await Hive.initFlutter();

  runApp(
    const ProviderScope(
      child: AnamiApp(),
    ),
  );
}
