import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/payment_bloc.dart';

class PaymentScreen extends StatelessWidget {
  final String bookingId;
  final double amount;

  const PaymentScreen({super.key, required this.bookingId, required this.amount});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful!'),
              backgroundColor: AppColors.secondary,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is PaymentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Payment')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        '₹${amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Pay via',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                const _PaymentOption(
                  icon: Icons.credit_card,
                  label: 'Credit / Debit Card',
                  subtitle: 'Visa, Mastercard, RuPay',
                ),
                const SizedBox(height: 8),
                const _PaymentOption(
                  icon: Icons.account_balance,
                  label: 'Net Banking',
                  subtitle: 'All major banks supported',
                ),
                const SizedBox(height: 8),
                const _PaymentOption(
                  icon: Icons.phone_android,
                  label: 'UPI',
                  subtitle: 'GPay, PhonePe, Paytm',
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is PaymentLoading || state is PaymentProcessing
                        ? null
                        : () => context
                            .read<PaymentBloc>()
                            .add(PaymentInitiated(bookingId)),
                    child: state is PaymentLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Pay ₹${amount.toStringAsFixed(0)}'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
