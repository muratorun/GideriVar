import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../utils/constants.dart';
import 'product_detail_screen.dart';
import 'edit_profile_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  UserModel? _currentUser;
  List<ProductModel> _userProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null) {
        final products = await DatabaseService().getUserProducts(user.id);
        
        setState(() {
          _currentUser = user;
          _userProducts = products;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return _buildLoginPrompt();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profilim',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF667eea),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF667eea)),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildUserInfo(),
                    const SizedBox(height: 24),
                    _buildStats(),
                    const SizedBox(height: 24),
                    _buildMyProducts(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoginPrompt() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profilim',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF667eea),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 64,
                  color: Color(0xFF667eea),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Giriş Yapın',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Profil bilgilerinizi görüntülemek ve ürün eklemek için giriş yapmalısınız.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _currentUser!.displayName?.split(' ').map((e) => e[0]).take(2).join() ?? 
                _currentUser!.email[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _currentUser!.displayName ?? 'Kullanıcı',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentUser!.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          if (_currentUser!.region != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  _currentUser!.region!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.shopping_bag_outlined,
            title: 'İlanlarım',
            value: _userProducts.length.toString(),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.visibility,
            title: 'Görüntüleme',
            value: '${_userProducts.length * 12}', // Simüle edilmiş
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.contact_phone,
            title: 'İletişim',
            value: '${_currentUser!.currentPurchases}/${_currentUser!.purchaseLimit}',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMyProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'İlanlarım',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add-product');
              },
              icon: const Icon(Icons.add),
              label: const Text('Yeni İlan'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_userProducts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.inventory_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Henüz ilan vermediniz',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'İlk ilanınızı vererek başlayın!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _userProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(_userProducts[index]);
            },
          ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ürün resmi
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImage(
                          product.imageUrls.first,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
              ),
              
              const SizedBox(width: 12),
              
              // Ürün bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.region,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category ?? '',
                      style: const TextStyle(
                        color: Color(0xFF667eea),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Menü butonu
              PopupMenuButton<String>(
                onSelected: (value) => _handleProductAction(value, product),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sil', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleProductAction(String action, ProductModel product) {
    switch (action) {
      case 'edit':
        // Düzenleme özelliği eklenecek
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Düzenleme özelliği yakında!'),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(product);
        break;
    }
  }

  void _showDeleteConfirmation(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: Text('${product.title} ilanını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await DatabaseService().deleteProduct(product.id);
              if (success) {
                _loadUserData(); // Listeyi yenile
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('İlan başarıyla silindi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              context.tr('settings'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(context.tr('language')),
              subtitle: Text(context.tr('change_language')),
              onTap: () {
                Navigator.pop(context);
                _showLanguageSelection();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(context.tr('edit_profile')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(context.tr('notifications')),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('feature_coming_soon')),
                  ),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.help),
              title: Text(context.tr('help')),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('feature_coming_soon')),
                  ),
                );
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                context.tr('logout'),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('logout')),
        content: Text(context.tr('logout_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.tr('logout')),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              context.tr('select_language'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            ...AppConstants.supportedLanguages.map((languageCode) {
              final languageName = AppConstants.languageNames[languageCode] ?? languageCode;
              final localizationService = Provider.of<LocalizationService>(context, listen: false);
              final isSelected = localizationService.currentLanguage == languageCode;
              
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF667eea) : Colors.grey,
                ),
                title: Text(
                  languageName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF667eea) : Colors.black,
                  ),
                ),
                onTap: () async {
                  await localizationService.changeLanguage(languageCode);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Helper function to determine if URL is asset or network
  Widget _buildImage(String imageUrl, {BoxFit? fit}) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
          );
        },
      );
    } else {
      return Image.network(
        imageUrl,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
          );
        },
      );
    }
  }
}
