import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:easy_deal/features/auth/presentation/controllers/auth_controller.dart';
import 'package:easy_deal/features/booking/data/booking_repository.dart';
import 'package:easy_deal/features/booking/data/models/booking_model.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return BookingRepository(client: client);
});

class BookingListState {
  final List<BookingModel> bookings;
  final bool isLoading;
  final String? errorMessage;

  const BookingListState({
    this.bookings = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BookingListState copyWith({
    List<BookingModel>? bookings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BookingListState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class BookingListController extends StateNotifier<BookingListState> {
  final BookingRepository _repository;

  BookingListController(this._repository) : super(const BookingListState()) {
    fetchMyBookings();
  }

  Future<void> fetchMyBookings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _repository.getMyBookings();
    if (response.isSuccess && response.data != null) {
      state = state.copyWith(bookings: response.data!, isLoading: false);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Failed to load bookings',
      );
    }
  }

  void addConfirmedBooking(BookingModel booking) {
    state = state.copyWith(bookings: [booking, ...state.bookings]);
  }
}

final bookingListControllerProvider =
    StateNotifierProvider<BookingListController, BookingListState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingListController(repository);
});
