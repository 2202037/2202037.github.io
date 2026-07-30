import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../models/doctor_model.dart';
import '../../providers/appointments_provider.dart';
import '../../providers/doctors_provider.dart';
import '../../shared/widgets/custom_button.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final int doctorId;

  const BookAppointmentScreen({super.key, required this.doctorId});

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends ConsumerState<BookAppointmentScreen> {
  DateTime _selectedDay = DateTime.now().add(const Duration(days: 1));
  DateTime _focusedDay = DateTime.now();
  String? _selectedTimeSlot;
  final _notesController = TextEditingController();
  int _selectedPeriod = 0; // 0=morning, 1=afternoon, 2=evening

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<String> get _currentSlots {
    switch (_selectedPeriod) {
      case 1:
        return AppConstants.afternoonSlots;
      case 2:
        return AppConstants.eveningSlots;
      default:
        return AppConstants.morningSlots;
    }
  }

  Future<void> _confirmBooking(DoctorModel doctor) async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a time slot'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final success = await ref.read(appointmentsProvider.notifier).bookAppointment(
          doctorId: widget.doctorId,
          date: _selectedDay,
          timeSlot: _selectedTimeSlot!,
          notes: _notesController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your appointment with ${doctor.name} on ${AppDateUtils.formatDate(_selectedDay)} at $_selectedTimeSlot has been booked.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home/appointments');
              },
              child: const Text(
                'View Appointments',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      final error = ref.read(appointmentsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Booking failed. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = ref.watch(doctorByIdProvider(widget.doctorId));
    final apptState = ref.watch(appointmentsProvider);

    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Appointment')),
        body: const Center(child: Text('Doctor not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info Card
            _buildDoctorCard(doctor),
            const SizedBox(height: 20),

            // Calendar
            _buildCalendar(),
            const SizedBox(height: 20),

            // Time Period Tabs
            const Text(
              'Select Time',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildPeriodTabs(),
            const SizedBox(height: 12),
            _buildTimeSlots(),
            const SizedBox(height: 20),

            // Notes
            const Text(
              'Additional Notes (Optional)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Describe your symptoms or concerns...',
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textHint,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Fee Summary
            _buildFeeSummary(doctor),
            const SizedBox(height: 24),

            // Book Button
            CustomButton(
              label: 'Confirm Booking',
              isLoading: apptState.isBooking,
              onPressed: () => _confirmBooking(doctor),
              icon: Icons.check_circle_outline_rounded,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              doctor.initials,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  doctor.specialty,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                doctor.formattedFee,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'per visit',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 60)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
            _selectedTimeSlot = null;
          });
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
          todayTextStyle: const TextStyle(
            color: AppColors.primary,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          defaultTextStyle: const TextStyle(fontFamily: 'Poppins'),
          weekendTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.error,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon:
              Icon(Icons.chevron_left_rounded, color: AppColors.primary),
          rightChevronIcon:
              Icon(Icons.chevron_right_rounded, color: AppColors.primary),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          weekendStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodTabs() {
    final periods = ['🌅 Morning', '☀️ Afternoon', '🌙 Evening'];
    return Row(
      children: periods.asMap().entries.map((entry) {
        final isSelected = _selectedPeriod == entry.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedPeriod = entry.key;
              _selectedTimeSlot = null;
            }),
            child: Container(
              margin: EdgeInsets.only(right: entry.key < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                entry.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlots() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _currentSlots.length,
      itemBuilder: (context, index) {
        final slot = _currentSlots[index];
        final isSelected = _selectedTimeSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedTimeSlot = slot),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Center(
              child: Text(
                slot,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeeSummary(DoctorModel doctor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Consultation Fee',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                doctor.formattedFee,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                doctor.formattedFee,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
