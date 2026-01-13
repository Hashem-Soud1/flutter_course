import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel.dart';
import '../models/booking.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user bookings
  Future<List<Booking>> getUserBookings(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookings')
        .get();

    List<Booking> loadedBookings = [];

    for (var doc in snapshot.docs) {
      final hotelId = doc['hotelId'];
      final bookingId = doc.id;
      final bookedAt = (doc['bookedAt'] as Timestamp?)?.toDate();

      final hotelDoc = await _firestore.collection('hotels').doc(hotelId).get();
      if (hotelDoc.exists) {
        final hotel = Hotel.fromMap(hotelDoc.data()!, hotelDoc.id);
        loadedBookings.add(
          Booking(
            bookingId: bookingId,
            hotel: hotel,
            userId: userId,
            bookedAt: bookedAt,
          ),
        );
      }
    }
    // الترتيب محلياً لتجنب طلب الـ Index من فايربيز
    loadedBookings.sort((a, b) {
      if (a.bookedAt == null) return 1;
      if (b.bookedAt == null) return -1;
      return b.bookedAt!.compareTo(a.bookedAt!);
    });
    return loadedBookings;
  }

  // Get ALL bookings (for Admin) using Collection Group
  Future<List<Booking>> getAllBookings() async {
    final snapshot = await _firestore.collectionGroup('bookings').get();

    List<Booking> loadedBookings = [];

    for (var doc in snapshot.docs) {
      final hotelId = doc['hotelId'];
      final bookingId = doc.id;
      final bookedAt = (doc['bookedAt'] as Timestamp?)?.toDate();
      // The path is users/{userId}/bookings/{bookingId}
      final userId = doc.reference.parent.parent!.id;

      final hotelDoc = await _firestore.collection('hotels').doc(hotelId).get();
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (hotelDoc.exists) {
        final hotel = Hotel.fromMap(hotelDoc.data()!, hotelDoc.id);
        final userData = userDoc.exists ? userDoc.data() : null;

        loadedBookings.add(
          Booking(
            bookingId: bookingId,
            hotel: hotel,
            userId: userId,
            userName: userData?['name'],
            userEmail: userData?['email'],
            bookedAt: bookedAt,
          ),
        );
      }
    }
    // الترتيب محلياً لتجنب طلب الـ Index من فايربيز
    loadedBookings.sort((a, b) {
      if (a.bookedAt == null) return 1;
      if (b.bookedAt == null) return -1;
      return b.bookedAt!.compareTo(a.bookedAt!);
    });
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
