import 'package:app/models/themes.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/voice_input_service.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(TransactionData) onTransactionAdded;
  final VoidCallback? onClose;
  final bool showBackButton;

  const VoiceInputWidget({
    super.key,
    required this.onTransactionAdded,
    this.onClose,
    this.showBackButton = false,
  });

  @override
  _VoiceInputWidgetState createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with TickerProviderStateMixin {
  final VoiceInputService _voiceService = VoiceInputService();
  late AnimationController _animationController;
  late AnimationController _pulseController;

  bool _isInitialized = false;
  bool _isListening = false;
  String _currentText = '';
  String _status = '';
  TransactionData? _parsedTransaction;
  bool _isProcessing = false;
  PermissionStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _initializeVoiceService();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _voiceService.stopListening();
    super.dispose();
  }

  Future<void> _initializeVoiceService() async {
    setState(() {
      _status = AppLocalizations.of(context).t('checking_permissions');
    });

    // Check permission status first
    final permissionStatus = await _voiceService.getPermissionStatus();
    setState(() {
      _permissionStatus = permissionStatus;
    });

    if (permissionStatus.isPermanentlyDenied) {
      setState(() {
        _status = AppLocalizations.of(context).t('mic_perm_permanently_denied');
        _isInitialized = false;
      });
      return;
    }

    final initialized = await _voiceService.initialize();
    setState(() {
      _isInitialized = initialized;
      if (initialized) {
        _status = AppLocalizations.of(context).t('tap_to_start_speaking');
      } else {
        if (permissionStatus.isDenied) {
          _status = AppLocalizations.of(
            context,
          ).t('mic_permission_required_request');
        } else {
          _status = AppLocalizations.of(
            context,
          ).t('voice_recognition_unavailable');
        }
      }
    });
  }

  Future<void> _handlePermissionRequest() async {
    if (_permissionStatus?.isPermanentlyDenied == true) {
      // Show dialog to go to settings
      _showPermissionDialog();
      return;
    }

    // Try to initialize again (this will request permission)
    await _initializeVoiceService();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context).t('microphone_permission'),
            ),
            content: Text(
              AppLocalizations.of(context).t('microphone_permission_needed'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).t('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text(AppLocalizations.of(context).t('open_settings')),
              ),
            ],
          ),
    );
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) {
      await _handlePermissionRequest();
      return;
    }

    if (_isListening) {
      _voiceService.stopListening();
      setState(() {
        _isListening = false;
        _status = AppLocalizations.of(context).t('processing');
        _isProcessing = true;
      });
      _animationController.reverse();

      if (_currentText.isNotEmpty) {
        await _processVoiceInput(_currentText);
      } else {
        setState(() {
          _isProcessing = false;
          _status = AppLocalizations.of(context).t('no_speech_detected');
        });
      }
    } else {
      setState(() {
        _currentText = '';
        _parsedTransaction = null;
        _status = AppLocalizations.of(context).t('listening_prompt');
        _isListening = true;
      });
      _animationController.forward();

      await _voiceService.startListening(
        onResult: (text) {
          setState(() {
            _currentText = text;
          });
        },
        onError: (error) {
          setState(() {
            _status = '${AppLocalizations.of(context).t('error')} $error';
            _isListening = false;
            _isProcessing = false;
          });
          _animationController.reverse();
        },
      );
    }
  }

  Future<void> _processVoiceInput(String text) async {
    final transactionData = await _voiceService.processVoiceInput(text);

    setState(() {
      _isProcessing = false;
      if (transactionData != null) {
        _parsedTransaction = transactionData;
        _status = AppLocalizations.of(context).t('transaction_parsed_success');
      } else {
        _status = AppLocalizations.of(
          context,
        ).t('could_not_understand_transaction');
      }
    });
  }

  void _confirmTransaction() {
    if (_parsedTransaction == null) return;

    widget.onTransactionAdded(_parsedTransaction!);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).t('transaction_added')),
        backgroundColor: Colors.green,
      ),
    );

    // Close the widget
    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              if (widget.showBackButton)
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.grey[400]),
                  onPressed: widget.onClose,
                ),
              Icon(Icons.mic, color: Colors.blue, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).t('voice_input_title'),
                  style: TextStyle(
                    color: ThemeProvider.getTextColor(),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.onClose != null && !widget.showBackButton)
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[400]),
                  onPressed: widget.onClose,
                ),
            ],
          ),
          SizedBox(height: 24),

          // Voice Animation
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _isListening
                            ? Colors.red.withOpacity(
                              0.1 + (_pulseController.value * 0.2),
                            )
                            : Colors.blue.withOpacity(0.1),
                    border: Border.all(
                      color: _isListening ? Colors.red : Colors.blue,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 48,
                    color: _isListening ? Colors.red : Colors.blue,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24),

          // Status Text
          Text(
            _status,
            style: TextStyle(
              color: ThemeProvider.getTextColor(),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),

          // ... existing code for current text, processing indicator, and parsed transaction preview ...
          SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              if (_parsedTransaction == null) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isInitialized || _permissionStatus?.isDenied == true
                            ? _toggleListening
                            : null,
                    icon: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isListening
                          ? AppLocalizations.of(context).t('stop')
                          : _isInitialized
                          ? AppLocalizations.of(context).t('start')
                          : AppLocalizations.of(
                            context,
                          ).t('request_permission'),
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening ? Colors.red : Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _parsedTransaction = null;
                        _currentText = '';
                        _status = AppLocalizations.of(
                          context,
                        ).t('tap_to_start_speaking');
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeProvider.getTextColor(),
                      side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context).t('try_again')),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirmTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).t('add_transaction'),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // ... existing code for examples ...
        ],
      ),
    );
  }
}
