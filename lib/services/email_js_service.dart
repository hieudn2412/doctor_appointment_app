import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:doctor_appointment_app/config/app_env.dart';
import 'package:http/http.dart' as http;

abstract class EmailOtpService {
  Future<void> sendResetOtp({
    required String toEmail,
    required String otpCode,
    required DateTime expiresAt,
  });
}

class EmailOtpException implements Exception {
  const EmailOtpException(this.message);

  final String message;

  @override
  String toString() => message;
}

class EmailJsService implements EmailOtpService {
  EmailJsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _requestTimeout = Duration(seconds: 12);

  @override
  Future<void> sendResetOtp({
    required String toEmail,
    required String otpCode,
    required DateTime expiresAt,
  }) async {
    if (!AppEnv.isEmailJsConfigured) {
      throw const EmailOtpException(
        'EmailJS chưa cấu hình. Vui lòng cập nhật file .env',
      );
    }

    final payload = <String, dynamic>{
      'service_id': AppEnv.emailJsServiceId,
      'template_id': AppEnv.emailJsTemplateId,
      'user_id': AppEnv.emailJsPublicKey,
      'template_params': <String, dynamic>{
        // Keep multiple aliases so template mapping does not break.
        'to_email': toEmail,
        'email': toEmail,
        'to_name': toEmail.split('@').first,
        'otp_code': otpCode,
        'otp': otpCode,
        'passcode': otpCode,
        'subject': '[${AppEnv.emailJsAppName}] Password Reset OTP',
        'app_name': AppEnv.emailJsAppName,
        'company_name': AppEnv.emailJsAppName,
        'expire_minutes': '10',
        'time': _formatExpiry(expiresAt),
      },
    };

    if (AppEnv.emailJsPrivateKey.isNotEmpty) {
      payload['accessToken'] = AppEnv.emailJsPrivateKey;
    }

    try {
      final response = await _client
          .post(
            Uri.parse(AppEnv.emailJsApiUrl),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = response.body.trim();
        throw EmailOtpException(
          'EmailJS trả về lỗi ${response.statusCode}${body.isEmpty ? '' : ': $body'}',
        );
      }
    } on TimeoutException {
      throw const EmailOtpException(
        'Gửi OTP quá thời gian chờ. Vui lòng kiểm tra mạng và thử lại.',
      );
    } on SocketException {
      throw const EmailOtpException(
        'Không có kết nối mạng. Vui lòng kiểm tra Internet và thử lại.',
      );
    } on http.ClientException catch (e) {
      throw EmailOtpException('Lỗi kết nối EmailJS: ${e.message}');
    }
  }

  String _formatExpiry(DateTime dt) {
    final d = dt.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$mi';
  }
}
