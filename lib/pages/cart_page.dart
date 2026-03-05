import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const Color vintagePaper = Color(0xFFF4E4BC);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color textDark = Color(0xFF2C1810);

  String _orderType = 'Dine-in';
  String? _selectedTable;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  final List<String> _tableOptions = [
    'A1',
    'A2',
    'A3',
    'A4',
    'B1',
    'B2',
    'B3',
    'B4',
    'B5',
    'B6',
    'C1',
    'C2',
    'C3',
    'C4',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder(CartService cart) async {
    // Validate
    if (_orderType == 'Dine-in' && _selectedTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'กรุณาเลือกเบอร์โต๊ะก่อนสั่งอาหาร (Please select a table)',
          ),
        ),
      );
      return;
    }
    if (_orderType == 'Takeaway' &&
        (_nameController.text.isEmpty || _timeController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'กรุณากรอกชื่อและเวลามารับ (Please enter name and pickup time)',
          ),
        ),
      );
      return;
    }

    // Build the message
    final sb = StringBuffer();
    sb.writeln('🛒 รายการสั่งอาหาร');
    sb.writeln('------------------------');

    if (_orderType == 'Dine-in') {
      sb.writeln('📍 รูปแบบ: ทานที่ร้าน');
      sb.writeln('🪑 โต๊ะที่: $_selectedTable');
    } else {
      sb.writeln('📦 รูปแบบ: รับกลับบ้าน (Takeaway)');
      sb.writeln('👤 ชื่อผู้รับ: ${_nameController.text}');
      sb.writeln('⏰ เวลามารับ: ${_timeController.text}');
    }

    sb.writeln('------------------------');
    for (int i = 0; i < cart.items.length; i++) {
      final item = cart.items[i];
      final optionText =
          item.optionLabel != null ? ' (${item.optionLabel})' : '';
      sb.writeln(
        '${i + 1}. ${item.name}$optionText x ${item.quantity} (${item.totalPrice}฿)',
      );
    }
    sb.writeln('------------------------');
    sb.writeln('💰 ยอดรวม: ${cart.totalPrice} บาท');

    // Launch LINE
    // URL Encode the message
    final encodedMessage = Uri.encodeComponent(sb.toString());
    final url = Uri.parse(
      'https://line.me/R/oaMessage/@158butwc/?$encodedMessage',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for some web browsers
        await launchUrl(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถเปิดแอป LINE ได้ (Cannot open LINE)'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vintagePaper,
      appBar: AppBar(
        title: Text(
          'YOUR CART',
          style: GoogleFonts.cinzel(
            color: goldAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2C1810),
        iconTheme: const IconThemeData(color: goldAccent),
        elevation: 0,
      ),
      body: Consumer<CartService>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: goldAccent.withOpacity(0.5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.lora(fontSize: 18, color: textDark),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C1810),
                      foregroundColor: goldAccent,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Menu'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder:
                      (context, index) =>
                          Divider(color: goldAccent.withOpacity(0.3)),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: GoogleFonts.lora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                              if (item.optionLabel != null)
                                Text(
                                  item.optionLabel!,
                                  style: GoogleFonts.lora(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              Text(
                                '${item.unitPrice}฿',
                                style: GoogleFonts.montserrat(
                                  color: goldAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: textDark,
                              ),
                              onPressed:
                                  () => cart.updateQuantity(
                                    item.id,
                                    item.quantity - 1,
                                  ),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: textDark,
                              ),
                              onPressed:
                                  () => cart.updateQuantity(
                                    item.id,
                                    item.quantity + 1,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              _buildCheckoutSection(cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckoutSection(CartService cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -5),
            blurRadius: 10,
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Type Selector
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text(
                      'Dine-in\n(ทานที่ร้าน)',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: 'Dine-in',
                    groupValue: _orderType,
                    activeColor: goldAccent,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) => setState(() => _orderType = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text(
                      'Takeaway\n(รับกลับบ้าน)',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: 'Takeaway',
                    groupValue: _orderType,
                    activeColor: goldAccent,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) => setState(() => _orderType = value!),
                  ),
                ),
              ],
            ),

            // Conditional Inputs
            if (_orderType == 'Dine-in')
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Table (เลือกเบอร์โต๊ะ)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                ),
                value: _selectedTable,
                items:
                    _tableOptions
                        .map(
                          (table) => DropdownMenuItem(
                            value: table,
                            child: Text(table),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedTable = val),
              )
            else
              Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name (ชื่อผู้รับ)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Pickup Time (เวลามารับ เช่น 12:30)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: GoogleFonts.cinzel(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                Text(
                  '${cart.totalPrice} ฿',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: goldAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B900), // LINE Green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _submitOrder(cart),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline),
                  const SizedBox(width: 8),
                  Text(
                    'Order via LINE',
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
