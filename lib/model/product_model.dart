class Product {
  final int id;
  final String name;
  final String slug;
  final String permalink;
  final String? price;
  final String? shortDescription;
  final List<ProductImage> images;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.permalink,
    required this.price,
    required this.shortDescription,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      permalink: json['permalink'] ?? '',
      price: json['price']?.toString(),
      shortDescription: json['short_description'],
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => ProductImage.fromJson(img))
              .toList() ??
          [],
    );
  }
}

class ProductImage {
  final int id;
  final String src;
  final String name;

  ProductImage({
    required this.id,
    required this.src,
    required this.name,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      src: json['src'] ?? '',
      name: json['name'] ?? '',
    );
  }
}