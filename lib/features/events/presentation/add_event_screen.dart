import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../districts/providers/districts_provider.dart';
import '../providers/events_provider.dart';
import 'event_detail_screen.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _addressController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _dateController = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
  final _timeController = TextEditingController(text: '16:00:00');

  String _selectedCategory = 'temple';
  int? _selectedDistrictId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _addressController.dispose();
    _imageUrlController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDistrictId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a district.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(eventsRepositoryProvider);
      final newEvent = await repo.createEvent({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'district': _selectedDistrictId,
        'venue_name': _venueController.text.trim(),
        'address': _addressController.text.trim(),
        'event_date': _dateController.text.trim(),
        'start_time': _timeController.text.trim(),
        'cover_image': _imageUrlController.text.trim(),
      });

      ref.invalidate(happeningNowEventsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event submitted! Needs 3 community verifications.')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: newEvent.id)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit event.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final districtsAsync = ref.watch(districtsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add New Event', style: AppTypography.titleMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event Details', style: AppTypography.headlineLarge.copyWith(fontSize: 22)),
              const SizedBox(height: 4),
              Text('New events go live after receiving 3 community verifications.', style: AppTypography.bodySmall),

              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title *', hintText: 'e.g. Thrissur Pooram 2026'),
                validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'temple', child: Text('Temple Festival')),
                  DropdownMenuItem(value: 'church', child: Text('Church Feast')),
                  DropdownMenuItem(value: 'dj_music', child: Text('DJ & Music Show')),
                  DropdownMenuItem(value: 'beach_meetup', child: Text('Beach Meetup')),
                  DropdownMenuItem(value: 'arts_culture', child: Text('Arts & Culture')),
                  DropdownMenuItem(value: 'food_fest', child: Text('Food Festival')),
                  DropdownMenuItem(value: 'community', child: Text('Community Gathering')),
                ],
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),

              const SizedBox(height: 16),
              districtsAsync.when(
                data: (districts) {
                  return DropdownButtonFormField<int>(
                    value: _selectedDistrictId,
                    decoration: const InputDecoration(labelText: 'District *'),
                    hint: const Text('Select District'),
                    items: districts
                        .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedDistrictId = val),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading districts'),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Venue Name *', hintText: 'e.g. Calicut Trade Centre'),
                validator: (val) => val == null || val.isEmpty ? 'Venue name is required' : null,
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Full Address', hintText: 'Street / Landmark address'),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(labelText: 'Event Date (YYYY-MM-DD)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      decoration: const InputDecoration(labelText: 'Start Time (HH:MM:SS)'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Cover Image URL', hintText: 'https://example.com/image.jpg'),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', hintText: 'Describe the event schedule, highlights, etc.'),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEvent,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Event for Verification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
