import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/catalog_cubit.dart';

class CatalogScreen extends StatefulWidget {
  final String? categoryId;

  const CatalogScreen({super.key, this.categoryId});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final _searchCtrl = TextEditingController();
  List<dynamic> _subcategories = [];

  // Active filter flags — used to filter the service list client-side
  bool _filterAvailableToday = false;
  bool _filterUnder499 = false;
  bool _filterRating45 = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      context.read<CatalogCubit>().loadSubcategories(widget.categoryId!);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    // Capture current values so the sheet starts with the live state
    bool tmpToday = _filterAvailableToday;
    bool tmpPrice = _filterUnder499;
    bool tmpRating = _filterRating45;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Filter Services',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setModal(() {
                        tmpToday = false;
                        tmpPrice = false;
                        tmpRating = false;
                      });
                    },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ModalFilterTile(
                label: 'Available Today',
                icon: Icons.today_outlined,
                value: tmpToday,
                onChanged: (v) => setModal(() => tmpToday = v),
              ),
              const Divider(height: 1),
              _ModalFilterTile(
                label: 'Under ₹499',
                icon: Icons.currency_rupee,
                value: tmpPrice,
                onChanged: (v) => setModal(() => tmpPrice = v),
              ),
              const Divider(height: 1),
              _ModalFilterTile(
                label: '4.5+ Rating',
                icon: Icons.star_outline,
                value: tmpRating,
                onChanged: (v) => setModal(() => tmpRating = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filterAvailableToday = tmpToday;
                      _filterUnder499 = tmpPrice;
                      _filterRating45 = tmpRating;
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: Badge(
              isLabelVisible:
                  _filterAvailableToday || _filterUnder499 || _filterRating45,
              smallSize: 8,
              child: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
      body: BlocConsumer<CatalogCubit, CatalogState>(
        listener: (context, state) {
          if (state is SubcategoriesLoaded && state.subcategories.isNotEmpty) {
            setState(() {
              _subcategories = state.subcategories;
              _tabController?.dispose();
              _tabController = TabController(
                length: state.subcategories.length,
                vsync: this,
              )..addListener(() {
                  if (!_tabController!.indexIsChanging) {
                    context.read<CatalogCubit>().loadServices(
                          _subcategories[_tabController!.index].id,
                        );
                  }
                });
            });
            context.read<CatalogCubit>().loadServices(
                  state.subcategories.first.id,
                );
          }
        },
        builder: (context, state) {
          if (state is CatalogError && _subcategories.isEmpty) {
            return Center(child: Text(state.message));
          }
          if (state is CatalogLoading && _subcategories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search for services...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                              if (_tabController != null &&
                                  _subcategories.isNotEmpty) {
                                context.read<CatalogCubit>().loadServices(
                                    _subcategories[_tabController!.index].id);
                              }
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (val) {
                    setState(() {});
                    if (val.trim().isEmpty) {
                      if (_tabController != null && _subcategories.isNotEmpty) {
                        context.read<CatalogCubit>().loadServices(
                            _subcategories[_tabController!.index].id);
                      }
                    } else if (val.trim().length >= 2) {
                      context.read<CatalogCubit>().searchServices(query: val);
                    }
                  },
                ),
              ),
              if (_tabController != null && _subcategories.isNotEmpty && _searchCtrl.text.isEmpty)
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: _subcategories.map((s) => Tab(text: s.name)).toList(),
                ),
              // Active filter chips row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Available Today',
                      selected: _filterAvailableToday,
                      onSelected: (v) =>
                          setState(() => _filterAvailableToday = v),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Under ₹499',
                      selected: _filterUnder499,
                      onSelected: (v) => setState(() => _filterUnder499 = v),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '4.5+ Rating',
                      selected: _filterRating45,
                      onSelected: (v) => setState(() => _filterRating45 = v),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _ServiceListView(
                  filterAvailableToday: _filterAvailableToday,
                  filterUnder499: _filterUnder499,
                  filterRating45: _filterRating45,
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: _NeedVendorBar(),
    );
  }
}

class _ModalFilterTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ModalFilterTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: AppColors.textSecondary),
      title: Text(label),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}

class _ServiceListView extends StatelessWidget {
  final bool filterAvailableToday;
  final bool filterUnder499;
  final bool filterRating45;

  const _ServiceListView({
    required this.filterAvailableToday,
    required this.filterUnder499,
    required this.filterRating45,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      buildWhen: (_, state) => state is ServicesLoaded || state is CatalogLoading,
      builder: (context, state) {
        if (state is CatalogLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ServicesLoaded) {
          final services = state.services.where((s) {
            if (filterAvailableToday && !s.availableToday) return false;
            if (filterUnder499 && s.basePrice >= 499) return false;
            if (filterRating45 && s.avgRating < 4.5) return false;
            return true;
          }).toList();

          if (services.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 48, color: AppColors.textHint),
                  SizedBox(height: 12),
                  Text('No services match your filters',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ServiceCard(service: services[i]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final dynamic service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: service.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: service.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.background,
                      child: const Icon(Icons.home_repair_service,
                          color: AppColors.textHint),
                    ),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: AppColors.background,
                    child: const Icon(Icons.home_repair_service,
                        color: AppColors.textHint),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(service.description,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(service.durationDisplay,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(width: 12),
                    const Icon(Icons.people_outline,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text('${service.vendorCount} vendors',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                if (service.availableToday)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Available today',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500)),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('₹${service.basePrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const Spacer(),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => context
                            .push(AppRoutes.serviceDetailPath(service.id)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        child: const Text('View Detail'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      checkmarkColor: Colors.white,
      side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border),
    );
  }
}

class _NeedVendorBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF3E0),
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Need a vendor today?',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text('Verified experts available near you right now.',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.catalog),
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: const Text('Check Slots'),
          ),
        ],
      ),
    );
  }
}
