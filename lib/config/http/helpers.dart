bool isValidUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && uri.hasScheme && uri.hasAuthority;
}
