import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class CacheCompressionHelper {
  static const String _gzipPrefix = 'gz:';
  static const String _plainPrefix = 'pl:';

  static String encodeJson(dynamic data, {bool compress = true}) {
    final jsonStr = jsonEncode(data);

    if (!compress || jsonStr.isEmpty) {
      return '$_plainPrefix$jsonStr';
    }

    try {
      final bytes = utf8.encode(jsonStr);
      final gzipped = gzip.encode(bytes);
      final b64 = base64Encode(gzipped);
      return '$_gzipPrefix$b64';
    } catch (_) {
      return '$_plainPrefix$jsonStr';
    }
  }

  static dynamic decodeJson(String raw) {
    if (raw.startsWith(_gzipPrefix)) {
      final payload = raw.substring(_gzipPrefix.length);
      final compressed = base64Decode(payload);
      final bytes = gzip.decode(compressed);
      final jsonStr = utf8.decode(bytes);
      return jsonDecode(jsonStr);
    }

    if (raw.startsWith(_plainPrefix)) {
      final payload = raw.substring(_plainPrefix.length);
      return jsonDecode(payload);
    }

    // backward compatibility
    return jsonDecode(raw);
  }

  static bool isCompressed(String raw) => raw.startsWith(_gzipPrefix);

  static int estimateCompressedBytes(String raw) {
    return utf8.encode(raw).length;
  }

  static String encodeCompactList(
      List<dynamic> list, {
        required bool compress,
      }) {
    return encodeJson(list, compress: compress);
  }

  static List<dynamic> decodeCompactList(String raw) {
    final decoded = decodeJson(raw);
    if (decoded is List) return decoded;
    return const [];
  }

  static Map<String, dynamic> decodeMap(String raw) {
    final decoded = decodeJson(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {};
  }

  static String compressString(String input) {
    if (input.isEmpty) return '';
    final gzipped = gzip.encode(utf8.encode(input));
    return base64Encode(gzipped);
  }

  static String decompressString(String input) {
    if (input.isEmpty) return '';
    final decoded = base64Decode(input);
    final bytes = gzip.decode(decoded);
    return utf8.decode(bytes);
  }
}