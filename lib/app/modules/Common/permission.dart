// First, add these dependencies to pubspec.yaml:
// permission_handler: ^11.0.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends StatefulWidget {
  final Widget nextScreen;

  const PermissionsScreen({Key? key, required this.nextScreen})
      : super(key: key);

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final Map<Permission, bool> _permissionStatus = {
    Permission.bluetooth: false,
    Permission.notification: false,
  };

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    for (var permission in _permissionStatus.keys) {
      final status = await permission.status;
      setState(() {
        _permissionStatus[permission] = status.isGranted;
      });
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      _permissionStatus[permission] = status.isGranted;
    });

    // Check if all permissions are granted
    if (_permissionStatus.values.every((status) => status)) {
      Get.off(() => widget.nextScreen);
    }
  }

  String _getPermissionTitle(Permission permission) {
    switch (permission) {
      case Permission.bluetooth:
        return 'Bluetooth';

      case Permission.notification:
        return 'Notifications';
      default:
        return 'Unknown';
    }
  }

  String _getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.bluetooth:
        return 'Required for connecting to nearby devices';

      case Permission.notification:
        return 'Stay updated with important alerts and messages';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Required Permissions',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Please grant the following permissions to use all features of the app',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView(
                  children: _permissionStatus.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        child: ListTile(
                          title: Text(_getPermissionTitle(entry.key)),
                          subtitle: Text(_getPermissionDescription(entry.key)),
                          trailing: entry.value
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : ElevatedButton(
                                  onPressed: () =>
                                      _requestPermission(entry.key),
                                  child: const Text('Grant'),
                                ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_permissionStatus.values.every((status) => status))
                Center(
                  child: ElevatedButton(
                    onPressed: () => Get.off(() => widget.nextScreen),
                    child: const Text('Continue'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
