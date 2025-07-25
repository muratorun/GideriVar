import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.card_giftcard, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'GideriVar',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 600,
          maxWidth: 600,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Color(0xFF232526), Color(0xFF414345)]
                : [Color(0xFFe0eafc), Color(0xFFcfdef3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Modern illüstrasyon veya animasyon
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 32,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Lottie.asset(
                        'assets/lottie/people-moving-boxes.json',
                        height: 200,
                        repeat: true,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    color: isDark ? Color(0xFF232526) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'GideriVar Web Çok Yakında!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.deepPurple,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Kullanmadığınız eşyaları ücretsiz paylaşabileceğiniz yepyeni bir platform için çalışıyoruz. Sürprizlerle dolu bir deneyim için bizi takipte kalın! 🎁',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // Modern loading animasyonu
                          Lottie.asset(
                            'assets/lottie/loading-workers.json',
                            height: 54,
                            repeat: true,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 6,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.notifications_active, color: Colors.white),
                            label: const Text(
                              'Haberdar Ol',
                              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.email, color: Colors.deepPurple),
                        tooltip: 'E-posta',
                        onPressed: () {},
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.facebook, color: Colors.deepPurple),
                        tooltip: 'Facebook',
                        onPressed: () {},
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.telegram, color: Colors.deepPurple),
                        tooltip: 'Telegram',
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '© 2025 GideriVar. Tüm hakları saklıdır.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
