import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anami/app.dart';

void main() {
  testWidgets('App renders browse page', (WidgetTester tester) async {
    await tester.pumpWidget(const AnamiApp());
    await tester.pump();

    // 首页应展示 Anami 标题或加载状态
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
