import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_picker_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placeCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  String _wasteType = 'Plastic';
  File? _image;
  bool _loading = false;
  double? _latitude;
  double? _longitude;

  final List<String> _wasteTypes = [
    'Plastic', 'Organic', 'E-waste', 'Metal', 'Glass', 'Other'
  ];

  final Map<String, Color> _typeColors = {
    'Plastic': const Color(0xFF29B6F6),
    'Organic': const Color(0xFF66BB6A),
    'E-waste': const Color(0xFFEF5350),
    'Metal':   const Color(0xFF78909C),
    'Glass':   const Color(0xFF26C6DA),
    'Other':   const Color(0xFFBDBDBD),
  };

  @override
  void dispose() {
    _placeCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 1280);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Photo', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PickerOption(icon: Icons.camera_alt, label: 'Camera', onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                }),
                _PickerOption(icon: Icons.photo_library, label: 'Gallery', onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                }),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      _showSnack('Please add a photo of the waste.', AppTheme.warning);
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await ApiService.submitReport(
        place: _placeCtrl.text.trim(),
        wasteType: _wasteType,
        fee: int.tryParse(_feeCtrl.text) ?? 0,
        image: _image!,
        latitude: _latitude,
        longitude: _longitude,
      );
      if (!mounted) return;
      if (result['status'] == 201) {
        _showSnack('🎉 Report submitted! +5 eco points earned.', AppTheme.success);
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        _showSnack('Failed: ${result['data']}', AppTheme.error);
      }
    } catch (e) {
      _showSnack('Error: $e', AppTheme.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Waste'),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker
              GestureDetector(
                onTap: _showImagePicker,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _image != null ? AppTheme.primary : const Color(0xFF2A2F4F),
                      width: 2,
                    ),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                color: AppTheme.primary.withOpacity(0.7), size: 48),
                            const SizedBox(height: 12),
                            const Text('Tap to add waste photo',
                                style: TextStyle(color: AppTheme.textSecondary)),
                            const Text('Camera or Gallery',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Waste type
              const Text('Waste Type', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _wasteTypes.map((type) {
                  final selected = type == _wasteType;
                  final color = _typeColors[type] ?? AppTheme.primary;
                  return GestureDetector(
                    onTap: () => setState(() => _wasteType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? color.withOpacity(0.2) : AppTheme.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? color : const Color(0xFF2A2F4F),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: selected ? color : AppTheme.textSecondary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Place and Map Picker
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _placeCtrl,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Location / Place',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Enter the location of waste' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () async {
                      final LatLng? result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MapPickerScreen()),
                      );
                      if (result != null) {
                        setState(() {
                          _latitude = result.latitude;
                          _longitude = result.longitude;
                          if (_placeCtrl.text.isEmpty) {
                            _placeCtrl.text = '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
                          }
                        });
                        _showSnack('Map location selected!', AppTheme.success);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _latitude != null ? AppTheme.primary.withOpacity(0.2) : AppTheme.card,
                        border: Border.all(
                          color: _latitude != null ? AppTheme.primary : const Color(0xFF2A2F4F),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.map_outlined,
                        color: _latitude != null ? AppTheme.primary : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Fee
              TextFormField(
                controller: _feeCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Estimated Fee (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                  hintText: '0',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter estimated fee (0 if none)';
                  if (int.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_loading ? 'Submitting...' : 'Submit Report'),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  '🌱 You earn +5 eco points for each report',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
