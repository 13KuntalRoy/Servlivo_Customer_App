import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/usecases/create_address_usecase.dart';
import '../cubit/address_cubit.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Addresses')),
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          return switch (state) {
            AddressLoading() => const Center(child: CircularProgressIndicator()),
            AddressError(:final message) => Center(child: Text(message)),
            AddressLoaded(:final addresses) => addresses.isEmpty
                ? const _EmptyAddresses()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _AddressCard(address: addresses[i]),
                  ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Address', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AddressCubit>(),
        child: const _AddAddressSheet(),
      ),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 64, color: AppColors.textHint),
          SizedBox(height: 16),
          Text('No saved addresses', style: TextStyle(color: AppColors.textSecondary)),
          SizedBox(height: 8),
          Text('Add your home or office address\nfor faster bookings',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.textHint, fontSize: 13)),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final dynamic address;

  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              address.label.toLowerCase() == 'home'
                  ? Icons.home_outlined
                  : Icons.work_outline,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(address.label,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Default',
                            style: TextStyle(fontSize: 10, color: AppColors.primary)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(address.fullDisplay,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.read<AddressCubit>().deleteAddress(address.id),
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          ),
        ],
      ),
    );
  }
}

class _AddAddressSheet extends StatefulWidget {
  const _AddAddressSheet();

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController(text: 'Home');
  final _line1Ctrl = TextEditingController();
  final _line2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AddressCubit>().createAddress(
            CreateAddressParams(
              label: _labelCtrl.text.trim(),
              line1: _line1Ctrl.text.trim(),
              line2: _line2Ctrl.text.trim(),
              city: _cityCtrl.text.trim(),
              state: _stateCtrl.text.trim(),
              pinCode: _pinCtrl.text.trim(),
              isDefault: _isDefault,
            ),
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New Address', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextFormField(
                controller: _labelCtrl,
                decoration: const InputDecoration(labelText: 'Label (Home/Office)'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _line1Ctrl,
                decoration: const InputDecoration(labelText: 'Address Line 1'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _line2Ctrl,
                decoration: const InputDecoration(labelText: 'Address Line 2 (optional)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(labelText: 'City'),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stateCtrl,
                      decoration: const InputDecoration(labelText: 'State'),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'PIN Code', counterText: ''),
                validator: (v) => (v?.length ?? 0) < 6 ? 'Enter valid PIN' : null,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as default address'),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v ?? false),
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _submit, child: const Text('Save Address')),
            ],
          ),
        ),
      ),
    );
  }
}
