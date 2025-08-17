import 'dart:io';
import 'package:app/screens/home/services/voice_input_service.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class ImageOCRService {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  static Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      return recognizedText.text;
    } catch (e) {
      print('Error extracting text from image: $e');
      return '';
    }
  }

  static Future<List<TransactionData>> parseTransactionsFromText(String text) async {
    List<TransactionData> transactions = [];
    
    // Split text into lines for processing
    List<String> lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    for (String line in lines) {
      TransactionData? transaction = _parseTransactionFromLine(line);
      if (transaction != null) {
        transactions.add(transaction);
      }
    }
    
    return transactions;
  }

  static TransactionData? _parseTransactionFromLine(String line) {
    // Clean the line
    line = line.trim().toLowerCase();
    
    // Skip if line is too short or doesn't contain relevant keywords
    if (line.length < 5) return null;
    
    // Look for amount patterns (numbers with currency symbols or decimal points)
    RegExp amountPattern = RegExp(r'[\$€£¥₹]?\s*(\d+(?:[.,]\d{2})?)\s*[\$€£¥₹]?');
    Match? amountMatch = amountPattern.firstMatch(line);
    
    if (amountMatch == null) return null;
    
    double amount;
    try {
      String amountStr = amountMatch.group(1)!.replaceAll(',', '.');
      amount = double.parse(amountStr);
    } catch (e) {
      return null;
    }
    
    // Determine transaction type based on keywords
    String type = _determineTransactionType(line);
    
    // Extract description (remove amount and common prefixes)
    String description = _extractDescription(line, amountMatch.group(0)!);
    
    // Determine category based on description
    String category = _determineCategory(description, type);
    
    return TransactionData(
      description: description,
      amount: amount,
      type: type,
      category: category, confidence: 0.0,
    );
  }

  static String _determineTransactionType(String line) {
    // Income keywords
    List<String> incomeKeywords = [
      'salary', 'wage', 'income', 'payment received', 'deposit', 'refund',
      'bonus', 'commission', 'dividend', 'interest', 'cashback', 'reward'
    ];
    
    // Expense keywords
    List<String> expenseKeywords = [
      'purchase', 'payment', 'bill', 'fee', 'charge', 'cost', 'expense',
      'withdrawal', 'debit', 'spent', 'paid', 'bought', 'subscription'
    ];
    
    for (String keyword in incomeKeywords) {
      if (line.contains(keyword)) {
        return 'income';
      }
    }
    
    for (String keyword in expenseKeywords) {
      if (line.contains(keyword)) {
        return 'expense';
      }
    }
    
    // Default to expense if unclear
    return 'expense';
  }

  static String _extractDescription(String line, String amountStr) {
    // Remove the amount from the line
    String description = line.replaceAll(amountStr.toLowerCase(), '').trim();
    
    // Remove common prefixes and suffixes
    List<String> prefixesToRemove = [
      'payment to', 'payment for', 'purchase at', 'bought from', 'paid to',
      'transaction:', 'description:', 'item:', 'service:', 'product:'
    ];
    
    for (String prefix in prefixesToRemove) {
      if (description.startsWith(prefix)) {
        description = description.substring(prefix.length).trim();
        break;
      }
    }
    
    // Capitalize first letter
    if (description.isNotEmpty) {
      description = description[0].toUpperCase() + description.substring(1);
    }
    
    return description.isEmpty ? 'Transaction from image' : description;
  }

  static String _determineCategory(String description, String type) {
    description = description.toLowerCase();
    
    if (type == 'income') {
      if (description.contains('salary') || description.contains('wage')) return 'Salary';
      if (description.contains('bonus')) return 'Bonus';
      if (description.contains('investment') || description.contains('dividend')) return 'Investment';
      return 'Other Income';
    } else {
      // Expense categories
      if (description.contains('food') || description.contains('restaurant') || 
          description.contains('lunch') || description.contains('dinner') ||
          description.contains('grocery') || description.contains('supermarket')) {
        return 'Food';
      }
      
      if (description.contains('transport') || description.contains('uber') ||
          description.contains('taxi') || description.contains('bus') ||
          description.contains('train') || description.contains('fuel') ||
          description.contains('gas') || description.contains('parking')) {
        return 'Transportation';
      }
      
      if (description.contains('shopping') || description.contains('clothes') ||
          description.contains('amazon') || description.contains('store')) {
        return 'Shopping';
      }
      
      if (description.contains('bill') || description.contains('electricity') ||
          description.contains('water') || description.contains('internet') ||
          description.contains('phone') || description.contains('utility')) {
        return 'Bills';
      }
      
      if (description.contains('entertainment') || description.contains('movie') ||
          description.contains('game') || description.contains('netflix') ||
          description.contains('spotify')) {
        return 'Entertainment';
      }
      
      if (description.contains('health') || description.contains('medical') ||
          description.contains('doctor') || description.contains('pharmacy') ||
          description.contains('hospital')) {
        return 'Healthcare';
      }
      
      return 'Other';
    }
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
