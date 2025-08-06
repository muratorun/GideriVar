import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/contact_method.dart';

class ContactMethodSelector extends StatefulWidget {
  final List<ContactMethod> initialMethods;
  final Function(List<ContactMethod>) onMethodsChanged;
  final bool isRequired;
  final int maxMethods;
  final String? title;

  const ContactMethodSelector({
    super.key,
    this.initialMethods = const [],
    required this.onMethodsChanged,
    this.isRequired = true,
    this.maxMethods = 3,
    this.title,
  });

  @override
  State<ContactMethodSelector> createState() => _ContactMethodSelectorState();
}

class _ContactMethodSelectorState extends State<ContactMethodSelector> {
  late List<ContactMethod> _selectedMethods;
  ContactMethodType? _selectedType;
  final TextEditingController _valueController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _selectedMethods = List.from(widget.initialMethods);
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _startAdding() {
    setState(() {
      _isAdding = true;
      _selectedType = null;
      _valueController.clear();
    });
  }

  void _cancelAdding() {
    setState(() {
      _isAdding = false;
      _selectedType = null;
      _valueController.clear();
    });
  }

  void _addMethod() {
    if (_selectedType == null) {
      _showSnackBar('Lütfen bir iletişim kanalı seçin');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final method = ContactMethod(
      type: _selectedType!,
      value: _valueController.text.trim(),
      createdAt: DateTime.now(),
    );

    // Check if method already exists
    if (_selectedMethods.any((m) => m.type == method.type)) {
      _showSnackBar('Bu iletişim kanalı zaten eklenmiş');
      return;
    }

    setState(() {
      _selectedMethods.add(method);
      _isAdding = false;
      _selectedType = null;
      _valueController.clear();
    });

    widget.onMethodsChanged(_selectedMethods);
  }

  void _removeMethod(ContactMethod method) {
    setState(() {
      _selectedMethods.remove(method);
    });
    widget.onMethodsChanged(_selectedMethods);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<ContactMethodType> get _availableTypes {
    return ContactMethodType.values
        .where((type) => !_selectedMethods.any((m) => m.type == type))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                  color: theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title ?? 'İletişim Bilgileri',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.isRequired)
                  Text(
                    ' *',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Helper text
            Text(
              'Müşterilerinizin sizinle iletişim kurabilmesi için en az bir iletişim kanalı eklemelisiniz.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Selected methods list
            if (_selectedMethods.isNotEmpty) ...[
              ...(_selectedMethods.map((method) => _buildMethodCard(method))),
              const SizedBox(height: 16),
            ],
            
            // Add new method section
            if (_isAdding) ...[
              _buildAddMethodForm(),
            ] else ...[
              _buildAddButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(ContactMethod method) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: method.color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: method.color.withOpacity(0.05),
      ),
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
          method.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          method.formattedValue,
          style: theme.textTheme.bodyMedium,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: theme.colorScheme.error,
          onPressed: () => _removeMethod(method),
          tooltip: 'Kaldır',
        ),
      ),
    );
  }

  Widget _buildAddMethodForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Method type selection
          Text(
            'İletişim Kanalı Seçin:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTypes.map((type) {
              final method = ContactMethod(type: type, value: '');
              final isSelected = _selectedType == type;
              
              return FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      method.icon,
                      size: 16,
                      color: isSelected ? Colors.white : method.color,
                    ),
                    const SizedBox(width: 4),
                    Text(method.displayName),
                  ],
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? type : null;
                    _valueController.clear();
                  });
                },
                selectedColor: method.color,
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Value input
          if (_selectedType != null) ...[
            _buildValueInput(),
            const SizedBox(height: 16),
          ],
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelAdding,
                  child: const Text('İptal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedType != null ? _addMethod : null,
                  child: const Text('Ekle'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueInput() {
    if (_selectedType == null) return const SizedBox();
    
    final method = ContactMethod(type: _selectedType!, value: '');
    
    return TextFormField(
      controller: _valueController,
      keyboardType: method.keyboardType,
      decoration: InputDecoration(
        labelText: method.displayName,
        hintText: method.hintText,
        prefixText: method.prefix,
        prefixIcon: Icon(method.icon, color: method.color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: method.color.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: method.color, width: 2),
        ),
      ),
      validator: method.validate,
      inputFormatters: _getInputFormatters(_selectedType!),
    );
  }

  Widget _buildAddButton() {
    final canAdd = _selectedMethods.length < widget.maxMethods && 
                   _availableTypes.isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: canAdd ? _startAdding : null,
        icon: const Icon(Icons.add),
        label: Text(
          _selectedMethods.isEmpty 
              ? 'İletişim Kanalı Ekle'
              : 'Başka Kanal Ekle',
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  List<TextInputFormatter> _getInputFormatters(ContactMethodType type) {
    switch (type) {
      case ContactMethodType.phone:
      case ContactMethodType.whatsapp:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s()-]')),
          LengthLimitingTextInputFormatter(20),
        ];
      case ContactMethodType.email:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          LengthLimitingTextInputFormatter(50),
        ];
      case ContactMethodType.instagram:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
          LengthLimitingTextInputFormatter(30),
        ];
    }
  }
}
