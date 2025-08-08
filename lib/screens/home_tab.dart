import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/product_model.dart';
import '../models/location_model.dart';
import '../widgets/contact_method_display.dart';
import '../widgets/banner_ad_widget.dart';
import '../services/database_service.dart';
import '../services/location_service_v2.dart';
import '../utils/constants.dart';
import 'product_detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<ProductModel> _products = [];
  List<LocationModel> _countries = [];
  List<LocationModel> _cities = [];
  bool _isLoading = true;
  bool _isLoadingLocations = false;
  String? _selectedCountry;
  String? _selectedRegion;
  String? _selectedCategory;
  LocationModel? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Kullanıcının mevcut konumunu al
    if (AppConstants.useOnlineLocationService) {
      _currentLocation = await LocationServiceV2().getCurrentLocation();
      if (_currentLocation != null) {
        _selectedCountry = _currentLocation!.name;
      }
    }
    
    _loadProducts();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    if (!AppConstants.useOnlineLocationService) return;
    
    setState(() => _isLoadingLocations = true);
    try {
      final countries = await LocationServiceV2().getCountries();
      setState(() {
        _countries = countries;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      // Fallback bölgeleri kullan
      _countries = AppConstants.fallbackRegions
          .map((region) => LocationModel(name: region, code: region.toLowerCase()))
          .toList();
    }
  }

  Future<void> _loadCitiesForCountry(String countryCode) async {
    if (!AppConstants.useOnlineLocationService) return;
    
    setState(() => _isLoadingLocations = true);
    try {
      final cities = await LocationServiceV2().getCitiesByCountry(countryCode);
      setState(() {
        _cities = cities;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      // Türkiye için fallback
      if (countryCode.toLowerCase() == 'tr') {
        _cities = LocationServiceV2().getTurkishCities();
      }
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    List<ProductModel> products;
    if (_selectedRegion != null) {
      products = await DatabaseService().getProductsByRegion(_selectedRegion!);
    } else {
      products = await DatabaseService().getAllProducts();
    }

    if (_selectedCategory != null) {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }

    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.projectName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF667eea),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF667eea)),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner reklam
          Container(
            margin: const EdgeInsets.all(8),
            child: BannerAdWidget(
              adSize: AdSize.banner,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          // Filtre durumu
          if (_selectedRegion != null || _selectedCategory != null)
            Container(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedRegion != null)
                    Chip(
                      label: Text(_selectedRegion!),
                      onDeleted: () {
                        setState(() => _selectedRegion = null);
                        _loadProducts();
                      },
                    ),
                  if (_selectedCategory != null)
                    Chip(
                      label: Text(_selectedCategory!),
                      onDeleted: () {
                        setState(() => _selectedCategory = null);
                        _loadProducts();
                      },
                    ),
                ],
              ),
            ),
          // Ürün listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Henüz ürün bulunamadı',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            return _ProductCard(
                              product: _products[index],
                              onTap: () => _showProductDetail(_products[index]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.filter_list),
            SizedBox(width: 8),
            Text('Filter Products'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ülke/Bölge seçimi
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: const InputDecoration(
                  labelText: 'Country/Region',
                  prefixIcon: Icon(Icons.public),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Regions')),
                  if (AppConstants.useOnlineLocationService && _countries.isNotEmpty)
                    ..._countries.map(
                      (country) => DropdownMenuItem(
                        value: country.name,
                        child: Row(
                          children: [
                            if (country.flag != null) Text(country.flag!),
                            const SizedBox(width: 8),
                            Expanded(child: Text(country.name)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...AppConstants.fallbackRegions.map(
                      (region) => DropdownMenuItem(
                        value: region,
                        child: Text(region),
                      ),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value;
                    _selectedRegion = null; // Reset city when country changes
                  });
                  if (value != null && AppConstants.useOnlineLocationService) {
                    final selectedCountry = _countries.firstWhere(
                      (c) => c.name == value,
                      orElse: () => LocationModel(name: value, code: value),
                    );
                    _loadCitiesForCountry(selectedCountry.code);
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Şehir seçimi
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Cities')),
                  if (_cities.isNotEmpty)
                    ..._cities.map(
                      (city) => DropdownMenuItem(
                        value: city.name,
                        child: Text(city.name),
                      ),
                    ),
                ],
                onChanged: (value) {
                  setState(() => _selectedRegion = value);
                },
              ),
              
              const SizedBox(height: 16),
              
              // Kategori seçimi
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Categories')),
                  ...AppConstants.categories.map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(_getLocalizedCategory(category)),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
              ),
              
              if (_isLoadingLocations) ...[
                const SizedBox(height: 16),
                const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Loading locations...'),
                  ],
                ),
              ],
              
              if (_currentLocation != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Current: ${_currentLocation!.name}',
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadProducts();
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  void _showProductDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  String _getLocalizedCategory(String category) {
    // Basit locale detection (genişletilebilir)
    try {
      final locale = Localizations.localeOf(context).languageCode;
      
      if (AppConstants.categoryTranslations.containsKey(locale)) {
        return AppConstants.categoryTranslations[locale]![category] ?? category;
      }
    } catch (e) {
      // Fallback to original if locale detection fails
    }
    
    return category;
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      color: Colors.grey[200],
                    ),
                    child: product.imageUrls.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: _buildImage(
                              product.imageUrls.first,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey,
                          ),
                  ),
                  if (product.isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.region,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    // İletişim kanalları
                    if (product.contactMethods.isNotEmpty)
                      ContactMethodChips(
                        contactMethods: product.contactMethods,
                        maxVisible: 2,
                      )
                    else
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.sellerName,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
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
            size: 48,
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
            size: 48,
            color: Colors.grey,
          );
        },
      );
    }
  }
}
