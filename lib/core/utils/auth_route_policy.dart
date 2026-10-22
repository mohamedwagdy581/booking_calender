String? authRouteRedirect(String path, {required bool signedIn}) {
  const publicRoutes = {'/splash', '/login', '/forgot-password'};
  if (!signedIn && !publicRoutes.contains(path)) return '/login';
  if (signedIn && path == '/login') return '/home';
  return null;
}
