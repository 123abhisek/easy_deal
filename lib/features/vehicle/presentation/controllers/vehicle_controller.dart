import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:easy_deal/features/auth/presentation/controllers/auth_controller.dart';
import 'package:easy_deal/features/vehicle/data/models/vehicle_model.dart';
import 'package:easy_deal/features/vehicle/data/vehicle_repository.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return VehicleRepository(client: client);
});

class VehicleListState {
  final List<VehicleModel> vehicles;
  final bool isLoading;
  final String? errorMessage;
  final String selectedBrand;
  final String? searchQuery;

  const VehicleListState({
    this.vehicles = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedBrand = 'All',
    this.searchQuery,
  });

  VehicleListState copyWith({
    List<VehicleModel>? vehicles,
    bool? isLoading,
    String? errorMessage,
    String? selectedBrand,
    String? searchQuery,
  }) {
    return VehicleListState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class VehicleListController extends StateNotifier<VehicleListState> {
  final VehicleRepository _repository;

  VehicleListController(this._repository) : super(const VehicleListState()) {
    fetchVehicles();
  }

  Future<void> fetchVehicles({String? brand, String? location}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _repository.getVehicles(
      brand: brand ?? (state.selectedBrand != 'All' ? state.selectedBrand : null),
      location: location,
    );

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        vehicles: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Failed to load vehicles',
      );
    }
  }

  void filterByBrand(String brand) {
    state = state.copyWith(selectedBrand: brand);
    fetchVehicles(brand: brand == 'All' ? null : brand);
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  List<VehicleModel> get filteredVehicles {
    if (state.searchQuery == null || state.searchQuery!.trim().isEmpty) {
      return state.vehicles;
    }
    final q = state.searchQuery!.toLowerCase();
    return state.vehicles.where((v) {
      return v.title.toLowerCase().contains(q) ||
          v.brand.toLowerCase().contains(q) ||
          v.model.toLowerCase().contains(q) ||
          v.location.toLowerCase().contains(q);
    }).toList();
  }
}

final vehicleListControllerProvider =
    StateNotifierProvider<VehicleListController, VehicleListState>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return VehicleListController(repository);
});
