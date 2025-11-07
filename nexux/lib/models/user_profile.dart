class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? address;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      address: json['address'],
    );
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
    );
  }
}