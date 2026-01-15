import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel.dart';
import '../models/booking.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add new booking
  Future<void> createBooking(String userId, String hotelId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookings')
        .add({
          'hotelId': hotelId,
          'bookedAt': FieldValue.serverTimestamp(),
          'status': 'confirmed',
        });
  }

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
      final hotelDoc = await _firestore.collection('hotels').doc(hotelId).get();
      if (hotelDoc.exists) {
        loadedBookings.add(
          Booking(
            bookingId: doc.id,
            hotel: Hotel.fromMap(hotelDoc.data()!, hotelDoc.id),
            userId: userId,
            bookedAt: (doc['bookedAt'] as Timestamp?)?.toDate(),
          ),
        );
      }
    }
    return loadedBookings;
  }

  // Get ALL bookings (Admin)
  Future<List<Booking>> getAllBookings() async {
    final snapshot = await _firestore.collectionGroup('bookings').get();
    List<Booking> loadedBookings = [];

    for (var doc in snapshot.docs) {
      final hotelId = doc['hotelId'];
      final userId = doc.reference.parent.parent!.id;

      final hotelDoc = await _firestore.collection('hotels').doc(hotelId).get();
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (hotelDoc.exists) {
        final userData = userDoc.exists ? userDoc.data() : null;
        loadedBookings.add(
          Booking(
            bookingId: doc.id,
            hotel: Hotel.fromMap(hotelDoc.data()!, hotelDoc.id),
            userId: userId,
            userName: userData?['name'],
            bookedAt: (doc['bookedAt'] as Timestamp?)?.toDate(),
          ),
        );
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
