import 'package:cached_network_image/cached_network_image.dart';
import 'package:cho_nun_btk/app/models/auth/authmodels.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/provider/staff_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffManagementView extends StatefulWidget {
  const StaffManagementView({super.key});

  @override
  _StaffManagementViewState createState() => _StaffManagementViewState();
}

class _StaffManagementViewState extends State<StaffManagementView> {
  late Future<List<UserModel>> _usersFuture;
  UserProvider userProvider = UserProvider();

  AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<UserModel>> _fetchUsers() async {
    await userProvider.fetchUsers();
    return userProvider.users;
  }

  List<UserModel> allUsers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          } else {
            allUsers = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                final user = allUsers[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // CircleAvatar(
                            //   backgroundImage: user.photoUrl.isNotEmpty
                            //       ? NetworkImage(user.photoUrl)
                            //       : const AssetImage('assets/placeholder.png')
                            //           as ImageProvider,
                            //   radius: 30,
                            // ),

                            CachedNetworkImage(
                              imageUrl: user.photoUrl,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.person),
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                backgroundImage: imageProvider,
                                radius: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            authController.userModel!.uid == user.uid
                                ? SizedBox()
                                : Switch(
                                    value: user.blocked,
                                    onChanged: (value) {
                                      setState(() {
                                        allUsers[index] =
                                            allUsers[index].copyWith(
                                          blocked: value,
                                        );
                                        userProvider.blockUser(user.uid, value);
                                      });
                                    },
                                    activeColor: Colors.red,
                                  ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Phone', user.phone),
                        _buildDetailRow('Address', user.address),
                        _buildDetailRow('User Type',
                            UserTypeToString.convert(user.userType)),
                        _buildDetailRow(
                            'Joined On', user.joinedOn.toLocal().toString()),
                        _buildDetailRow(
                            'Last Login', user.lastLogin.toLocal().toString()),
                        const SizedBox(height: 8),
                        _buildBlockedStatus(user.blocked),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedStatus(bool blocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: blocked ? Colors.red.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        blocked ? 'Blocked' : 'Active',
        style: TextStyle(
          color: blocked ? Colors.red.shade800 : Colors.green.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
