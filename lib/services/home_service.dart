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
      // You might want to handle errors more gracefully or rethrow
      throw e;
    }
  }
}
