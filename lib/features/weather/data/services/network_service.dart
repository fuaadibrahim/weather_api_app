import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkService {
  Future<bool> get hasInternet async {
    return InternetConnection().hasInternetAccess;
  }
}
