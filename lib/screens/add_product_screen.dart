import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/contact_method.dart';
import '../widgets/contact_method_selector.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sellerNameController = TextEditingController();
  
  List<LocationModel> _countries = [];
  List<LocationModel> _cities = [];
  List<LocationModel> _districts = [];
  String? _selectedCountry;
  String? _selectedRegion;
  String? _selectedDistrict;
  String? _selectedCategory;
  List<ContactMethod> _selectedContactMethods = [];
  bool _isPremium = false;
  bool _isLoading = false;
  bool _isLoadingLocations = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    if (!AppConstants.useOnlineLocationService) {
      // Fallback regions kullan
      setState(() {
        _countries = AppConstants.fallbackRegions
            .map((region) => LocationModel(name: region, code: region.toLowerCase()))
            .toList();
      });
      return;
    }
    
    setState(() => _isLoadingLocations = true);
    try {
      final countries = await LocationService().getCountries();
      setState(() {
        _countries = countries;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      // Fallback
      _countries = AppConstants.fallbackRegions
          .map((region) => LocationModel(name: region, code: region.toLowerCase()))
          .toList();
    }
  }

  Future<void> _loadCitiesForCountry(String countryCode) async {
    if (!AppConstants.useOnlineLocationService) return;
    
    setState(() => _isLoadingLocations = true);
    try {
      final cities = await LocationService().getCitiesByCountry(countryCode);
      setState(() {
        _cities = cities;
        _districts = []; // City değişince districts temizle
        _selectedDistrict = null;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      // Türkiye için fallback
      if (countryCode.toLowerCase() == 'tr') {
        _cities = LocationService().getTurkishCities();
      }
    }
  }

  Future<void> _loadDistrictsForCity(String cityCode) async {
    if (!AppConstants.useOnlineLocationService) return;
    
    setState(() => _isLoadingLocations = true);
    try {
      final districts = await LocationService().getDistrictsByCity(cityCode);
      setState(() {
        _districts = districts;
        _selectedDistrict = null; // Reset district selection
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _sellerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ürün Ekle',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF667eea),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF667eea),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              _buildSectionTitle('Ürün Bilgileri'),
              const SizedBox(height: 16),
              
              // Ürün başlığı
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Ürün Başlığı *',
                  hintText: 'Örn: iPhone 12 Pro Max',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ürün başlığı gerekli';
                  }
                  if (value.trim().length < 3) {
                    return 'Başlık en az 3 karakter olmalı';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Kategori seçimi
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori seçimi gerekli';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Açıklama
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Açıklama *',
                  hintText: 'Ürününüzü detaylı şekilde açıklayın...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Açıklama gerekli';
                  }
                  if (value.trim().length < 10) {
                    return 'Açıklama en az 10 karakter olmalı';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Ülke/Bölge seçimi
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Country/Region *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.public),
                ),
                items: _countries.map((country) {
                  return DropdownMenuItem(
                    value: country.name,
                    child: Text(
                      '${country.flag != null ? country.flag! + ' ' : ''}${country.name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Country/Region selection required';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Şehir seçimi
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'Not Specified',
                    child: Text('Not Specified'),
                  ),
                  ..._cities.map((city) {
                    return DropdownMenuItem(
                      value: city.name,
                      child: Text(city.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRegion = value;
                    if (value != null && value != 'Not Specified') {
                      // İlçeleri yükle
                      final selectedCity = _cities.firstWhere(
                        (c) => c.name == value,
                        orElse: () => LocationModel(name: value, code: value.toLowerCase()),
                      );
                      _loadDistrictsForCity(selectedCity.code);
                    } else {
                      // City seçimi kaldırıldıysa districts temizle
                      _districts.clear();
                      _selectedDistrict = null;
                    }
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // İlçe seçimi (sadece şehir seçildiyse göster)
              if (_selectedRegion != null && _selectedRegion != 'Not Specified' && _districts.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'District',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.place),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'Not Specified',
                      child: Text('Not Specified'),
                    ),
                    ..._districts.map((district) {
                      return DropdownMenuItem(
                        value: district.name,
                        child: Text(district.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedDistrict = value);
                  },
                ),
              
              if (_selectedRegion != null && _selectedRegion != 'Not Specified' && _districts.isNotEmpty)
                const SizedBox(height: 16),
              if (_isLoadingLocations) ...[
                const SizedBox(height: 8),
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
              
              const SizedBox(height: 24),
              
              // Satıcı bilgileri
              _buildSectionTitle('Satıcı Bilgileri'),
              const SizedBox(height: 16),
              
              // Satıcı adı
              TextFormField(
                controller: _sellerNameController,
                decoration: const InputDecoration(
                  labelText: 'Adınız *',
                  hintText: 'Örn: Ahmet Yılmaz',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ad soyad gerekli';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // İletişim kanalları
              ContactMethodSelector(
                initialMethods: _selectedContactMethods,
                onMethodsChanged: (methods) {
                  setState(() {
                    _selectedContactMethods = methods;
                  });
                },
                title: 'İletişim Bilgileri',
                isRequired: true,
                maxMethods: 3,
              ),
              
              const SizedBox(height: 24),
              
              // Premium seçeneği
              _buildSectionTitle('Ek Seçenekler'),
              const SizedBox(height: 16),
              
              SwitchListTile(
                title: const Text('Premium İlan'),
                subtitle: const Text('İlanınız listenin üstünde görüntülenir'),
                value: _isPremium,
                onChanged: (value) {
                  setState(() => _isPremium = value);
                },
                activeColor: const Color(0xFF667eea),
              ),
              
              const SizedBox(height: 32),
              
              // Kaydet butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Ürünü Yayınla',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bilgi notu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'İletişim bilgileriniz sadece ürünle ilgilenen kişilere gösterilecektir.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF667eea),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // İletişim kanalı kontrolü
    if (_selectedContactMethods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En az bir iletişim kanalı seçmelisiniz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = await AuthService().getCurrentUser();
      if (currentUser == null) {
        _showErrorDialog('Giriş yapmalısınız');
        return;
      }

      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrls: [], // Resim yükleme özelliği eklenecek
        sellerId: currentUser.id,
        sellerName: _sellerNameController.text.trim(),
        contactMethods: _selectedContactMethods,
        createdAt: DateTime.now(),
        region: _selectedRegion!,
        district: _selectedDistrict != 'Not Specified' ? _selectedDistrict : null,
        category: _selectedCategory!,
        isPremium: _isPremium,
      );

      final success = await DatabaseService().createProduct(product);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ürün başarıyla yayınlandı!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        _showErrorDialog('Ürün yayınlanırken hata oluştu');
      }
    } catch (e) {
      _showErrorDialog('Beklenmeyen hata: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
