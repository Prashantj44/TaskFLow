import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _quoteUrl = 'https://dummyjson.com/quotes/random';

  // Fallback quotes in case the API is down during your demo
  final List<Map<String, String>> _fallbackQuotes = [
    {'quote': 'The only way to do great work is to love what you do.', 'author': 'Steve Jobs'},
    {'quote': 'Believe you can and you\'re halfway there.', 'author': 'Theodore Roosevelt'},
    {'quote': 'Don\'t watch the clock; do what it does. Keep going.', 'author': 'Sam Levenson'},
    {'quote': 'Everything you\'ve ever wanted is on the other side of fear.', 'author': 'George Addair'},
    {'quote': 'Your time is limited, so don\'t waste it living someone else\'s life.', 'author': 'Steve Jobs'},
  ];

  Future<Map<String, String>> fetchQuote() async {
    try {
      final response = await http.get(Uri.parse(_quoteUrl)).timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'quote': data['quote'],
          'author': data['author'],
        };
      }
    } catch (e) {
      // Fall through to local quotes on any error
    }
    
    // If API fails or times out, return a random beautiful local quote
    return _fallbackQuotes[Random().nextInt(_fallbackQuotes.length)];
  }
}
