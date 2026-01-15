import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/home_service.dart';

class HotelProvider extends ChangeNotifier {
  final HomeService _homeService = HomeService();
  List<Hotel> hotels = [];
  bool isLoading = false;
  String? error;

  HotelProvider() {
    fetchHotels();
  }

  Future<void> fetchHotels() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      hotels = await _homeService.getHotels();
    } catch (e) {
      error = "Failed to load hotels";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHotel(Hotel hotel) async {
    await _homeService.addHotel(hotel);
    await fetchHotels();
  }

  Future<void> updateHotel(Hotel hotel) async {
    await _homeService.updateHotel(hotel);
    await fetchHotels();
  }

  Future<void> deleteHotel(String id) async {
    try {
      await _homeService.deleteHotel(id);
      await fetchHotels();
    } catch (e) {
      error = "Delete failed";
      notifyListeners();
    }
  }
}
