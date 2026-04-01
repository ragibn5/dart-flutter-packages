abstract interface class Parser<D, E> {
  /// Encode the value.
  E encode(D value);

  /// Decode the encoded value.
  D decode(E encoded);
}
