import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  static String _read(String key, {String fallback = ''}) {
    try {
      return dotenv.env[key]?.trim() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  // EmailJS
  static String get emailJsApiUrl =>
      _read('EMAILJS_API_URL', fallback: 'https://api.emailjs.com/api/v1.0/email/send');
  static String get emailJsServiceId => _read('EMAILJS_SERVICE_ID');
  static String get emailJsTemplateId => _read('EMAILJS_TEMPLATE_ID');
  static String get emailJsPublicKey => _read('EMAILJS_PUBLIC_KEY');
  static String get emailJsPrivateKey => _read('EMAILJS_PRIVATE_KEY');
  static String get emailJsAppName =>
      _read('EMAILJS_APP_NAME', fallback: 'Doctor Appointment App');

  static bool get isEmailJsConfigured =>
      emailJsServiceId.isNotEmpty &&
      emailJsTemplateId.isNotEmpty &&
      emailJsPublicKey.isNotEmpty;

  // Google OAuth
  static String get googleOauthWebClientId =>
      _read('GOOGLE_OAUTH_WEB_CLIENT_ID');
  static String get googleOauthAndroidClientId =>
      _read('GOOGLE_OAUTH_ANDROID_CLIENT_ID');
  static String get googleOauthAndroidPackageName =>
      _read('GOOGLE_OAUTH_ANDROID_PACKAGE_NAME');
  static String get googleOauthAndroidSha1 =>
      _read('GOOGLE_OAUTH_ANDROID_SHA1');

  static bool get isGoogleConfigured =>
      googleOauthWebClientId.isNotEmpty &&
      googleOauthAndroidClientId.isNotEmpty &&
      googleOauthAndroidPackageName.isNotEmpty &&
      googleOauthAndroidSha1.isNotEmpty;
}
