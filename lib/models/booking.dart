import 'package:cloud_firestore/cloud_firestore.dart';
import 'hotel.dart';

class Booking {
  final String bookingId;
  final Hotel hotel;
  final String userId;
  final String? userName;
  final String? userEmail;
  final DateTime? bookedAt;
  final int nights;
  final double totalPrice;
  final DateTime? checkInDate;

  Booking({
    required this.bookingId,
    required this.hotel,
    required this.userId,
    this.userName,
    this.userEmail,
    this.bookedAt,
    this.nights = 1,
    this.totalPrice = 0.0,
    this.checkInDate,
  });

  factory Booking.fromMap({
    required Map<String, dynamic> data,
    required String bookingId,
    required String userId,
    required Hotel hotel,
    Map<String, dynamic>? userData,
  }) {
    return Booking(
      bookingId: bookingId,
      hotel: hotel,
      userId: userId,
      userName: userData?['name'],
      userEmail: userData?['email'],
      bookedAt: (data['bookedAt'] as Timestamp?)?.toDate(),
      nights: data['nights'] ?? 1,
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      checkInDate: (data['checkInDate'] as Timestamp?)?.toDate(),
    );
  }
}
