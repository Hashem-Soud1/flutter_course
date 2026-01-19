import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> addHotel(Hotel hotel) async {
    await _firestore.collection('hotels').add(hotel.toMap());
  }

  Future<void> updateHotel(Hotel hotel) async {
    await _firestore.collection('hotels').doc(hotel.id).update(hotel.toMap());
  }

  Future<void> deleteHotel(String hotelId) async {
    await _firestore.collection('hotels').doc(hotelId).delete();
  }
}
