import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../address/presentation/cubit/address_cubit.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

class BookingCreateScreen extends StatefulWidget {
  final String serviceId;
  final double servicePrice;

  const BookingCreateScreen({
    super.key,
    required this.serviceId,
    required this.servicePrice,
  });

  @override
  State<BookingCreateScreen> createState() => _BookingCreateScreenState();
}

class _BookingCreateScreenState extends State<BookingCreateScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  String? _selectedAddressId;
  final _notesCtrl = TextEditingController();

  final _slots = ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM', '06:00 PM'];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingCreated) {
          context.go(AppRoutes.bookingDetailPath(state.booking.id));
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Book Service')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker
              Text('Select Date', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _DateSelector(
                selected: _selectedDate,
                onDateSelected: (d) => setState(() => _selectedDate = d),
              ),
              const SizedBox(height: 24),

              // Time slot
              Text('Select Time', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _slots.map((slot) {
                  final selected = slot == _selectedSlot;
                  return InkWell(
                    onTap: () => setState(() => _selectedSlot = slot),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Address
              Text('Select Address', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              BlocBuilder<AddressCubit, AddressState>(
                builder: (context, state) {
                  if (state is AddressLoaded) {
                    return Column(
                      children: [
                        ...state.addresses.map((addr) => RadioListTile<String>(
                              value: addr.id,
                              groupValue: _selectedAddressId,
                              onChanged: (v) => setState(() => _selectedAddressId = v),
                              title: Text(addr.label),
                              subtitle: Text(addr.shortDisplay,
                                  style: const TextStyle(fontSize: 12)),
                              activeColor: AppColors.primary,
                              contentPadding: EdgeInsets.zero,
                            )),
                        TextButton.icon(
                          onPressed: () => context.push(AppRoutes.address),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add New Address'),
                        ),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),

              const SizedBox(height: 24),

              // Notes
              Text('Special Instructions (optional)', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g. Please bring eco-friendly products',
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: (_selectedSlot != null && _selectedAddressId != null && state is! BookingLoading)
                      ? () {
                          // Parse slot like '02:00 PM' into a 24-hour hour value
                          final slotParts = _selectedSlot!.split(' ');
                          final timeParts = slotParts[0].split(':');
                          int hour = int.parse(timeParts[0]);
                          final isPM = slotParts.length > 1 && slotParts[1].toUpperCase() == 'PM';
                          if (isPM && hour != 12) hour += 12;
                          if (!isPM && hour == 12) hour = 0;
                          final scheduledAt = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            hour,
                          );
                          context.read<BookingBloc>().add(
                                BookingCreateRequested(
                                  serviceId: widget.serviceId,
                                  addressId: _selectedAddressId!,
                                  scheduledAt: scheduledAt,
                                  amount: widget.servicePrice,
                                  notes: _notesCtrl.text.trim(),
                                ),
                              );
                        }
                      : null,
                  child: state is BookingLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Confirm Booking'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onDateSelected;

  const _DateSelector({required this.selected, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dates = List.generate(7, (i) => now.add(Duration(days: i)));

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final date = dates[i];
          final isSelected = date.day == selected.day &&
              date.month == selected.month &&
              date.year == selected.year;

          return InkWell(
            onTap: () => onDateSelected(date),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 52,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
