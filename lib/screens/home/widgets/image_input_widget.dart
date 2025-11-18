import 'dart:io';
import 'package:app/models/themes.dart';
import 'package:app/services/currency_service.dart';
import 'package:app/screens/home/services/voice_input_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../l10n/app_localizations.dart';
import '../services/image_ocr_service.dart';

class ImageInputWidget extends StatefulWidget {
  final Function(List<TransactionData>) onTransactionsExtracted;
  final VoidCallback onClose;
  final bool showBackButton;

  const ImageInputWidget({
    super.key,
    required this.onTransactionsExtracted,
    required this.onClose,
    this.showBackButton = false,
  });

  @override
  _ImageInputWidgetState createState() => _ImageInputWidgetState();
}

class _ImageInputWidgetState extends State<ImageInputWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;
  String _status = '';
  List<TransactionData> _extractedTransactions = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                if (widget.showBackButton)
                  IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(
                      Icons.arrow_back,
                      color: ThemeProvider.getTextColor(),
                    ),
                  ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).t('image_transaction_title'),
                    style: TextStyle(
                      color: ThemeProvider.getTextColor(),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(Icons.close, color: Colors.grey[400]),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Image Preview or Placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child:
                  _selectedImage != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.fill),
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).t('upload_receipt_placeholder'),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).t('supports_receipts_hint'),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
            ),
            SizedBox(height: 20),

            // Action Buttons
            if (!_isProcessing) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      label: Text(
                        AppLocalizations.of(context).t('camera'),
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeProvider.getPrimaryColor(),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo_library, color: Colors.white),
                      label: Text(
                        AppLocalizations.of(context).t('gallery'),
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedImage != null) ...[
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _processImage,
                    icon: Icon(Icons.auto_awesome, color: Colors.white),
                    label: Text(
                      AppLocalizations.of(context).t('extract_transactions'),
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],

            // Processing Indicator
            if (_isProcessing) ...[
              Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeProvider.getPrimaryColor(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).t('processing_image'),
                    style: TextStyle(
                      color: ThemeProvider.getTextColor(),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).t('extracting_text'),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ],

            SizedBox(height: 16),

            // Status Message
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    _extractedTransactions.isNotEmpty
                        ? Colors.green.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      _extractedTransactions.isNotEmpty
                          ? Colors.green.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _extractedTransactions.isNotEmpty
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    color:
                        _extractedTransactions.isNotEmpty
                            ? Colors.green
                            : Colors.blue,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _status.isNotEmpty
                          ? _status
                          : AppLocalizations.of(
                            context,
                          ).t('select_image_prompt'),
                      style: TextStyle(
                        color: ThemeProvider.getTextColor(),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Extracted Transactions Preview
            if (_extractedTransactions.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)
                    .t('found_transactions')
                    .replaceFirst(
                      '{n}',
                      _extractedTransactions.length.toString(),
                    ),
                style: TextStyle(
                  color: ThemeProvider.getTextColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(maxHeight: 150),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _extractedTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _extractedTransactions[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            transaction.type == 'income'
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color:
                                transaction.type == 'income'
                                    ? Colors.green
                                    : Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.description,
                                  style: TextStyle(
                                    color: ThemeProvider.getTextColor(),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${transaction.category} • ${CurrencyService.instance.formatAmount(transaction.amount)}',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onTransactionsExtracted(_extractedTransactions);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).t('add_all_transactions'),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _extractedTransactions.clear();
          _status = AppLocalizations.of(context).t('image_selected_prompt');
        });
      }
    } catch (e) {
      setState(() {
        _status = '${AppLocalizations.of(context).t('error')} ${e.toString()}';
      });
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _status = AppLocalizations.of(context).t('processing_image');
    });

    try {
      // Extract text from image
      String extractedText = await ImageOCRService.extractTextFromImage(
        _selectedImage!,
      );

      if (extractedText.isEmpty) {
        setState(() {
          _isProcessing = false;
          _status = AppLocalizations.of(context).t('no_text_found');
        });
        return;
      }

      // Parse transactions from extracted text
      List<TransactionData> transactions =
          await ImageOCRService.parseTransactionsFromText(extractedText);

      setState(() {
        _isProcessing = false;
        _extractedTransactions = transactions;
        if (transactions.isEmpty) {
          _status = AppLocalizations.of(
            context,
          ).t('no_transactions_found_image');
        } else {
          _status = AppLocalizations.of(context)
              .t('found_transactions')
              .replaceFirst('{n}', transactions.length.toString());
        }
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = '${AppLocalizations.of(context).t('error')} ${e.toString()}';
      });
    }
  }
}
