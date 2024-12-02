import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String photoUrl;
  final String phone;
  final String address;
  final UserType userType;
  final String password;
  final bool blocked;
  final DateTime joinedOn;
  final DateTime lastLogin;
  String fcmToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.phone,
    required this.address,
    required this.userType,
    required this.password,
    required this.blocked,
    required this.joinedOn,
    required this.lastLogin,
    required this.fcmToken,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoUrl,
    String? phone,
    String? address,
    UserType? userType,
    String? password,
    bool? blocked,
    DateTime? joinedOn,
    DateTime? lastLogin,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      userType: userType ?? this.userType,
      password: password ?? this.password,
      blocked: blocked ?? this.blocked,
      joinedOn: joinedOn ?? this.joinedOn,
      lastLogin: lastLogin ?? this.lastLogin,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phone': phone,
      'address': address,
      'userType': userType.toString(),
      'password': password,
      'blocked': blocked,
      'joinedOn': joinedOn.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      userType: UserType.values.firstWhere(
          (e) => e.toString() == json['userType'],
          orElse: () => UserType.NONE), // Handle default UserType
      password: json['password'] as String,
      blocked: json['blocked'] as bool,
      joinedOn: DateTime.parse(json['joinedOn'] as String),
      lastLogin: DateTime.parse(json['lastLogin'] as String),
      fcmToken: json['fcmToken'] as String,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        photoUrl,
        phone,
        address,
        userType,
        password,
        blocked,
        joinedOn,
        lastLogin,
        fcmToken,
      ];
}
