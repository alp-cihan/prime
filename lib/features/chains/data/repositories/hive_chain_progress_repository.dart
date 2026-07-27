import 'package:hive_ce/hive.dart';

import '../../domain/entities/chain_progress.dart';
import '../../domain/repositories/chain_progress_repository.dart';
import '../mappers/chain_progress_mapper.dart';
import '../models/chain_progress_hive_model.dart';

/// Hive CE-backed [ChainProgressRepository]. Keyed by
/// [ChainProgress.chainId] directly — one row per chain, freely
/// overwritten as progress advances (unlike the achievements box, this one
/// is a genuine upsert, not an append-only dedup-by-key write).
class HiveChainProgressRepository implements ChainProgressRepository {
  HiveChainProgressRepository(
    this._box, {
    ChainProgressMapper mapper = const ChainProgressMapper(),
  }) : _mapper = mapper;

  final Box<ChainProgressHiveModel> _box;
  final ChainProgressMapper _mapper;

  @override
  Future<ChainProgress?> getForChain(String chainId) async {
    final model = _box.get(chainId);
    return model == null ? null : _mapper.toDomain(model);
  }

  @override
  Future<List<ChainProgress>> getAll() async => _readAll();

  @override
  Stream<List<ChainProgress>> watchAll() async* {
    yield _readAll();
    yield* _box.watch().map((_) => _readAll());
  }

  @override
  Future<void> upsert(ChainProgress progress) async {
    await _box.put(progress.chainId, _mapper.toModel(progress));
  }

  List<ChainProgress> _readAll() => _box.values.map(_mapper.toDomain).toList();
}
