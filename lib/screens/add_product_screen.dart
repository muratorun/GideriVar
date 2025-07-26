import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
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
  final _contactInfoController = TextEditingController();
  final _sellerNameController = TextEditingController();
  
  String? _selectedRegion;
  String? _selectedCategory;
  ContactType _selectedContactType = ContactType.phone;
  bool _isPremium = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contactInfoController.dispose();
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
              
              // Bölge seçimi
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: const InputDecoration(
                  labelText: 'Şehir *',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.turkishCities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedRegion = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Şehir seçimi gerekli';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Satıcı bilgileri
              _buildSectionTitle('İletişim Bilgileri'),
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
              
              const SizedBox(height: 16),
              
              // İletişim türü
              const Text(
                'İletişim Türü *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                children: ContactType.values.map((type) {
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(type.icon),
                        const SizedBox(width: 4),
                        Text(type.displayName),
                      ],
                    ),
                    selected: _selectedContactType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedContactType = type);
                      }
                    },
                    selectedColor: const Color(0xFF667eea).withOpacity(0.2),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // İletişim bilgisi
              TextFormField(
                controller: _contactInfoController,
                decoration: InputDecoration(
                  labelText: '${_selectedContactType.displayName} *',
                  hintText: _getContactHint(_selectedContactType),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '${_selectedContactType.displayName} gerekli';
                  }
                  return _validateContact(_selectedContactType, value.trim());
                },
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

  String _getContactHint(ContactType type) {
    switch (type) {
      case ContactType.phone:
        return '+90 555 123 45 67';
      case ContactType.whatsapp:
        return '+90 555 123 45 67';
      case ContactType.email:
        return 'ornek@email.com';
      case ContactType.instagram:
        return '@kullanici_adi';
    }
  }

  String? _validateContact(ContactType type, String value) {
    switch (type) {
      case ContactType.phone:
      case ContactType.whatsapp:
        if (!RegExp(r'^(\+90|0)?[5][0-9]{9}$').hasMatch(value.replaceAll(' ', ''))) {
          return 'Geçerli bir telefon numarası girin';
        }
        break;
      case ContactType.email:
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Geçerli bir e-posta adresi girin';
        }
        break;
      case ContactType.instagram:
        if (!value.startsWith('@') || value.length < 2) {
          return 'Instagram kullanıcı adı @ ile başlamalı';
        }
        break;
    }
    return null;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
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
        contactType: _selectedContactType,
        contactInfo: _contactInfoController.text.trim(),
        createdAt: DateTime.now(),
        region: _selectedRegion!,
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
