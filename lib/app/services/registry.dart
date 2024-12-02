import 'package:cho_nun_btk/app/provider/authProvider.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

Future<void> setupRegistry() async {
  // Create and register MyService with async initialization
  serviceLocator.registerLazySingleton<AuthProvider>(() => AuthProvider());
}
