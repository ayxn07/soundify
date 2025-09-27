import 'package:firebase_storage/firebase_storage.dart';

abstract class StorageUrlResolver {
  Future<String> urlFor(String storagePath);
}

class StorageUrlResolverImpl implements StorageUrlResolver {
  final _cache = <String, String>{};
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<String> urlFor(String storagePath) async {
    if (_cache.containsKey(storagePath)) return _cache[storagePath]!;
    final url = await _storage.ref(storagePath).getDownloadURL();
    _cache[storagePath] = url;
    return url;
  }
}
