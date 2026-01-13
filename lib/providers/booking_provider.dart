import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> loadUserBookings(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _bookings = await _bookingService.getUserBookings(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllBookings() async {
    _isLoading = true;
    notifyListeners();
    try {
      _bookings = await _bookingService.getAllBookings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(
    String userId,
    String bookingId,
    bool isAdmin,
  ) async {
    await _bookingService.cancelBooking(userId, bookingId);
    if (isAdmin) {
      await loadAllBookings();
    } else {
      await loadUserBookings(userId);
    }
  }
}
