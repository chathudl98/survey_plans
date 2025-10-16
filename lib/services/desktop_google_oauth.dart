// Desktop Google OAuth (loopback + PKCE), with optional client_secret support.
// If clientSecret is provided (non-empty), it will be sent in the token request.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DesktopGoogleOAuth {
  DesktopGoogleOAuth({
    required this.clientId,
    this.clientSecret = '',
    this.scopes = const ['openid','email','profile'],
  });

  final String clientId;          // Google OAuth 2.0 Client ID (Desktop app)
  final String clientSecret;      // Optional; some desktop clients include this
  final List<String> scopes;

  Future<Map<String, String>> signIn() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0, shared: false);
    final redirectUri = 'http://127.0.0.1:${server.port}';

    final verifier = _createCodeVerifier();
    final challenge = _codeChallenge(verifier);

    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': scopes.join(' '),
      'access_type': 'offline',
      'prompt': 'consent',
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
    });

    final ok = await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    if (!ok) {
      server.close(force: true);
      throw 'Could not launch browser for Google login.';
    }

    final code = await _waitForCode(server);
    server.close(force: true);

    final body = {
      'client_id': clientId,
      'code': code,
      'code_verifier': verifier,
      'redirect_uri': redirectUri,
      'grant_type': 'authorization_code',
    };
    if (clientSecret.isNotEmpty) {
      body['client_secret'] = clientSecret;
    }

    final tokenResp = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    if (tokenResp.statusCode != 200) {
      throw 'Token exchange failed: ${tokenResp.statusCode} ${tokenResp.body}';
    }
    final map = json.decode(tokenResp.body) as Map<String, dynamic>;
    final idToken = map['id_token'] as String?;
    final accessToken = map['access_token'] as String?;
    if (idToken == null || accessToken == null) {
      throw 'Missing id_token or access_token in token response';
    }
    return {'idToken': idToken, 'accessToken': accessToken};
  }

  Future<String> _waitForCode(HttpServer server, {Duration timeout = const Duration(minutes: 3)}) async {
    final completer = Completer<String>();
    late StreamSubscription sub;
    sub = server.listen((HttpRequest req) async {
      try {
        final code = req.uri.queryParameters['code'];
        final err = req.uri.queryParameters['error'];
        if (err != null) {
          _writeHtml(req, 400, '<h3>Sign-in failed</h3><p>${Uri.decodeComponent(err)}</p>');
          if (!completer.isCompleted) completer.completeError('OAuth error: $err');
          return;
        }
        if (code != null) {
          _writeHtml(req, 200, '<h3>Login complete</h3><p>You can close this window.</p>');
          if (!completer.isCompleted) completer.complete(code);
          return;
        }
        _writeHtml(req, 404, '<p>Not found</p>');
      } finally {
        await req.response.close();
      }
    });

    Future.delayed(timeout, () {
      try { sub.cancel(); } catch (_) {}
      if (!completer.isCompleted) completer.completeError('Timed out waiting for authentication');
    });

    return completer.future;
  }

  void _writeHtml(HttpRequest req, int status, String body) {
    req.response.statusCode = status;
    req.response.headers.contentType = ContentType.html;
    req.response.write('<!doctype html><html><body style="font-family: system-ui; padding: 24px;">$body</body></html>');
  }

  String _createCodeVerifier() {
    final r = Random.secure();
    final bytes = List<int>.generate(32, (_) => r.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  String _codeChallenge(String verifier) {
    final bytes = ascii.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
}
