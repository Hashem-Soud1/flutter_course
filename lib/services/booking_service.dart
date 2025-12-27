import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel.dart';

// Helper model for bookings
class BookingItem {
  final String bookingId;
  final Hotel hotel;

  BookingItem({required this.bookingId, required this.hotel});
}

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user bookings
  Future<List<BookingItem>> getUserBookings(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookings')
        .orderBy('bookedAt', descending: true)
        .get();

    List<BookingItem> loadedBookings = [];

    for (var doc in snapshot.docs) {
      final hotelId = doc['hotelId'];
      final bookingId = doc.id;

      final hotelDoc = await _firestore.collection('hotels').doc(hotelId).get();
      if (hotelDoc.exists) {
        final hotel = Hotel.fromMap(hotelDoc.data()!, hotelDoc.id);
        loadedBookings.add(BookingItem(bookingId: bookingId, hotel: hotel));
      }
    }
    return loadedBookings;
  }

  // Cancel booking
  Future<void> cancelBooking(String userId, String bookingId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookings')
        .doc(bookingId)
        .delete();
  }
}
