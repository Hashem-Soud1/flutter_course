class Hotel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final double price; // Stored as double for calculation, display as string
  final String address;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.address,
  });

  // Factory to create from Firestore
  factory Hotel.fromMap(Map<String, dynamic> data, String documentId) {
    return Hotel(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      price: (data['price'] ?? 0.0).toDouble(),
      address: data['address'] ?? '',
    );
  }

  // To save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'price': price,
      'address': address,
    };
  }
}
