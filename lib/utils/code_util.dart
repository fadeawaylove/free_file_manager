import 'dart:convert' as convert;
import 'dart:typed_data';

convert.Codec<String, String> base64Coder = convert.utf8.fuse(convert.base64);

// 将base64字符串解码，并且用ut8编码
String b64utf8decode(String encoded) {
  return base64Coder.decode(encoded);
}

// 将base64字符串转为不编码的字符串
String b64decode(String encoded) {
  var decodeBytes = convert.base64.decode(encoded);
  return String.fromCharCodes(decodeBytes);
}

Uint8List b64decodeRaw(String encoded) {
  return convert.base64.decode(encoded);
}
