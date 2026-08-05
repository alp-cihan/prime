import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/design_system/widgets/quest_visual.dart';

void main() {
  testWidgets('renders the resolved asset for a known category seed', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuestVisual(seed: 'fitness/walk_20', height: 100),
      ),
    );
    await tester.pumpAndSettle();

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, 'assets/visuals/walking.png');
    expect(find.byType(DecoratedBox), findsNothing);
  });

  testWidgets('falls back to the gradient placeholder for an unresolvable seed '
      '(e.g. a plain quest id)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuestVisual(
          seed: '3f1a9c2e-4b7d-4e2a-9c1a-8f6b2d1e0a3c',
          icon: Icons.favorite_outline,
          height: 100,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
    expect(find.byType(DecoratedBox), findsOneWidget);
    expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
  });

  testWidgets('an explicit imageAssetPath always wins over the resolver', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuestVisual(
          seed: 'fitness/walk_20',
          imageAssetPath: 'assets/visuals/coding.png',
          height: 100,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, 'assets/visuals/coding.png');
  });
}
