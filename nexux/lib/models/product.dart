class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final String restaurant;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.description = 'A fantastic product.',
    this.restaurant = 'Unknown Restaurant',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'price': price,
        'description': description,
        'restaurant': restaurant,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        imageUrl: json['imageUrl'],
        price: json['price'],
        description: json['description'] ?? 'A fantastic product.',
        restaurant: json['restaurant'] ?? 'Unknown Restaurant',
      );
}
