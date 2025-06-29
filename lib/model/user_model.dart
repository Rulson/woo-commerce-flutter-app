class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final String? avatar;
  final Map<String, dynamic>? billing;
  final Map<String, dynamic>? shipping;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.avatar,
    this.billing,
    this.shipping,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      username: json['username'],
      avatar: json['avatar_url'],
      billing: json['billing'],
      shipping: json['shipping'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'avatar_url': avatar,
      'billing': billing,
      'shipping': shipping,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
} 