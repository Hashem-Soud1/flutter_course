import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  List<Booking> bookings = [];
  bool isLoading = false;

  Future<void> fetchUserBookings(String userId) async {
    isLoading = true;
    notifyListeners();
    try {
      bookings = await _bookingService.getUserBookings(userId);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllBookings() async {
    isLoading = true;
    notifyListeners();
    try {
      bookings = await _bookingService.getAllBookings();
    } finally {
      isLoading = false;
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
      await fetchAllBookings();
    } else {
      await fetchUserBookings(userId);
    }
  }
}
