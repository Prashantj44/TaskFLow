import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _quoteUrl = 'https://api.quotable.io/random';

  Future<Map<String, String>> fetchQuote() async {
    try {
      final response = await http.get(Uri.parse(_quoteUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'quote': data['content'],
          'author': data['author'],
        };
      } else {
        return {
          'quote': 'Could not fetch quote at this time.',
          'author': 'System',
        };
      }
    } catch (e) {
      return {
        'quote': 'Could not connect to the quote service.',
        'author': 'System',
      };
    }
  }
}
