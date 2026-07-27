import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/chains/data/mappers/chain_progress_mapper.dart';
import 'package:prime/features/chains/domain/entities/chain_progress.dart';

void main() {
  const mapper = ChainProgressMapper();

  test('round-trips a completed chain', () {
    final progress = ChainProgress(
      chainId: 'chain1',
      completedStageCount: 3,
      completedAt: DateTime.utc(2026, 1, 10, 9, 30, 15, 500),
    );

    final roundTripped = mapper.toDomain(mapper.toModel(progress));

    expect(roundTripped, progress);
  });

  test('round-trips a null completedAt', () {
    const progress = ChainProgress(chainId: 'chain1', completedStageCount: 1);

    final roundTripped = mapper.toDomain(mapper.toModel(progress));

    expect(roundTripped.completedAt, isNull);
    expect(roundTripped.completedStageCount, 1);
  });

  test('completedAt survives microsecond precision', () {
    final progress = ChainProgress(
      chainId: 'chain1',
      completedStageCount: 2,
      completedAt: DateTime.utc(2026, 1, 10, 9, 30, 15, 123, 456),
    );

    final roundTripped = mapper.toDomain(mapper.toModel(progress));

    expect(roundTripped.completedAt, progress.completedAt);
  });
}
