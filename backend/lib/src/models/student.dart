/// Student model representing a student entity
class Student {
  final int? id;
  final String studentId;
  final String name;
  final String email;
  final String? passwordHash;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final String? profilePicture;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Student({
    this.id,
    required this.studentId,
    required this.name,
    required this.email,
    this.passwordHash,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.profilePicture,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Student from database row
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      studentId: map['student_id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash']?.toString(),
      phone: map['phone']?.toString(),
      address: map['address']?.toString(),
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'].toString())
          : null,
      profilePicture: map['profile_picture']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'].toString())
          : null,
    );
  }

  /// Convert Student to JSON (excluding sensitive data like password)
  Map<String, dynamic> toJson({bool includePassword = false}) {
    final json = {
      'id': id,
      'studentId': studentId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'profilePicture': profilePicture,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };

    if (includePassword && passwordHash != null) {
      json['passwordHash'] = passwordHash;
    }

    return json;
  }

  /// Create a copy of Student with updated fields
  Student copyWith({
    int? id,
    String? studentId,
    String? name,
    String? email,
    String? passwordHash,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
