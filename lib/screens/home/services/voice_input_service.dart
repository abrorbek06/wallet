import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceInputService {
  static const String _openAIApiKey = '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';
  static const String _openAIBaseUrl = 'https://api.openai.com/v1';
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  bool _isInitialized = false;

  Future<bool> initialize() async {
    try {
      // Check current permission status first
      PermissionStatus status = await Permission.microphone.status;
      print('Current microphone permission status: $status');
      
      // If permission is denied, request it
      if (status.isDenied) {
        status = await Permission.microphone.request();
        print('Permission request result: $status');
      }
      
      // Handle different permission states
      if (status.isPermanentlyDenied) {
        print('Microphone permission permanently denied - user needs to enable in settings');
        return false;
      }
      
      if (status.isDenied) {
        print('Microphone permission denied by user');
        return false;
      }
      
      if (status.isGranted) {
        print('Microphone permission granted, initializing speech recognition...');
        
        // Initialize speech to text with better error handling
        bool available = await _speech.initialize(
          onStatus: (status) {
            print('Speech recognition status: $status');
            if (status == 'notListening') {
              _isListening = false;
            }
          },
          onError: (error) {
            print('Speech recognition error: ${error.errorMsg}');
            _isListening = false;
          },
          debugLogging: true, // Enable debug logging
        );
        
        if (available) {
          _isInitialized = true;
          print('Speech recognition initialized successfully');
          return true;
        } else {
          print('Speech recognition not available on this device');
          return false;
        }
      }
      
      print('Microphone permission status unclear: $status');
      return false;
      
    } catch (e) {
      print('Error during initialization: $e');
      return false;
    }
  }

  Future<PermissionStatus> getPermissionStatus() async {
    return await Permission.microphone.status;
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
  }) async {
    try {
      // Double-check initialization before starting
      if (!_isInitialized) {
        bool initialized = await initialize();
        if (!initialized) {
          onError('Voice recognition not available. Please check microphone permissions.');
          return;
        }
      }

      if (!_isListening && _speech.isAvailable) {
        _isListening = true;
        print('Starting to listen...');
        
        await _speech.listen(
          onResult: (result) {
            _lastWords = result.recognizedWords;
            print('Recognized words: $_lastWords (confidence: ${result.confidence})');
            
            if (result.finalResult) {
              _isListening = false;
              print('Final result: $_lastWords');
              onResult(_lastWords);
            }
          },
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 3),
          partialResults: true,
          localeId: 'en_US',
          onSoundLevelChange: (level) {
            // Only log significant sound level changes to reduce noise
            if (level > 0.5) {
              print('Sound level: $level');
            }
          },
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      } else if (!_speech.isAvailable) {
        onError('Speech recognition is not available');
      } else {
        onError('Already listening');
      }
    } catch (e) {
      print('Error starting listening: $e');
      _isListening = false;
      onError('Error starting speech recognition: $e');
    }
  }

  // Stop listening
  void stopListening() {
    if (_isListening) {
      print('Stopping speech recognition...');
      _speech.stop();
      _isListening = false;
    }
  }

  Future<TransactionData?> processVoiceInput(String voiceText) async {
    if (voiceText.trim().isEmpty) {
      print('Empty voice input received');
      return null;
    }
    
    print('Processing voice input: $voiceText');
    
    // First try local processing for testing
    final localResult = _parseVoiceInputLocally(voiceText);
    if (localResult != null) {
      print('Local parsing successful');
      return localResult;
    }
    
    // If local parsing fails, try OpenAI
    try {
      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a financial assistant that extracts transaction information from voice input. 
              Extract the following information and return ONLY a valid JSON object:
              {
                "type": "income" or "expense",
                "amount": numeric value,
                "description": "brief description",
                "category": "suggested category name",
                "confidence": 0.0 to 1.0
              }
              
              Common categories:
              Income: Salary, Freelance, Investment, Business, Other Income
              Expense: Food & Dining, Transportation, Shopping, Entertainment, Bills & Utilities, Healthcare, Education, Travel
              
              If the input is unclear or not a financial transaction, return:
              {"error": "Unable to parse transaction information"}'''
            },
            {
              'role': 'user',
              'content': voiceText
            }
          ],
          'max_tokens': 150,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        try {
          final transactionJson = jsonDecode(content);
          
          if (transactionJson.containsKey('error')) {
            print('OpenAI could not parse transaction: ${transactionJson['error']}');
            return null;
          }
          
          return TransactionData.fromJson(transactionJson);
        } catch (e) {
          print('Error parsing OpenAI response: $e');
          return null;
        }
      } else {
        print('OpenAI API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error processing voice input with OpenAI: $e');
      return null;
    }
  }


  TransactionData? _parseVoiceInputLocally(String text) {
    text = text.toLowerCase().trim();
    print('Local parsing for: $text');
    
    if (text.isEmpty) return null;
    
    // Determine type
    String type = 'expense';
    if (text.contains('received') || text.contains('earned') || 
        text.contains('salary') || text.contains('income') ||
        text.contains('got') || text.contains('paid me') ||
        text.contains('made') || text.contains('profit')) {
      type = 'income';
    }
    
    // Extract amount using multiple patterns
    RegExp amountRegex = RegExp(r'(\d+(?:\.\d{1,2})?)');
    Match? amountMatch = amountRegex.firstMatch(text);
    double amount = 0.0;
    if (amountMatch != null) {
      amount = double.tryParse(amountMatch.group(1) ?? '0') ?? 0.0;
    }
    
    // Extract description
    String description = text;
    if (text.contains('spent') && text.contains('on')) {
      int onIndex = text.indexOf('on');
      if (onIndex != -1) {
        description = text.substring(onIndex + 3).trim();
      }
    } else if (text.contains('paid') && text.contains('for')) {
      int forIndex = text.indexOf('for');
      if (forIndex != -1) {
        description = text.substring(forIndex + 4).trim();
      }
    } else if (text.contains('bought')) {
      int boughtIndex = text.indexOf('bought');
      if (boughtIndex != -1) {
        description = text.substring(boughtIndex + 7).trim();
      }
    }
    
    // Clean up description
    description = description.replaceAll(RegExp(r'\d+(\.\d{1,2})?\s*(dollars?|usd|\$)'), '').trim();
    if (description.isEmpty) {
      description = type == 'income' ? 'Income' : 'Expense';
    }
    
    // Suggest category with better matching
    String category = 'Other';
    if (text.contains('food') || text.contains('lunch') || text.contains('dinner') || 
        text.contains('restaurant') || text.contains('eat') || text.contains('meal')) {
      category = 'Food & Dining';
    } else if (text.contains('gas') || text.contains('fuel') || text.contains('transport') ||
               text.contains('uber') || text.contains('taxi') || text.contains('bus')) {
      category = 'Transportation';
    } else if (text.contains('salary') || text.contains('work') || text.contains('job') ||
               text.contains('paycheck')) {
      category = 'Salary';
    } else if (text.contains('shop') || text.contains('buy') || text.contains('purchase') ||
               text.contains('store')) {
      category = 'Shopping';
    } else if (text.contains('bill') || text.contains('utility') || text.contains('electric') ||
               text.contains('water') || text.contains('internet')) {
      category = 'Bills & Utilities';
    } else if (text.contains('freelance') || text.contains('contract') || text.contains('gig')) {
      category = 'Freelance';
    }
    
    if (amount > 0) {
      print('Parsed: type=$type, amount=$amount, description=$description, category=$category');
      return TransactionData(
        type: type,
        amount: amount,
        description: description,
        category: category,
        confidence: 0.8,
      );
    }
    
    print('Failed to parse amount from: $text');
    return null;
  }


  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  bool get isInitialized => _isInitialized;
}

// Data class for parsed transaction information
class TransactionData {
  final String type;
  final double amount;
  final String description;
  final String category;
  final double confidence;

  TransactionData({
    required this.type,
    required this.amount,
    required this.description,
    required this.category,
    required this.confidence,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      type: json['type'] ?? 'expense',
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'description': description,
      'category': category,
      'confidence': confidence,
    };
  }
}
