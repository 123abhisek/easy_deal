import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:easy_deal/features/auth/presentation/controllers/auth_controller.dart';
import 'package:easy_deal/features/admin/data/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AdminRepository(client: client);
});

class AdminState {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> pendingListings;
  final bool isLoading;
  final String? errorMessage;

  const AdminState({
    this.stats = const {},
    this.pendingListings = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AdminState copyWith({
    Map<String, dynamic>? stats,
    List<Map<String, dynamic>>? pendingListings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminState(
      stats: stats ?? this.stats,
      pendingListings: pendingListings ?? this.pendingListings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AdminController extends StateNotifier<AdminState> {
  final AdminRepository _repository;

  AdminController(this._repository) : super(const AdminState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final statsRes = await _repository.getDashboardStats();
    final pendingRes = await _repository.getPendingListings();

    state = state.copyWith(
      stats: statsRes.data ?? {},
      pendingListings: pendingRes.data ?? [],
      isLoading: false,
    );
  }

  Future<bool> moderateListing(String id, String type, String status) async {
    final res = await _repository.updateListingStatus(id, type, status);
    if (res.isSuccess) {
      final updatedList = state.pendingListings.where((item) => item['id'] != id).toList();
      state = state.copyWith(pendingListings: updatedList);
      return true;
    }
    return false;
  }
}

final adminControllerProvider = StateNotifierProvider<AdminController, AdminState>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return AdminController(repo);
});
