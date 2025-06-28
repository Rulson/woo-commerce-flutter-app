class Category {
  final int id;
  final String name;
  final String slug;
  final int parent;
  final String description;
  final String display;
  final int menuOrder;
  final int count;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.parent,
    required this.description,
    required this.display,
    required this.menuOrder,
    required this.count,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      parent: json['parent'] ?? 0,
      description: json['description'] ?? '',
      display: json['display'] ?? '',
      menuOrder: json['menu_order'] ?? 0,
      count: json['count'] ?? 0,
    );
  }
}