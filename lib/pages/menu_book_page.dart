import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';
import 'package:provider/provider.dart';
import 'data/menu_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/cart_service.dart';
import 'cart_page.dart';

class MenuBookPage extends StatefulWidget {
  const MenuBookPage({super.key});

  @override
  State<MenuBookPage> createState() => _MenuBookPageState();
}

class _MenuBookPageState extends State<MenuBookPage> {
  final _controller = GlobalKey<PageFlipWidgetState>();
  final Map<String, int> _categoryIndices = {};

  // Premium Colors
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color vintagePaper = Color(0xFFFDF5E6);
  static const Color deepLeather = Color(0xFF3E2723);
  static const Color textDark = Color(0xFF2D241E);

  // Menu URL for QR Code (Change this after deployment)
  final String menuUrl = "https://Combo0445.github.io/AstroHouse/";

  bool _isScrolling = false;
  late List<Widget> _menuPages;

  @override
  void initState() {
    super.initState();
    // Build menu pages ONCE so _categoryIndices is populated
    // stably and pages aren't recreated on setiap rebuild
    _menuPages = _buildAllMenuPages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      endDrawer: _buildDrawer(),
      body: Stack(
        children: [
          // Background wood/leather texture behind the book
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF3E2723), Color(0xFF1B100B)],
                radius: 1.2,
              ),
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo is ScrollStartNotification) {
                setState(() => _isScrolling = true);
              } else if (scrollInfo is ScrollEndNotification) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) setState(() => _isScrolling = false);
                });
              }
              return true;
            },
            child: PageFlipWidget(
              key: _controller,
              backgroundColor:
                  Colors.transparent, // Let the background show through
              lastPage: Container(color: deepLeather),
              children: [
                _buildCoverPage(),
                _buildWelcomeQRPage(),
                _buildTOCPage(),
                ..._menuPages,
                _buildContactPage(),
              ],
            ),
          ),
          Positioned(
            top: 25,
            right: 25,
            child: Builder(
              builder: (context) {
                return AnimatedOpacity(
                  opacity: _isScrolling ? 0.2 : 0.9,
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'menu_drawer',
                        backgroundColor: goldAccent,
                        foregroundColor: deepLeather,
                        elevation: 8,
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                        child: const Icon(Icons.restaurant_menu),
                      ),
                      const SizedBox(height: 15),
                      Consumer<CartService>(
                        builder: (context, cart, child) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              FloatingActionButton(
                                heroTag: 'cart_button',
                                backgroundColor: vintagePaper,
                                foregroundColor: deepLeather,
                                elevation: 8,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CartPage(),
                                    ),
                                  );
                                },
                                child: const Icon(Icons.shopping_cart),
                              ),
                              if (cart.totalItems > 0)
                                Positioned(
                                  right: -5,
                                  top: -5,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '\${cart.totalItems}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllMenuPages() {
    List<Widget> pages = [];
    _categoryIndices.clear();

    // The first 2 pages are Cover(0), WelcomeQR(1), and TOC(2)
    // So the menu pages start at index 3
    int currentIndex = 3;

    // Drinks Pages
    if (menuData.containsKey("Drinks")) {
      _categoryIndices["[DRINKS]"] = currentIndex;
      pages.add(
        _buildCategoryIntroPage("Beverages", "Refreshing & Fine Selections"),
      );
      currentIndex++;
      menuData["Drinks"].forEach((title, data) {
        _categoryIndices[title] = currentIndex;
        pages.add(
          _buildMenuCategoryPage(
            title,
            data,
            showImage: false,
            key: ValueKey('menu_$title'),
          ),
        );
        currentIndex++;
      });
    }

    // Food Pages
    if (menuData.containsKey("Food")) {
      _categoryIndices["[FOOD]"] = currentIndex;
      pages.add(
        _buildCategoryIntroPage(
          "Cuisine",
          "A Culinary Journey",
          key: const ValueKey('intro_Food'),
        ),
      );
      currentIndex++;
      menuData["Food"].forEach((subCategory, data) {
        _categoryIndices[subCategory] = currentIndex;
        pages.add(
          _buildMenuCategoryPage(
            subCategory,
            data,
            key: ValueKey('menu_$subCategory'),
          ),
        );
        currentIndex++;
      });
    }

    // Dessert Pages
    if (menuData.containsKey("Dessert")) {
      _categoryIndices["[DESSERT]"] = currentIndex;
      pages.add(
        _buildCategoryIntroPage(
          "Sweets",
          "The Perfect Ending",
          key: const ValueKey('intro_Dessert'),
        ),
      );
      currentIndex++;
      menuData["Dessert"].forEach((title, data) {
        _categoryIndices[title] = currentIndex;
        pages.add(
          _buildMenuCategoryPage(title, data, key: ValueKey('menu_$title')),
        );
        currentIndex++;
      });
    }

    return pages;
  }

  Widget _buildCategoryIntroPage(String title, String subtitle, {Key? key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: vintagePaper,
        border: Border.all(color: goldAccent.withOpacity(0.3), width: 15),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title.toUpperCase(),
              style: GoogleFonts.cinzel(
                color: textDark,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              height: 2,
              width: 100,
              color: goldAccent,
            ),
            Text(
              subtitle,
              style: GoogleFonts.playfairDisplay(
                color: Colors.brown.shade400,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPage() {
    return Container(
      decoration: const BoxDecoration(color: deepLeather),
      child: Container(
        margin: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          border: Border.all(color: goldAccent, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ASTRO',
                style: GoogleFonts.cinzel(
                  color: goldAccent,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'GASTRONOMY',
                style: GoogleFonts.cinzel(
                  color: goldAccent,
                  fontSize: 16,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 40),
              const Icon(Icons.restaurant_menu, color: goldAccent, size: 40),
              const SizedBox(height: 60),
              Text(
                'PREMIUM MENU',
                style: GoogleFonts.playfairDisplay(
                  color: goldAccent.withValues(alpha: 0.7),
                  fontSize: 14,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeQRPage() {
    return Container(
      decoration: BoxDecoration(
        color: vintagePaper,
        border: Border.all(color: goldAccent.withValues(alpha: 0.3), width: 15),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'WELCOME',
              style: GoogleFonts.cinzel(
                color: textDark,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Scan to view menu on your phone',
              style: GoogleFonts.playfairDisplay(
                color: Colors.brown.shade400,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: QrImageView(
                data:
                    menuUrl, // เปลี่ยนเป็น IP ของเครื่องที่รันเพื่อใช้งานแบบ Offline/Local
                version: QrVersions.auto,
                size: 200.0,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: textDark,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: textDark,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'OR FLIP TO CONTINUE',
              style: GoogleFonts.cinzel(
                color: goldAccent,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            const Icon(Icons.arrow_forward_ios, color: goldAccent, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContactPage() {
    return Container(
      decoration: BoxDecoration(
        color: deepLeather,
        border: Border.all(color: goldAccent.withValues(alpha: 0.3), width: 10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars, color: goldAccent, size: 40),
            const SizedBox(height: 20),
            Text(
              'THANK YOU',
              style: GoogleFonts.cinzel(
                color: goldAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'FOR VISITING ASTRO HOUSE',
              style: GoogleFonts.lora(
                color: vintagePaper.withValues(alpha: 0.7),
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 50),
            Container(
              width: 150,
              height: 1,
              color: goldAccent.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 50),
            _buildContactRow(
              Icons.chat_bubble_outline,
              'LINE OA',
              '@astrohouse',
            ),
            const SizedBox(height: 20),
            _buildContactRow(
              Icons.facebook,
              'FACEBOOK',
              'Astro House Gastronomy',
            ),
            const SizedBox(height: 20),
            _buildContactRow(Icons.phone_outlined, 'CALL US', '089-123-4567'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String title, String detail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: goldAccent, size: 20),
        const SizedBox(width: 15),
        SizedBox(
          width: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cinzel(
                  color: goldAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: GoogleFonts.lora(
                  color: vintagePaper.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCategoryPage(
    String title,
    dynamic categoryData, {
    bool showImage = true,
    Key? key,
  }) {
    List<Widget> listItems = [];
    if (categoryData is Map) {
      categoryData.forEach((sectionTitle, items) {
        listItems.add(
          Padding(
            padding: const EdgeInsets.only(top: 25, bottom: 15),
            child: Column(
              children: [
                Text(
                  sectionTitle.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: goldAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 1,
                  width: 60,
                  color: goldAccent.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        );
        if (items is List) {
          for (var item in items) {
            listItems.add(_buildPremiumMenuItem(item, showImage: showImage));
          }
        }
      });
    } else if (categoryData is List) {
      for (var item in categoryData) {
        listItems.add(_buildPremiumMenuItem(item, showImage: showImage));
      }
    }

    return Container(
      key: key,
      color: vintagePaper,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.cinzel(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: textDark,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 10, color: goldAccent),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 1,
                width: 40,
                color: goldAccent,
              ),
              const Icon(Icons.star, size: 10, color: goldAccent),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: ListView(children: listItems)),
        ],
      ),
    );
  }

  Widget _buildPremiumMenuItem(dynamic item, {bool showImage = true}) {
    if (item["isPlaceholder"] == true) return const SizedBox.shrink();
    if (item["isTopping"] == true) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        child: Row(
          children: [
            const Text("•", style: TextStyle(color: goldAccent)),
            const SizedBox(width: 8),
            Text(
              item["name"],
              style: GoogleFonts.lora(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
            const Spacer(),
            Text(
              "${item["price"]}฿",
              style: GoogleFonts.montserrat(fontSize: 14, color: goldAccent),
            ),
          ],
        ),
      );
    }

    String imagePath = item["image"] ?? "";
    bool isNetwork = false;

    // Check if it's an HTML img tag and extract the src
    if (imagePath.contains("<img") && imagePath.contains("src=\"")) {
      final startIndex = imagePath.indexOf("src=\"") + 5;
      final endIndex = imagePath.indexOf("\"", startIndex);
      if (startIndex != -1 && endIndex != -1) {
        imagePath = imagePath.substring(startIndex, endIndex);
      }
    }

    // Convert Google Drive links to direct image links
    if (imagePath.contains("drive.google.com")) {
      String? fileId;
      // Handle /file/d/ID/view format
      if (imagePath.contains("/file/d/")) {
        final parts = imagePath.split("/file/d/");
        if (parts.length > 1) {
          fileId = parts[1].split("/").first;
        }
      }
      // Handle id=ID format
      else if (imagePath.contains("id=")) {
        final uri = Uri.tryParse(imagePath);
        if (uri != null && uri.queryParameters.containsKey("id")) {
          fileId = uri.queryParameters["id"];
        }
      }

      if (fileId != null) {
        // Use the undocumented lh3.googleusercontent.com endpoint
        // This endpoint natively supports CORS for Flutter Web without needing an external proxy
        imagePath = "https://lh3.googleusercontent.com/d/$fileId=w1000";
      }
    }

    // Check if it's a URL
    if (imagePath.startsWith("http://") || imagePath.startsWith("https://")) {
      isNetwork = true;
    }

    Widget imageWidget =
        isNetwork
            ? Image.network(
              imagePath,
              width: 65,
              height: 65,
              fit: BoxFit.cover,
              errorBuilder: _buildImageErrorPlaceholder,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 65,
                  height: 65,
                  color: vintagePaper,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: goldAccent,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                );
              },
            )
            : Image.asset(
              imagePath,
              width: 65,
              height: 65,
              fit: BoxFit.cover,
              errorBuilder: _buildImageErrorPlaceholder,
            );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showImage) ...[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: goldAccent, width: 1),
                  ),
                  child: imageWidget,
                ),
                const SizedBox(width: 15),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            item["name"],
                            style: GoogleFonts.lora(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ),
                        if (item["priceOptions"] == null)
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  context.read<CartService>().addItem(
                                    name: item["name"],
                                    price: (item["price"] as num).toInt(),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added ${item["name"]} to cart',
                                        style: const TextStyle(
                                          color: vintagePaper,
                                        ),
                                      ),
                                      backgroundColor: deepLeather,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${item["price"]}฿",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: goldAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: goldAccent.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add_shopping_cart,
                                          size: 18,
                                          color: textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (item["description"] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item["description"],
                          style: GoogleFonts.lora(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    if (item["priceOptions"] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          children: [
                            for (var opt in item["priceOptions"])
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      context.read<CartService>().addItem(
                                        name: item["name"],
                                        price: (opt["price"] as num).toInt(),
                                        optionLabel: opt["label"],
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Added ${item["name"]} (${opt["label"]}) to cart',
                                            style: const TextStyle(
                                              color: vintagePaper,
                                            ),
                                          ),
                                          backgroundColor: deepLeather,
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                        horizontal: 4.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "- ${opt["label"]}",
                                            style: GoogleFonts.lora(
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "${opt["price"]}฿",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 13,
                                              color: goldAccent,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: goldAccent.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Icon(
                                              Icons.add_shopping_cart,
                                              size: 14,
                                              color: textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: goldAccent.withValues(alpha: 0.1), thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildTOCPage() {
    return Container(
      decoration: BoxDecoration(
        color: vintagePaper,
        border: Border.all(color: goldAccent.withValues(alpha: 0.3), width: 10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        children: [
          Text(
            'CONTENTS',
            style: GoogleFonts.cinzel(
              color: textDark,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 2, width: 60, color: goldAccent),
          const SizedBox(height: 50),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  _categoryIndices.entries.where((e) => e.key.startsWith('[')).map((
                    entry,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: InkWell(
                        onTap:
                            () =>
                                _controller.currentState?.goToPage(entry.value),
                        child: Row(
                          children: [
                            Text(
                              entry.key.replaceAll(RegExp(r'[\[\]]'), ''),
                              style: GoogleFonts.cinzel(
                                color: textDark,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Dotted line that perfectly spans the available space
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: CustomPaint(
                                      size: Size(constraints.maxWidth, 1),
                                      painter: _DottedLinePainter(
                                        color: goldAccent.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Text(
                              '${entry.value + 1}',
                              style: GoogleFonts.playfairDisplay(
                                color: goldAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          Text(
            '~ Astro House ~',
            style: GoogleFonts.playfairDisplay(
              color: Colors.brown.shade300,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // Map of section headers to display names and icons
  static const Map<String, Map<String, dynamic>> _sectionInfo = {
    '[DRINKS]': {'label': 'DRINKS', 'icon': Icons.local_cafe},
    '[FOOD]': {'label': 'FOOD', 'icon': Icons.restaurant},
    '[DESSERT]': {'label': 'DESSERT', 'icon': Icons.cake},
  };

  Widget _buildDrawer() {
    List<Widget> drawerItems = [];
    Map<String, List<MapEntry<String, int>>> grouped = {};
    String currentHeader = '';

    // Group categories
    for (var entry in _categoryIndices.entries) {
      if (entry.key.startsWith('[')) {
        currentHeader = entry.key;
        grouped[currentHeader] = [];
      } else {
        if (currentHeader.isNotEmpty) {
          grouped[currentHeader]!.add(entry);
        }
      }
    }

    // Build ExpansionTiles
    grouped.forEach((headerKey, items) {
      final info = _sectionInfo[headerKey];
      final headerIndex = _categoryIndices[headerKey]!;

      drawerItems.add(
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            iconColor: goldAccent,
            collapsedIconColor: goldAccent,
            title: GestureDetector(
              onTap: () {
                Navigator.pop(context); // close drawer
                Future.delayed(const Duration(milliseconds: 300), () {
                  _controller.currentState?.goToPage(headerIndex);
                });
              },
              child: Row(
                children: [
                  Icon(
                    info?['icon'] as IconData? ?? Icons.menu_book,
                    color: goldAccent,
                    size: 22,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    info?['label'] as String? ?? '',
                    style: GoogleFonts.cinzel(
                      color: goldAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            children:
                items.map((subItem) {
                  return ListTile(
                    contentPadding: const EdgeInsets.only(left: 55, right: 16),
                    title: Text(
                      subItem.key,
                      style: GoogleFonts.lora(
                        color: vintagePaper,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        _controller.currentState?.goToPage(subItem.value);
                      });
                    },
                  );
                }).toList(),
          ),
        ),
      );
    });

    return Drawer(
      backgroundColor: deepLeather,
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF2C1810), deepLeather],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                bottom: BorderSide(color: goldAccent.withValues(alpha: 0.3)),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: goldAccent, width: 2),
                  ),
                  child: const Icon(Icons.star, color: goldAccent, size: 40),
                ),
                const SizedBox(height: 15),
                Text(
                  'ASTRO MENU',
                  style: GoogleFonts.cinzel(
                    color: goldAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
          // Categories
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: drawerItems,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageErrorPlaceholder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Container(
      width: 65,
      height: 65,
      color: vintagePaper,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 20,
              color: goldAccent.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 2),
            Text(
              "N/A",
              style: GoogleFonts.cinzel(
                color: goldAccent.withValues(alpha: 0.5),
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
