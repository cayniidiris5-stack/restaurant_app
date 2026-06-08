// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unnecessary_import, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../constants/app_colors.dart';
import '../../constants/api_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});
  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _newCategoryCtrl = TextEditingController();

  XFile? _imageFile;
  Uint8List? _imageBytes;
  bool _uploading = false;
  String? _selectedCategory;
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  Future<void> _loadCategories() async {
    final mealProv = context.read<MealProvider>();
    await mealProv.fetchCategories();
    final cats = mealProv.dbCategories;
    if (mounted) {
      setState(() {
        _selectedCategory = cats.isNotEmpty ? cats.first : null;
        _loadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageFile = picked;
        _imageBytes = bytes;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Select Image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ImageSourceBtn(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ImageSourceBtn(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    _newCategoryCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('New Category',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _newCategoryCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Soups, Juices...',
              prefixIcon: const Icon(Icons.category_outlined,
                  color: AppColors.primary),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = _newCategoryCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                final token = context.read<AuthProvider>().token;
                final ok =
                    await context.read<MealProvider>().addCategory(name, token);
                if (mounted) {
                  if (ok) {
                    setState(() => _selectedCategory = name);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Category "$name" added!'),
                      backgroundColor: AppColors.success,
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Category already exists or failed'),
                      backgroundColor: AppColors.error,
                    ));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitMeal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a meal image'),
            backgroundColor: AppColors.error),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _uploading = true);

    try {
      final token = context.read<AuthProvider>().token;
      final request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/api/meals'))
            ..headers['Authorization'] = 'Bearer $token'
            ..fields['name'] = _nameCtrl.text.trim()
            ..fields['description'] = _descCtrl.text.trim()
            ..fields['price'] = _priceCtrl.text.trim()
            ..fields['category'] = _selectedCategory!
            ..files.add(http.MultipartFile.fromBytes(
              'image',
              _imageBytes!,
              filename: _imageFile!.name,
            ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 201) {
        await context.read<MealProvider>().fetchMeals();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text('Meal added successfully!',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context);
      } else {
        String errorMsg = 'Failed to add meal (${response.statusCode})';
        try {
          final body = jsonDecode(response.body);
          errorMsg = body['message'] ?? errorMsg;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(errorMsg)),
          ]),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text('Connection error: $e')),
          ]),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mealProv = context.watch<MealProvider>();
    final categories = mealProv.dbCategories;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Add New Item',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
        elevation: 0,
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.primary)),
      ),
      body: _loadingCategories
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image Picker ──────────────────────────────────
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 2,
                              style: BorderStyle.solid),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10)
                          ],
                        ),
                        child: _imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.memory(_imageBytes!,
                                    fit: BoxFit.cover,
                                    width: double.infinity),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withOpacity(0.12),
                                        shape: BoxShape.circle),
                                    child: const Icon(
                                        Icons.add_a_photo_rounded,
                                        color: AppColors.primary,
                                        size: 30),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Tap to add item image',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('Camera or Gallery',
                                      style: TextStyle(
                                          color: isDark
                                              ? AppColors.darkSubtext
                                              : AppColors.lightSubtext,
                                          fontSize: 12)),
                                ],
                              ),
                      ),
                    ),
                    if (_imageBytes != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(Icons.refresh,
                              size: 16, color: AppColors.primary),
                          label: const Text('Change Image',
                              style: TextStyle(color: AppColors.primary)),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // ── Name ─────────────────────────────────────────
                    _buildLabel('Item Name', isDark),
                    const SizedBox(height: 8),
                    _buildField(
                        controller: _nameCtrl,
                        hint: 'e.g. Baasto iyo Hilib, Mango Juice...',
                        icon: Icons.restaurant_menu,
                        validator: (v) => v!.isEmpty ? 'Required' : null),

                    const SizedBox(height: 16),
                    // ── Description ───────────────────────────────────
                    _buildLabel('Description', isDark),
                    const SizedBox(height: 8),
                    _buildField(
                        controller: _descCtrl,
                        hint: 'Describe the item...',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                        validator: (v) => v!.isEmpty ? 'Required' : null),

                    const SizedBox(height: 16),
                    // ── Price ─────────────────────────────────────────
                    _buildLabel('Price (\$)', isDark),
                    const SizedBox(height: 8),
                    _buildField(
                        controller: _priceCtrl,
                        hint: 'e.g. 12.99',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v!.isEmpty) return 'Required';
                          if (double.tryParse(v) == null)
                            return 'Enter a valid price';
                          return null;
                        }),

                    const SizedBox(height: 16),
                    // ── Category ──────────────────────────────────────
                    Row(
                      children: [
                        Expanded(child: _buildLabel('Category', isDark)),
                        TextButton.icon(
                          onPressed: _showAddCategoryDialog,
                          icon: const Icon(Icons.add_circle_outline,
                              color: AppColors.primary, size: 18),
                          label: const Text('New Category',
                              style: TextStyle(
                                  color: AppColors.primary, fontSize: 13)),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider),
                      ),
                      child: categories.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(children: [
                                const Icon(Icons.category_outlined,
                                    color: AppColors.primary),
                                const SizedBox(width: 12),
                                Text('No categories yet — add one above',
                                    style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkSubtext
                                            : AppColors.lightSubtext)),
                              ]),
                            )
                          : DropdownButtonFormField<String>(
                              value: categories.contains(_selectedCategory)
                                  ? _selectedCategory
                                  : categories.first,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.category_outlined,
                                    color: AppColors.primary),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 14),
                              ),
                              dropdownColor: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightCard,
                              items: categories
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCategory = v),
                            ),
                    ),

                    const SizedBox(height: 32),
                    // ── Submit ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _uploading ? null : _submitMeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _uploading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2)),
                                  SizedBox(width: 12),
                                  Text('Uploading...',
                                      style: TextStyle(fontSize: 16)),
                                ])
                            : const Text('Add Item',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text, bool isDark) => Text(text,
      style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.lightText));

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            maxLines == 1 ? Icon(icon, color: AppColors.primary) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        filled: true,
      ),
    );
  }
}

class _ImageSourceBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ImageSourceBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
