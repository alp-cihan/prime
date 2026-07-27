import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/use_cases/clear_local_data_use_case.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
ClearLocalDataUseCase clearLocalDataUseCase(Ref ref) =>
    const ClearLocalDataUseCase();
