import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';
import 'data/menu_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    // Build menu pages FIRST so _categoryIndices is populated
    // before TOC and Drawer try to use it
    final menuPages = _buildAllMenuPages();

    return Scaffold(
      backgroundColor: Colors.black,
      endDrawer: _buildDrawer(),
      body: Stack(
        children: [
          PageFlipWidget(
            key: _controller,
            backgroundColor: Colors.black,
            lastPage: Container(color: deepLeather),
            children: [
              _buildCoverPage(),
              _buildWelcomeQRPage(),
              _buildTOCPage(),
              ...menuPages,
            ],
          ),
          Positioned(
            top: 25,
            right: 25,
            child: Builder(
              builder: (context) {
                return FloatingActionButton(
                  backgroundColor: goldAccent,
                  foregroundColor: deepLeather,
                  elevation: 8,
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  child: const Icon(Icons.restaurant_menu),
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
        pages.add(_buildMenuCategoryPage(title, data, showImage: false));
        currentIndex++;
      });
    }

    // Food Pages
    if (menuData.containsKey("Food")) {
      _categoryIndices["[FOOD]"] = currentIndex;
      pages.add(_buildCategoryIntroPage("Cuisine", "A Culinary Journey"));
      currentIndex++;
      menuData["Food"].forEach((subCategory, data) {
        _categoryIndices[subCategory] = currentIndex;
        pages.add(_buildMenuCategoryPage(subCategory, data));
        currentIndex++;
      });
    }

    // Dessert Pages
    if (menuData.containsKey("Dessert")) {
      _categoryIndices["[DESSERT]"] = currentIndex;
      pages.add(_buildCategoryIntroPage("Sweets", "The Perfect Ending"));
      currentIndex++;
      menuData["Dessert"].forEach((title, data) {
        _categoryIndices[title] = currentIndex;
        pages.add(_buildMenuCategoryPage(title, data));
        currentIndex++;
      });
    }

    return pages;
  }

  Widget _buildCategoryIntroPage(String title, String subtitle) {
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

  Widget _buildMenuCategoryPage(
    String title,
    dynamic categoryData, {
    bool showImage = true,
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
                          Text(
                            "${item["price"]}฿",
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: goldAccent,
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
                                  ],
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
        border: Border.all(color: goldAccent.withValues(alpha: 0.3), width: 15),
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
                  _categoryIndices.entries
                      .where((e) => e.key.startsWith('['))
                      .map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: InkWell(
                            onTap:
                                () => _controller.currentState?.goToPage(
                                  entry.value,
                                ),
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
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      '...................................',
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(color: Colors.grey),
                                    ),
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
                      })
                      .toList(),
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
                _controller.currentState?.goToPage(headerIndex);
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
                      _controller.currentState?.goToPage(subItem.value);
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
