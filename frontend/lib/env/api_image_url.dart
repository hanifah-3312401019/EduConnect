import 'package:flutter/foundation.dart';

class ApiImageUrl {
  static String storage(String path) {
    if (path.isEmpty || path == 'null') return '';
    if (kIsWeb) {
      return 'http://192.168.1.52:8000/storage/$path';
    } else {
      return 'http://127.0.0.1:8000/storage/$path';
    }
  }
}
