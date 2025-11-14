/// Student data model
/// Maps to/from JSON for API communication
class StudentModel {
  final int? id;
  final String studentId;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final String? profilePicture;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentModel({
    this.id,
    required this.studentId,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.profilePicture,
    this.createdAt,
    this.updatedAt,
  });

  /// Create StudentModel from JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as int?,
      studentId: json['studentId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      profilePicture: json['profilePicture'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert StudentModel to JSON
  Map<String, dynamic> toJson() {
    return {
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
  }

  /// Create a copy with updated fields
  StudentModel copyWith({
    int? id,
    String? studentId,
    String? name,
    String? email,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
