import '../../domain/entities/profile_entity.dart';

class ProfileModel {
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

  ProfileModel({
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

  factory ProfileModel.fromJson(Map<String, dynamic> j) {
    final pub = j['publicationDetails'] as Map<String, dynamic>?;
    return ProfileModel(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      email: j['email']?.toString() ?? '',
      firstName: j['firstName']?.toString() ?? '',
      lastName: j['lastName']?.toString() ?? '',
      phone: j['phone']?.toString(),
      profileImage: j['profileImage']?.toString(),
      designation: j['designation']?.toString(),
      department: j['department']?.toString(),
      address: j['address']?.toString(),
      employeeId: j['employeeId']?.toString(),
      joinedAt: j['joinedAt'] != null ? DateTime.tryParse(j['joinedAt'].toString()) : null,
      companyName: pub?['companyName']?.toString(),
      companyLogo: pub?['profileImage']?.toString(),
    );
  }

  ProfileEntity toEntity() => ProfileEntity(
        id: id, email: email, firstName: firstName, lastName: lastName,
        phone: phone, profileImage: profileImage, designation: designation,
        department: department, address: address, employeeId: employeeId,
        joinedAt: joinedAt, companyName: companyName, companyLogo: companyLogo,
      );
}
