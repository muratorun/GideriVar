import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';
import 'product_detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _selectedRegion;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadProducts();
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
        title: const Text(
          'Giderivar',
          style: TextStyle(
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
            child: AdService().getBannerAd() ?? const SizedBox.shrink(),
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
        title: const Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: const InputDecoration(labelText: 'Şehir'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tüm şehirler')),
                ...AppConstants.turkishCities.map(
                  (city) => DropdownMenuItem(value: city, child: Text(city)),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedRegion = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tüm kategoriler')),
                ...AppConstants.categories.map(
                  (category) => DropdownMenuItem(value: category, child: Text(category)),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
            ),
          ],
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
                            child: Image.network(
                              product.imageUrls.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Colors.grey,
                                );
                              },
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
                    Row(
                      children: [
                        Text(
                          product.contactType.icon,
                          style: const TextStyle(fontSize: 16),
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
}
