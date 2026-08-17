import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class CreateMeetingScreen extends StatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _selectedVillage;
  final TextEditingController _attendeesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  static const List<String> _villages = [
    'Chandpur',
    'Kothrud',
    'Ambegaon',
    'Mandvi',
    'Baramati',
  ];

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: AppColors.textOnPrimary,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  String get _formattedDate {
    if (_selectedDate == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[_selectedDate!.month - 1]} ${_selectedDate!.day}, ${_selectedDate!.year}';
  }

  void _saveMeeting() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meeting saved successfully!'),
          backgroundColor: AppColors.secondaryTerracotta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.spacingSm),
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _attendeesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text(
          'Create Meeting',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section Header
              const _SectionHeader(
                icon: Icons.event_rounded,
                title: 'Meeting Details',
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // Date Picker
              _FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Date'),
                    const SizedBox(height: AppConstants.spacingSm),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                      child: InputDecorator(
                        decoration: _inputDecoration(
                          hint: 'Select date',
                          prefixIcon: Icons.calendar_today_rounded,
                        ),
                        child: Text(
                          _selectedDate != null ? _formattedDate : 'Select date',
                          style: TextStyle(
                            color: _selectedDate != null
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),

                    // Village Dropdown
                    const _FieldLabel(label: 'Village'),
                    const SizedBox(height: AppConstants.spacingSm),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedVillage,
                      decoration: _inputDecoration(
                        hint: 'Select village',
                        prefixIcon: Icons.location_city_rounded,
                      ),
                      items: _villages.map((village) {
                        return DropdownMenuItem(
                          value: village,
                          child: Text(village),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedVillage = value),
                      validator: (value) =>
                          value == null ? 'Please select a village' : null,
                      dropdownColor: AppColors.surfaceCard,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),

                    // Attendees
                    const _FieldLabel(label: 'Expected Attendees'),
                    const SizedBox(height: AppConstants.spacingSm),
                    TextFormField(
                      controller: _attendeesController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        hint: 'Number of attendees',
                        prefixIcon: Icons.people_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of attendees';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Photo Section
              const _SectionHeader(
                icon: Icons.photo_camera_rounded,
                title: 'Photo',
              ),
              const SizedBox(height: AppConstants.spacingMd),
              _FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Meeting Photo'),
                    const SizedBox(height: AppConstants.spacingSm),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Camera feature coming soon'),
                            backgroundColor: AppColors.info,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.spacingSm),
                            ),
                          ),
                        );
                      },
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                      child: CustomPaint(
                        painter: _DashedBorderPainter(
                          color: AppColors.primaryGreen.withValues(alpha: 0.5),
                          borderRadius: AppConstants.radiusMd,
                          dashWidth: 8,
                          dashSpace: 5,
                          strokeWidth: 2,
                        ),
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen
                                .withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusMd),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingSm + 4),
                              const Text(
                                'Tap to attach photo',
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'JPG, PNG up to 10MB',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Notes Section
              const _SectionHeader(
                icon: Icons.notes_rounded,
                title: 'Notes',
              ),
              const SizedBox(height: AppConstants.spacingMd),
              _FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Meeting Notes'),
                    const SizedBox(height: AppConstants.spacingSm),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 5,
                      decoration: _inputDecoration(
                        hint:
                            'Enter agenda, discussion points, or any additional notes...',
                        prefixIcon: null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg + 8),

              // Save Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveMeeting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryTerracotta,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLg),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, size: 20),
                      SizedBox(width: AppConstants.spacingSm),
                      Text('Save Meeting'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.primaryGreen, size: 20)
          : null,
      filled: true,
      fillColor: AppColors.backgroundCream,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: BorderSide(color: AppColors.textHint.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: BorderSide(color: AppColors.textHint.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide:
            const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm + 4,
      ),
    );
  }
}

// -- Helper Widgets ---

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(width: AppConstants.spacingSm),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;

  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: child,
      ),
    );
  }
}

// -- Dashed Border Painter ---

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          end > metric.length ? metric.length : end,
        );
        canvas.drawPath(extractPath, paint);
        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}
