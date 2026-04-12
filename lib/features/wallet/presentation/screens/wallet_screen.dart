import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/wallet_cubit.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showAddMoneySheet(BuildContext context) {
    final amountCtrl = TextEditingController();
    final amounts = [100, 250, 500, 1000];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Money',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: amounts.map((a) {
                  return ChoiceChip(
                    label: Text('₹$a'),
                    selected: amountCtrl.text == a.toString(),
                    onSelected: (_) {
                      setModal(() => amountCtrl.text = a.toString());
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: amountCtrl.text == a.toString()
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter custom amount',
                  prefixText: '₹ ',
                ),
                onChanged: (_) => setModal(() {}),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final amt = double.tryParse(amountCtrl.text);
                    if (amt == null || amt <= 0) return;
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('₹${amt.toStringAsFixed(0)} added to wallet'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  },
                  child: const Text('Proceed to Pay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToTransactions() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WalletError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<WalletCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is WalletLoaded) {
            return Column(
              children: [
                // Balance card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFFFF9A5C)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Servlivo Credits',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${state.balance.balance.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _WalletAction(
                            icon: Icons.add_circle_outline,
                            label: 'Add Money',
                            onTap: () => _showAddMoneySheet(context),
                          ),
                          const SizedBox(width: 16),
                          _WalletAction(
                            icon: Icons.history,
                            label: 'History',
                            onTap: _scrollToTransactions,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Transactions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Transactions',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text('${state.transactions.length} total',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: state.transactions.isEmpty
                      ? const Center(child: Text('No transactions yet'))
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.transactions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final tx = state.transactions[i];
                            final isCredit = tx.type == 'credit';
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: isCredit
                                    ? AppColors.secondary.withValues(alpha:0.15)
                                    : Colors.red.withValues(alpha:0.1),
                                child: Icon(
                                  isCredit
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: isCredit ? AppColors.secondary : Colors.red,
                                  size: 18,
                                ),
                              ),
                              title: Text(tx.description,
                                  style: const TextStyle(fontSize: 14)),
                              subtitle: Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(tx.createdAt),
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textSecondary),
                              ),
                              trailing: Text(
                                '${isCredit ? '+' : '-'}₹${tx.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isCredit ? AppColors.secondary : Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _WalletAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
