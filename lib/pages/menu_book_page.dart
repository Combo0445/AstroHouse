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

  // Premium Colors
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color vintagePaper = Color(0xFFFDF5E6);
  static const Color deepLeather = Color(0xFF3E2723);
  static const Color textDark = Color(0xFF2D241E);

  // Menu URL for QR Code (Change this after deployment)
  final String menuUrl = "https://Combo0445.github.io/AstroHouse/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageFlipWidget(
        key: _controller,
        backgroundColor: Colors.black,
        lastPage: _buildLastPage(),
        children: [
          _buildCoverPage(),
          _buildWelcomeQRPage(),
          ..._buildAllMenuPages(),
          _buildBackCoverPage(),
        ],
      ),
    );
  }

  List<Widget> _buildAllMenuPages() {
    List<Widget> pages = [];

    // Drinks Pages
    if (menuData.containsKey("Drinks")) {
      pages.add(
        _buildCategoryIntroPage("Beverages", "Refreshing & Fine Selections"),
      );
      menuData["Drinks"].forEach((title, data) {
        pages.add(_buildMenuCategoryPage(title, data));
      });
    }

    // Food Pages
    if (menuData.containsKey("Food")) {
      pages.add(_buildCategoryIntroPage("Cuisine", "A Culinary Journey"));
      menuData["Food"].forEach((subCategory, data) {
        if (subCategory != "Others") {
          pages.add(_buildMenuCategoryPage(subCategory, data));
        }
      });
    }

    // Dessert Pages
    if (menuData.containsKey("Dessert")) {
      pages.add(_buildCategoryIntroPage("Sweets", "The Perfect Ending"));
      menuData["Dessert"].forEach((title, data) {
        pages.add(_buildMenuCategoryPage(title, data));
      });
    }

    // Chorizo Pages
    if (menuData.containsKey("Chorizo")) {
      pages.add(
        _buildCategoryIntroPage("Chorizo", "Premium Sausage Selections"),
      );
      menuData["Chorizo"].forEach((title, data) {
        pages.add(_buildMenuCategoryPage(title, data));
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

  Widget _buildBackCoverPage() {
    return Container(
      color: deepLeather,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars, color: goldAccent, size: 50),
            const SizedBox(height: 20),
            Text(
              'ESTABLISHED 2024',
              style: GoogleFonts.cinzel(color: goldAccent, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastPage() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'THANK YOU',
          style: GoogleFonts.cinzel(color: goldAccent, fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildMenuCategoryPage(String title, dynamic categoryData) {
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
            listItems.add(_buildPremiumMenuItem(item));
          }
        }
      });
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

  Widget _buildPremiumMenuItem(dynamic item) {
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: goldAccent, width: 1),
                ),
                child: Image.asset(
                  item["image"] ?? "",
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (c, e, s) => Container(
                        width: 65,
                        height: 65,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.restaurant, size: 20),
                      ),
                ),
              ),
              const SizedBox(width: 15),
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
}
