import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all hotels
  Future<List<Hotel>> getHotels() async {
    try {
      final snapshot = await _firestore.collection('hotels').get();
      return snapshot.docs.map((doc) {
        return Hotel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add a new hotel
  Future<void> addHotel(Hotel hotel) async {
    await _firestore.collection('hotels').add(hotel.toMap());
  }

  // Update an existing hotel
  Future<void> updateHotel(Hotel hotel) async {
    await _firestore.collection('hotels').doc(hotel.id).update(hotel.toMap());
  }

  // Delete a hotel
  Future<void> deleteHotel(String hotelId) async {
    await _firestore.collection('hotels').doc(hotelId).delete();
  }
}
