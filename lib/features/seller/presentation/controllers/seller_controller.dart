import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:easy_deal/features/auth/presentation/controllers/auth_controller.dart';
import 'package:easy_deal/features/seller/data/seller_repository.dart';

final sellerRepositoryProvider = Provider<SellerRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return SellerRepository(client: client);
});

class SellerDashboardState {
  final Map<String, dynamic> stats;
  final bool isLoading;
  final String? errorMessage;

  const SellerDashboardState({
    this.stats = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  SellerDashboardState copyWith({
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SellerDashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SellerDashboardController extends StateNotifier<SellerDashboardState> {
  final SellerRepository _repository;

  SellerDashboardController(this._repository) : super(const SellerDashboardState()) {
    fetchStats();
  }

  Future<void> fetchStats() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _repository.getSellerStats();
    if (response.isSuccess && response.data != null) {
      state = state.copyWith(stats: response.data!, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }
}

final sellerDashboardControllerProvider =
    StateNotifierProvider<SellerDashboardController, SellerDashboardState>((ref) {
  final repo = ref.watch(sellerRepositoryProvider);
  return SellerDashboardController(repo);
});
