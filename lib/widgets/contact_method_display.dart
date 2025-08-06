import 'package:flutter/material.dart';
import '../models/contact_method.dart';
import '../services/contact_method_service.dart';

class ContactMethodDisplay extends StatelessWidget {
  final List<ContactMethod> contactMethods;
  final String title;
  final bool showRewardedAdFirst;
  final VoidCallback? onAdCompleted;

  const ContactMethodDisplay({
    super.key,
    required this.contactMethods,
    this.title = 'İletişim Bilgileri',
    this.showRewardedAdFirst = false,
    this.onAdCompleted,
  });

  @override
  Widget build(BuildContext context) {
    if (contactMethods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.contact_page,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Info text
            if (showRewardedAdFirst)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'İletişim bilgilerini görmek için kısa bir reklam izlemeniz gerekiyor.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Contact methods
            ...contactMethods.map((method) => _buildContactMethodTile(context, method)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethodTile(BuildContext context, ContactMethod method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: method.color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            method.icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          ContactMethodService.getContactDisplayText(method),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          method.formattedValue,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () => _handleContactTap(context, method),
        tileColor: method.color.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: method.color.withOpacity(0.2)),
        ),
      ),
    );
  }

  void _handleContactTap(BuildContext context, ContactMethod method) async {
    if (showRewardedAdFirst && onAdCompleted != null) {
      // Show rewarded ad first
      _showAdConfirmationDialog(context, method);
    } else {
      await _launchContact(context, method);
    }
  }

  void _showAdConfirmationDialog(BuildContext context, ContactMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reklam İzle'),
        content: Text(
          'İletişim bilgilerini görmek için kısa bir reklam izlemeniz gerekiyor. '
          '${ContactMethodService.getContactDisplayText(method)} için devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onAdCompleted?.call();
              // After ad completion, launch contact
              _launchContact(context, method);
            },
            child: const Text('Reklam İzle'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchContact(BuildContext context, ContactMethod method) async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ContactMethodService.getContactActionText(method)),
        duration: const Duration(seconds: 1),
        backgroundColor: method.color,
      ),
    );

    final success = await ContactMethodService.launchContactMethod(method);
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${method.displayName} açılamadı. Lütfen tekrar deneyin.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Alternative compact version for product cards
class ContactMethodChips extends StatelessWidget {
  final List<ContactMethod> contactMethods;
  final int maxVisible;
  final bool showRewardedAdFirst;
  final VoidCallback? onAdCompleted;

  const ContactMethodChips({
    super.key,
    required this.contactMethods,
    this.maxVisible = 3,
    this.showRewardedAdFirst = false,
    this.onAdCompleted,
  });

  @override
  Widget build(BuildContext context) {
    if (contactMethods.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleMethods = contactMethods.take(maxVisible).toList();
    final remainingCount = contactMethods.length - maxVisible;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ...visibleMethods.map((method) => _buildContactChip(context, method)),
        
        if (remainingCount > 0)
          Chip(
            label: Text('+$remainingCount'),
            labelStyle: const TextStyle(fontSize: 12),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Widget _buildContactChip(BuildContext context, ContactMethod method) {
    return ActionChip(
      avatar: Icon(
        method.icon,
        size: 16,
        color: method.color,
      ),
      label: Text(
        method.displayName,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () => _handleContactTap(context, method),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: method.color.withOpacity(0.3)),
    );
  }

  void _handleContactTap(BuildContext context, ContactMethod method) async {
    if (showRewardedAdFirst && onAdCompleted != null) {
      onAdCompleted?.call();
    }
    
    final success = await ContactMethodService.launchContactMethod(method);
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${method.displayName} açılamadı'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
