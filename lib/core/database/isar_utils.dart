/// Generates a fast 32-bit hash to be used as an Isar ID from a String UUID.
int fastHash(String string) {
  var hash = 0x811c9dc5;
  for (var i = 0; i < string.length; i++) {
    hash ^= string.codeUnitAt(i);
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}
