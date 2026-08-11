class Profile {
  const Profile({
    required this.id,
    this.fullName,
    this.phone,
    this.createdAt,
  });

  final String id;
  final String? fullName;
  final String? phone;
  final DateTime? createdAt;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
      };
}
