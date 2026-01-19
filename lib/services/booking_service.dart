import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel.dart';
import '../models/booking.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBooking(
    String userId,
    String hotelId, {
    int nights = 1,
    double totalPrice = 0,
    DateTime? checkInDate,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookings')
        .add({
          'hotelId': hotelId,
          'bookedAt': FieldValue.serverTimestamp(),
          'status': 'confirmed',
          'nights': nights,
          'totalPrice': totalPrice,
          'checkInDate': checkInDate != null
              ? Timestamp.fromDate(checkInDate)
              : null,
        });
  }

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
        final data = doc.data() as Map<String, dynamic>;
        loadedBookings.add(
          Booking.fromMap(
            data: data,
            bookingId: doc.id,
            userId: userId,
            hotel: Hotel.fromMap(hotelDoc.data()!, hotelDoc.id),
          ),
        );
      }
    }
    return loadedBookings;
  }

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
          Booking.fromMap(
            data: doc.data() as Map<String, dynamic>,
            bookingId: doc.id,
            userId: userId,
            hotel: Hotel.fromMap(hotelDoc.data()!, hotelDoc.id),
            userData: userData as Map<String, dynamic>?,
          ),
        );
      }
    }
    return loadedBookings;
  }

  Future<void> cancelBooking(String userId, String bookingId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookings')
        .doc(bookingId)
        .delete();
  }

  Future<void> updateBooking(
    String userId,
    String bookingId, {
    required int nights,
    required double totalPrice,
    required DateTime checkInDate,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookings')
        .doc(bookingId)
        .update({
          'nights': nights,
          'totalPrice': totalPrice,
          'checkInDate': Timestamp.fromDate(checkInDate),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}
