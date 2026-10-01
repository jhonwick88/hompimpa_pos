import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hompimpa_pos/core/widgets/app_image.dart';
import 'package:hompimpa_pos/features/products/domain/product.dart';

enum ProductCardVariant {
  /// Alternatif 1: Clean & Modern (Light)
  cleanLight,

  /// Alternatif 2: Rich & Modern (Dark Accent - Gradient Orange, Merah, Hitam)
  richModern,
}

class ProductCardModern extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final String? portionLabel;
  final String? customDescription;
  final ProductCardVariant variant;

  const ProductCardModern({
    super.key,
    required this.product,
    this.onTap,
    this.portionLabel,
    this.customDescription,
    this.variant = ProductCardVariant.richModern,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isOutOfStock = product.stock <= 0;
    final isLowStock = product.stock > 0 && product.stock < 10;
    final catLower = product.category.toLowerCase();
    final isFood = catLower.contains('makan') || catLower.contains('mie') || catLower.contains('pangsit');
    final isRich = variant == ProductCardVariant.richModern;

    // Badge styling based on stock
    Color stockBadgeColor;
    IconData stockIcon;
    String stockText;

    if (isOutOfStock) {
      stockBadgeColor = const Color(0xFFDC2626);
      stockIcon = Icons.block_rounded;
      stockText = 'Habis';
    } else if (isLowStock) {
      stockBadgeColor = const Color(0xFFEA580C);
      stockIcon = Icons.warning_amber_rounded;
      stockText = 'Stok: ${product.stock}';
    } else {
      stockBadgeColor = const Color(0xFF16A34A);
      stockIcon = Icons.eco_rounded;
      stockText = 'Stok: ${product.stock}';
    }

    // Dynamic smart description based on category
    String description = customDescription ?? '';
    if (description.isEmpty) {
      if (catLower.contains('snack')) {
        description = 'Camilan renyah & nikmat.';
      } else if (catLower.contains('minum')) {
        description = 'Minuman segar pelepas dahaga.';
      } else {
        description = 'Pilihan menu spesial gurih & lezat.';
      }
    }

    final portion = portionLabel ?? '1 Porsi';

    // 🎨 Card Background & Border (Gradient mix: Orange, Merah, Hitam)
    final cardDecoration = isRich
        ? BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.35, 0.70, 1.0],
              colors: [
                Color(0xFF15080C), // Deep Black-Maroon
                Color(0xFF5E111E), // Hompimpa Deep Red
                Color(0xFF8B1E2D), // Rich Maroon
                Color(0xFFC84B10), // Warm Fiery Orange-Red
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF8A00).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B1E2D).withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          )
        : BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.85),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          );

    return Container(
      decoration: cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: const Color(0xFFFF8A00).withValues(alpha: 0.18),
            highlightColor: const Color(0xFF8B1E2D).withValues(alpha: 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 📸 1. PRODUCT IMAGE + BADGES (Image with rounded bottom corners)
                Expanded(
                  flex: 13,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                      bottom: Radius.circular(18),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppImage(
                          url: product.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1E070D),
                                  Color(0xFF3D0E18),
                                  Color(0xFF140509),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF8A00),
                                      Color(0xFF8B1E2D),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFFFD54F),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF8A00).withValues(alpha: 0.35),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isFood ? Icons.soup_kitchen_rounded : Icons.local_drink_rounded,
                                  size: 26,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Subtle gradient overlay for badge readability
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 48,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 🏷️ COMPACT HOMPIMPA BRAND ICON BADGE (Top Left)
                        if (isRich)
                          Positioned(
                            top: 7,
                            left: 7,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF8A00),
                                    Color(0xFF8B1E2D),
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(0xFFFFD54F),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF8A00).withValues(alpha: 0.4),
                                    blurRadius: 5,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.soup_kitchen_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),

                        // 🌿 FLOATING STOCK BADGE (Top Right)
                        Positioned(
                          top: 7,
                          right: 7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: stockBadgeColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: stockBadgeColor.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1.5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  stockIcon,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 3.5),
                                Text(
                                  stockText,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Out of stock overlay
                        if (isOutOfStock)
                          Container(
                            color: Colors.black.withValues(alpha: 0.55),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'HABIS',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 📝 2. PRODUCT DETAILS (Over rich gradient background)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title + Accent
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              product.name.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: isRich ? Colors.white : const Color(0xFF1E293B),
                                height: 1.15,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isRich)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.rotate(
                                    angle: 0.2,
                                    child: Container(
                                      width: 3,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF8A00),
                                        borderRadius: BorderRadius.circular(1.5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Transform.rotate(
                                    angle: -0.2,
                                    child: Container(
                                      width: 3,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5722),
                                        borderRadius: BorderRadius.circular(1.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Description
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: isRich
                              ? Colors.white.withValues(alpha: 0.78)
                              : const Color(0xFF64748B),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Price & Portion Chip Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 💰 Price Badge
                          if (isRich)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4.5,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF8A00),
                                    Color(0xFFE64A19),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF8A00).withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                currencyFormatter.format(product.price),
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else
                            Text(
                              currencyFormatter.format(product.price),
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFF8A00),
                              ),
                            ),

                          // 🍲 Portion Chip (Dark Glassmorphic style for gradient card)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: isRich
                                  ? Colors.black.withValues(alpha: 0.35)
                                  : const Color(0xFFF8F6EF),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: isRich
                                    ? Colors.white.withValues(alpha: 0.22)
                                    : const Color(0xFFE8E4D8),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isFood
                                      ? Icons.ramen_dining_rounded
                                      : Icons.local_drink_rounded,
                                  size: 12,
                                  color: isRich ? const Color(0xFFFFB74D) : const Color(0xFF8B1E2D),
                                ),
                                const SizedBox(width: 3.5),
                                Text(
                                  portion,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isRich ? Colors.white : const Color(0xFF5C5549),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
