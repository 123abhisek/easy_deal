import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:easy_deal/features/auth/presentation/controllers/auth_controller.dart';
import 'package:easy_deal/features/property/data/models/property_model.dart';
import 'package:easy_deal/features/property/data/property_repository.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return PropertyRepository(client: client);
});

class PropertyListState {
  final List<PropertyModel> properties;
  final bool isLoading;
  final String? errorMessage;
  final String selectedType;
  final String? searchQuery;

  const PropertyListState({
    this.properties = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedType = 'All',
    this.searchQuery,
  });

  PropertyListState copyWith({
    List<PropertyModel>? properties,
    bool? isLoading,
    String? errorMessage,
    String? selectedType,
    String? searchQuery,
  }) {
    return PropertyListState(
      properties: properties ?? this.properties,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedType: selectedType ?? this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PropertyListController extends StateNotifier<PropertyListState> {
  final PropertyRepository _repository;

  PropertyListController(this._repository) : super(const PropertyListState()) {
    fetchProperties();
  }

  Future<void> fetchProperties({String? type, String? location}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _repository.getProperties(
      propertyType: type ?? (state.selectedType != 'All' ? state.selectedType : null),
      location: location,
    );

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        properties: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Failed to load properties',
      );
    }
  }

  void filterByType(String type) {
    state = state.copyWith(selectedType: type);
    fetchProperties(type: type == 'All' ? null : type);
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  List<PropertyModel> get filteredProperties {
    if (state.searchQuery == null || state.searchQuery!.trim().isEmpty) {
      return state.properties;
    }
    final q = state.searchQuery!.toLowerCase();
    return state.properties.where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q) ||
          p.propertyType.toLowerCase().contains(q);
    }).toList();
  }
}

final propertyListControllerProvider =
    StateNotifierProvider<PropertyListController, PropertyListState>((ref) {
  final repository = ref.watch(propertyRepositoryProvider);
  return PropertyListController(repository);
});
