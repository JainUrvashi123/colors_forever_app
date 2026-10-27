import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../../../../core/network/session_manager.dart';

class ContactSubmitResponse {
  final int status;
  final String message;
  final int? contactId;
  final int? emailSent;

  ContactSubmitResponse({
    required this.status,
    required this.message,
    this.contactId,
    this.emailSent,
  });

  factory ContactSubmitResponse.fromJson(Map<String, dynamic> json) {
    return ContactSubmitResponse(
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
      contactId: json['contact_id'] is int
          ? json['contact_id']
          : int.tryParse(json['contact_id']?.toString() ?? ''),
      emailSent: json['email_sent'] is int
          ? json['email_sent']
          : int.tryParse(json['email_sent']?.toString() ?? ''),
    );
  }
}

class ContactRemoteDataSource {
  static const String contactSubmitUrl =
      'https://colorsforever.com/api/contact-submit';

  final http.Client _client;

  static http.Client _createCustomClient() {
    try {
      final ioClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      return IOClient(ioClient);
    } catch (_) {
      return http.Client();
    }
  }

  ContactRemoteDataSource({http.Client? client})
      : _client = client ?? _createCustomClient();

  /// POST https://colorsforever.com/api/contact-submit
  Future<ContactSubmitResponse> submitContactForm({
    required String fullname,
    required String email,
    required String mobile,
    required String companyName,
    required String companyAddress,
    required String subject,
    required String message,
  }) async {
    final uri = Uri.parse(contactSubmitUrl);

    final body = jsonEncode({
      'fullname': fullname,
      'email': email,
      'mobile': mobile,
      'company_name': companyName,
      'company_address': companyAddress,
      'subject': subject,
      'message': message,
    });

    final response = await _client.post(
      uri,
      headers: SessionManager.getHeaders(isJson: true),
      body: body,
    );

    SessionManager.updateCookieFromResponse(response.headers);

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return ContactSubmitResponse.fromJson(jsonResponse);
  }
}
