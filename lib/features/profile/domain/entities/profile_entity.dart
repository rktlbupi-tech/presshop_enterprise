import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? profileImage;
  final String? designation;
  final String? department;
  final String? address;
  final String? employeeId;
  final DateTime? joinedAt;
  final String? companyName;
  final String? companyLogo;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.profileImage,
    this.designation,
    this.department,
    this.address,
    this.employeeId,
    this.joinedAt,
    this.companyName,
    this.companyLogo,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [id, email, firstName, lastName];
}
