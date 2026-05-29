import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hompimpa_pos/core/widgets/gradient_app_bar.dart';

class DeveloperContactScreen extends StatelessWidget {
  const DeveloperContactScreen({super.key});

  Future<void> _openWhatsApp() async {
    final message = "Halo Labs Pintar, saya tertarik dengan jasa pembuatan aplikasi POS / custom. Mohon info lebih lanjut. Terima kasih!";
    final encodedMessage = Uri.encodeComponent(message);
    final uri = Uri.parse("https://wa.me/6282132935169?text=$encodedMessage");
    
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
        // Fallback silently or via platform default
      }
    }
  }

  Future<void> _openEmail() async {
    final uri = Uri.parse("mailto:labspintar@gmail.com?subject=Tanya%20Jasa%20Pembuatan%20Aplikasi");
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
        // Fallback
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 700;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const GradientAppBar(
        title: Text('Developer Contact Center'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF1E293B), // Slate 800
              Color(0xFF334155), // Slate 700
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 60.0 : 20.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== LOGO / HEADER BRAND =====
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade500.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber.shade500.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.amber.shade400,
                      size: isTablet ? 64 : 48,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'LABS PINTAR',
                    style: TextStyle(
                      fontSize: isTablet ? 28 : 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Premium Software Development Studio',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // ===== INTRO CARD =====
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Wujudkan Aplikasi Impian Anda!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Kami menerima jasa pembuatan aplikasi kasir POS (Point of Sales) sejenis, website perusahaan, e-commerce, sistem pergudangan, hingga aplikasi kustom lainnya yang dirancang khusus untuk meningkatkan omzet dan efisiensi operasional bisnis Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade300,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // ===== PROMO CARD (LUXURIOUS GOLD GRADIENT) =====
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD4AF37), // Metallic Gold
                        Color(0xFFAA7C11), // Dark Gold
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.stars, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'PROMO SPESIAL',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'DISKON 20% + GRATIS HOSTING & MAINTENANCE 1 TAHUN!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Khusus bulan ini, dapatkan potongan harga 20% untuk pembuatan aplikasi custom, serta jaminan pemeliharaan (maintenance) & cloud hosting gratis selama 1 tahun penuh. Sistem aman, performa cepat, dan bergaransi!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // ===== CONTACT SECTION TITLE =====
                const Text(
                  'Saluran Kontak Hubungi Kami',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                
                // ===== CONTACT INFO CARD =====
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Phone Row
                      _buildContactItem(
                        icon: Icons.phone_android_rounded,
                        title: 'Nomor Handphone (WhatsApp)',
                        value: '0821-3293-5169',
                        onTap: _openWhatsApp,
                        color: Colors.teal.shade400,
                      ),
                      const Divider(color: Colors.white12, height: 24),
                      // Email Row
                      _buildContactItem(
                        icon: Icons.email_outlined,
                        title: 'Email Resmi',
                        value: 'labspintar@gmail.com',
                        onTap: _openEmail,
                        color: Colors.blue.shade400,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // ===== LAUNCH WHATSAPP BUTTON =====
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF25D366), // WhatsApp Green
                        Color(0xFF128C7E), // WhatsApp Dark Green
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF25D366).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _openWhatsApp,
                      borderRadius: BorderRadius.circular(16),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'HUBUNGI VIA WHATSAPP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade600, size: 14),
          ],
        ),
      ),
    );
  }
}
