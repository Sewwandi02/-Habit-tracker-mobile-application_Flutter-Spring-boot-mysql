import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../utils/constants.dart';

class HabitFormData {
  const HabitFormData({
    required this.title,
    required this.description,
    required this.category,
    required this.dailyTarget,
    required this.color,
    required this.icon,
  });

  final String title;
  final String description;
  final String category;
  final int dailyTarget;
  final String color;
  final String icon;
}

Future<HabitFormData?> showHabitDialog(
  BuildContext context, {
  Habit? existingHabit,
}) {
  return showDialog<HabitFormData>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return _HabitDialog(existingHabit: existingHabit);
    },
  );
}

class _HabitDialog extends StatefulWidget {
  const _HabitDialog({this.existingHabit});

  final Habit? existingHabit;

  @override
  State<_HabitDialog> createState() => _HabitDialogState();
}

class _HabitDialogState extends State<_HabitDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _targetController;
  late String _selectedCategory;
  late String _selectedColor;
  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    final habit = widget.existingHabit;
    _titleController = TextEditingController(text: habit?.title ?? '');
    _descriptionController = TextEditingController(text: habit?.description ?? '');
    _targetController = TextEditingController(text: (habit?.dailyTarget ?? 1).toString());
    _selectedCategory = habit?.category ?? AppConstants.habitCategories.first;
    _selectedColor = habit?.color ?? AppConstants.habitColors.keys.first;
    _selectedIcon = habit?.icon ?? AppConstants.habitIcons.keys.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingHabit != null;
    final primaryColor = AppConstants.habitColors[_selectedColor] ?? const Color(0xFF136F63);

    return AlertDialog(
      title: Text(isEditing ? 'Edit habit' : 'Add habit'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Enter a habit name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Enter a habit description.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.habitCategories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Daily Target',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed < 1) {
                    return 'Enter a valid target of at least 1.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Color',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AppConstants.habitColors.entries.map((entry) {
                      final colorKey = entry.key;
                      final colorValue = entry.value;
                      final isSelected = _selectedColor == colorKey;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = colorKey),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorValue,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 2.5)
                                : Border.all(color: Colors.transparent),
                            boxShadow: isSelected
                                ? [BoxShadow(color: colorValue.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 3))]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Icon',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AppConstants.habitIcons.entries.map((entry) {
                      final iconKey = entry.key;
                      final iconValue = entry.value;
                      final isSelected = _selectedIcon == iconKey;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = iconKey),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor.withValues(alpha: 0.15)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey.shade300,
                              width: 1.6,
                            ),
                          ),
                          child: Icon(
                            iconValue,
                            color: isSelected ? primaryColor : Colors.grey.shade600,
                            size: 22,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      HabitFormData(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        dailyTarget: int.parse(_targetController.text.trim()),
        color: _selectedColor,
        icon: _selectedIcon,
      ),
    );
  }
}