import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/design_system/asset_visual_resolver.dart';

void main() {
  const resolver = AssetVisualResolver();

  test('resolves a bare category seed directly', () {
    expect(resolver.resolve('fitness'), 'assets/visuals/fitness.png');
    expect(resolver.resolve('coding'), 'assets/visuals/coding.png');
  });

  test('resolves a suggestion visualKey via its category segment', () {
    expect(resolver.resolve('study/pomodoro'), 'assets/visuals/study.png');
    expect(resolver.resolve('reading/pages_20'), 'assets/visuals/reading.png');
    expect(resolver.resolve('sleep/nap'), 'assets/visuals/sleep.png');
  });

  test('prefers a more specific slug match over the generic category '
      '(nutrition/water -> water.png, not nutrition.png)', () {
    expect(resolver.resolve('nutrition/water'), 'assets/visuals/water.png');
  });

  test('matches known synonyms found in the suggestion catalog', () {
    expect(resolver.resolve('fitness/walk_20'), 'assets/visuals/walking.png');
    expect(
      resolver.resolve('fitness/gentle_walk'),
      'assets/visuals/walking.png',
    );
    expect(
      resolver.resolve('organization/declutter'),
      'assets/visuals/cleaning.png',
    );
    expect(
      resolver.resolve('organization/tidy_sprint'),
      'assets/visuals/cleaning.png',
    );
    expect(
      resolver.resolve('mindfulness/journal_evening'),
      'assets/visuals/journaling.png',
    );
    expect(
      resolver.resolve('mindfulness/meditate'),
      'assets/visuals/meditation.png',
    );
    expect(
      resolver.resolve('mindfulness/deep_breathing'),
      'assets/visuals/meditation.png', // falls through to the category alias
    );
  });

  test('is case-insensitive', () {
    expect(resolver.resolve('Fitness/Walk_20'), 'assets/visuals/walking.png');
  });

  test('returns null for a plain quest id (no category information at all), '
      'so QuestVisual keeps its gradient placeholder', () {
    expect(resolver.resolve('3f1a9c2e-4b7d-4e2a-9c1a-8f6b2d1e0a3c'), isNull);
  });

  test('returns null for a category-shaped seed with no catalog match', () {
    expect(resolver.resolve('career/deep_work'), isNull);
    expect(resolver.resolve('finance/log_spending'), isNull);
    expect(resolver.resolve('creativity/sketch'), isNull);
  });

  test('resolving the same seed twice is deterministic', () {
    final first = resolver.resolve('fitness/walk_20');
    final second = resolver.resolve('fitness/walk_20');
    expect(first, second);
  });
}
