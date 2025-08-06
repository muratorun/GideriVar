import 'package:flutter/material.dart';
import '../models/contact_method.dart';
import '../widgets/contact_method_selector.dart';

class ContactMethodDemoScreen extends StatefulWidget {
  const ContactMethodDemoScreen({super.key});

  @override
  State<ContactMethodDemoScreen> createState() => _ContactMethodDemoScreenState();
}

class _ContactMethodDemoScreenState extends State<ContactMethodDemoScreen> {
  List<ContactMethod> selectedMethods = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İletişim Kanalı Seçimi'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'İletişim Kanalı Seçimi',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kullanıcılar ürününüzle ilgilendiklerinde sizinle nasıl iletişim kurmak istediklerini seçebilirler. '
                      'En az bir iletişim kanalı seçmeniz gereklidir.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contact Method Selector
            ContactMethodSelector(
              initialMethods: selectedMethods,
              onMethodsChanged: (methods) {
                setState(() {
                  selectedMethods = methods;
                });
              },
              title: 'İletişim Bilgileriniz',
              isRequired: true,
              maxMethods: 4,
            ),

            const SizedBox(height: 24),

            // Preview Section
            if (selectedMethods.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.preview,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Müşteri Görünümü',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Müşteriler ürününüzü gördüklerinde şu iletişim seçenekleri görecekler:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      ...selectedMethods.map((method) => _buildPreviewMethod(method)),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedMethods.clear();
                      });
                    },
                    child: const Text('Temizle'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedMethods.isNotEmpty 
                        ? () => _saveContactMethods()
                        : null,
                    child: const Text('Kaydet'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewMethod(ContactMethod method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: method.color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            method.icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        title: Text(
          '${method.displayName} ile İletişim',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          method.formattedValue,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey[400],
        ),
        tileColor: method.color.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: method.color.withOpacity(0.2)),
        ),
      ),
    );
  }

  void _saveContactMethods() {
    if (selectedMethods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En az bir iletişim kanalı seçmelisiniz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Here you would save to Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedMethods.length} iletişim kanalı kaydedildi'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Görüntüle',
          onPressed: () {
            _showSavedMethods();
          },
        ),
      ),
    );
  }

  void _showSavedMethods() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydedilen İletişim Kanalları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: selectedMethods.map((method) {
            return ListTile(
              leading: Icon(method.icon, color: method.color),
              title: Text(method.displayName),
              subtitle: Text(method.formattedValue),
            );
          }).toList(),
        ),
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
