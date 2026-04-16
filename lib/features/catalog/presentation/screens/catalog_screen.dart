import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category_entity.dart';
import '../cubit/catalog_cubit.dart';

// ─── Colour + icon helpers ────────────────────────────────────────────────────

const _kCatColors = {
  'cleaning':    [Color(0xFFFF6B2C), Color(0xFFFFF0E8)],
  'plumbing':    [Color(0xFF2563EB), Color(0xFFEFF6FF)],
  'electrician': [Color(0xFFD97706), Color(0xFFFFFBEB)],
  'beauty':      [Color(0xFFDB2777), Color(0xFFFDF2F8)],
  'chef':        [Color(0xFF16A34A), Color(0xFFF0FDF4)],
  'cook':        [Color(0xFF16A34A), Color(0xFFF0FDF4)],
  'pest':        [Color(0xFF7C3AED), Color(0xFFF5F3FF)],
  'carpenter':   [Color(0xFF92400E), Color(0xFFFFFBEB)],
  'painter':     [Color(0xFF0891B2), Color(0xFFECFEFF)],
  'ac':          [Color(0xFF0284C7), Color(0xFFE0F2FE)],
  'appliance':   [Color(0xFF6D28D9), Color(0xFFEDE9FE)],
  'laundry':     [Color(0xFF0369A1), Color(0xFFE0F2FE)],
  'massage':     [Color(0xFFBE185D), Color(0xFFFDF2F8)],
  'bathroom':    [Color(0xFF0891B2), Color(0xFFECFEFF)],
  'kitchen':     [Color(0xFF16A34A), Color(0xFFF0FDF4)],
  'sofa':        [Color(0xFF7C3AED), Color(0xFFF5F3FF)],
};

List<Color> _catColors(String name) {
  final k = name.toLowerCase();
  for (final e in _kCatColors.entries) {
    if (k.contains(e.key)) return e.value;
  }
  return [AppColors.primary, const Color(0xFFFFF0E8)];
}

IconData _catIcon(String name) {
  final k = name.toLowerCase();
  if (k.contains('bathroom') || k.contains('bath')) return Icons.bathtub_outlined;
  if (k.contains('kitchen'))  return Icons.kitchen_rounded;
  if (k.contains('sofa') || k.contains('couch')) return Icons.weekend_rounded;
  if (k.contains('clean'))    return Icons.cleaning_services_rounded;
  if (k.contains('plumb'))    return Icons.water_drop_rounded;
  if (k.contains('electr'))   return Icons.bolt_rounded;
  if (k.contains('beauty') || k.contains('spa') || k.contains('massage')) {
    return Icons.face_retouching_natural_rounded;
  }
  if (k.contains('chef') || k.contains('cook')) return Icons.soup_kitchen_rounded;
  if (k.contains('pest'))     return Icons.pest_control_rounded;
  if (k.contains('carpenter') || k.contains('handyman')) return Icons.handyman_rounded;
  if (k.contains('paint'))    return Icons.format_paint_rounded;
  if (k.contains('ac') || k.contains('appliance')) return Icons.ac_unit_rounded;
  if (k.contains('laundry'))  return Icons.local_laundry_service_rounded;
  return Icons.home_repair_service_rounded;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class CatalogScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const CatalogScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchCtrl = TextEditingController();

  // Browse mode (no categoryId): all categories + selected category
  List<CategoryEntity> _categories = [];
  int _selectedCategory = 0;

  // Both modes: subcategories of selected category
  List<SubcategoryEntity> _subcategories = [];
  int _selectedSub = 0;

  bool _filterToday  = false;
  bool _filterU499   = false;
  bool _filterRating = false;

  // True when accessed from the Services tab (no pre-selected category)
  bool get _isBrowseMode => widget.categoryId == null;

  String get _headerTitle =>
      widget.categoryName != null && widget.categoryName!.isNotEmpty
          ? widget.categoryName!
          : 'Services';

  String get _activeSub =>
      _subcategories.isNotEmpty ? _subcategories[_selectedSub].name : '';

  @override
  void initState() {
    super.initState();
    if (!_isBrowseMode) {
      // Came from a category card — jump straight to subcategories
      context.read<CatalogCubit>().loadSubcategories(widget.categoryId!);
    }
    // Browse mode: categories already loading via router (loadCategories)
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    bool td = _filterToday, u4 = _filterU499, rt = _filterRating;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Row(children: [
              const Text('Filter',
                style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 18,
                  fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: () => set(() { td = false; u4 = false; rt = false; }),
                child: const Text('Clear all',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 13,
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 16),
            _FilterTile(icon: Icons.bolt_rounded,
              label: 'Available Today', sub: 'Services bookable right now',
              value: td, onChanged: (v) => set(() => td = v)),
            _FilterTile(icon: Icons.currency_rupee_rounded,
              label: 'Under ₹499', sub: 'Budget-friendly options',
              value: u4, onChanged: (v) => set(() => u4 = v)),
            _FilterTile(icon: Icons.star_rounded,
              label: '4.5+ Rating', sub: 'Only top-rated services',
              value: rt, onChanged: (v) => set(() => rt = v)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _filterToday = td; _filterU499 = u4; _filterRating = rt;
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Apply Filters',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: BlocConsumer<CatalogCubit, CatalogState>(
        listener: (ctx, state) {
          // Browse mode: categories loaded → auto-select first, load its subcategories
          if (state is CategoriesLoaded && state.categories.isNotEmpty && _isBrowseMode) {
            setState(() {
              _categories = state.categories;
              _selectedCategory = 0;
            });
            ctx.read<CatalogCubit>().loadSubcategories(state.categories.first.id);
          }
          // Both modes: subcategories loaded → auto-select first, load services
          if (state is SubcategoriesLoaded && state.subcategories.isNotEmpty) {
            setState(() {
              _subcategories = state.subcategories;
              _selectedSub = 0;
            });
            ctx.read<CatalogCubit>().loadServices(state.subcategories.first.id);
          }
        },
        builder: (ctx, state) {
          final initialLoading = state is CatalogLoading &&
              _subcategories.isEmpty &&
              (_isBrowseMode ? _categories.isEmpty : true);

          if (initialLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is CatalogError && _subcategories.isEmpty) {
            return _ErrorBody(
              message: state.message,
              onRetry: () {
                if (_isBrowseMode) {
                  ctx.read<CatalogCubit>().loadCategories();
                } else {
                  ctx.read<CatalogCubit>().loadSubcategories(widget.categoryId!);
                }
              },
            );
          }

          return CustomScrollView(
            slivers: [
              _buildHeader(context),
              SliverToBoxAdapter(child: _buildBodyContent(ctx)),
            ],
          );
        },
      ),
    );
  }

  // ─── Gradient header ─────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B2C), Color(0xFFFF9A5C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.fromLTRB(16, top + 12, 16, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Back button (only when coming from category) or spacer
          Row(children: [
            if (!_isBrowseMode)
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: Colors.white),
                ),
              )
            else
              const SizedBox(width: 36),
            const Spacer(),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.more_horiz_rounded,
                  size: 20, color: Colors.white),
            ),
          ]),
          const SizedBox(height: 16),

          // Title
          Text(
            _isBrowseMode ? 'All Services' : '$_headerTitle Services',
            style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 24,
              fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
          const SizedBox(height: 6),
          Text(
            _isBrowseMode
                ? 'Browse all categories, filter by type,\nand find the right service for you.'
                : 'Browse subcategories, compare service\nattributes, and check availability before booking.',
            style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 12,
              color: Colors.white70, height: 1.5)),
        ]),
      ),
    );
  }

  // ─── Scrollable body ──────────────────────────────────────────────────────────

  Widget _buildBodyContent(BuildContext ctx) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F6F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        _buildSearchBar(ctx),

        // Category chips — only in browse mode
        if (_isBrowseMode && _categories.isNotEmpty) ...[
          _sectionLabel('CATEGORY'),
          _buildCategoryRow(ctx),
        ],

        // Subcategory chips
        if (_subcategories.isNotEmpty && _searchCtrl.text.isEmpty) ...[
          _sectionLabel('SUBCATEGORY'),
          _buildSubcategoryRow(),
        ],

        // Quick filters
        _sectionLabel('FILTERS'),
        _buildFilterChips(),

        // Services section label
        if (_activeSub.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text('SERVICES IN ${_activeSub.toUpperCase()}',
              style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 11,
                fontWeight: FontWeight.w700, color: Color(0xFF9E9E9E),
                letterSpacing: 0.8)),
          ),

        _buildServiceList(),
        _NeedVendorBar(
          onCheckSlots: () => setState(() => _filterToday = true),
        ),
        SizedBox(height: MediaQuery.of(ctx).padding.bottom + 80),
      ]),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
    child: Text(text,
      style: const TextStyle(
        fontFamily: 'Poppins', fontSize: 11,
        fontWeight: FontWeight.w700, color: Color(0xFF9E9E9E),
        letterSpacing: 0.8)),
  );

  // ─── Search ───────────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search services...',
          hintStyle: TextStyle(
            fontFamily: 'Poppins', fontSize: 13.5, color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.primary, size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.cancel_rounded,
                      size: 18, color: AppColors.textHint),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {});
                    if (_subcategories.isNotEmpty) {
                      ctx.read<CatalogCubit>()
                          .loadServices(_subcategories[_selectedSub].id);
                    }
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEAEAEA))),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.primary, width: 1.5)),
        ),
        onChanged: (val) {
          setState(() {});
          if (val.trim().isEmpty && _subcategories.isNotEmpty) {
            ctx.read<CatalogCubit>()
                .loadServices(_subcategories[_selectedSub].id);
          } else if (val.trim().length >= 2) {
            ctx.read<CatalogCubit>().searchServices(query: val);
          }
        },
      ),
    );
  }

  // ─── Category chips (browse mode) ────────────────────────────────────────────

  Widget _buildCategoryRow(BuildContext ctx) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat    = _categories[i];
          final active = i == _selectedCategory;
          final colors = _catColors(cat.name);

          return GestureDetector(
            onTap: () {
              if (_selectedCategory == i) return;
              setState(() {
                _selectedCategory = i;
                _subcategories = [];
                _selectedSub = 0;
              });
              ctx.read<CatalogCubit>().loadSubcategories(cat.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? colors[0] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? colors[0] : const Color(0xFFDDDDDD)),
                boxShadow: active
                    ? [BoxShadow(
                        color: colors[0].withValues(alpha: 0.3),
                        blurRadius: 6, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_catIcon(cat.name),
                  size: 14,
                  color: active ? Colors.white : colors[0]),
                const SizedBox(width: 6),
                Text(cat.name,
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppColors.textSecondary)),
              ]),
            ),
          );
        },
      ),
    );
  }

  // ─── Subcategory cards ────────────────────────────────────────────────────────

  Widget _buildSubcategoryRow() {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _subcategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final sub    = _subcategories[i];
          final active = i == _selectedSub;
          final colors = _catColors(sub.name);

          return GestureDetector(
            onTap: () {
              setState(() => _selectedSub = i);
              context.read<CatalogCubit>().loadServices(sub.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 80,
              decoration: BoxDecoration(
                color: active ? colors[0] : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? colors[0] : const Color(0xFFEAEAEA),
                  width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: active
                        ? colors[0].withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: active ? 10 : 4,
                    offset: const Offset(0, 3))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withValues(alpha: 0.2)
                          : colors[1],
                      shape: BoxShape.circle),
                    child: Icon(_catIcon(sub.name), size: 18,
                        color: active ? Colors.white : colors[0]),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(sub.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : AppColors.textPrimary,
                        height: 1.2)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Filter chips ─────────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(children: [
        _InlineChip(label: 'Available Today', selected: _filterToday,
            onTap: () => setState(() => _filterToday = !_filterToday)),
        const SizedBox(width: 8),
        _InlineChip(label: 'Under ₹499', selected: _filterU499,
            onTap: () => setState(() => _filterU499 = !_filterU499)),
        const SizedBox(width: 8),
        _InlineChip(label: '4.5+ Rating', selected: _filterRating,
            onTap: () => setState(() => _filterRating = !_filterRating)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _showFilterSheet,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDDDDDD))),
            child: const Icon(Icons.tune_rounded,
                size: 16, color: AppColors.textSecondary),
          ),
        ),
      ]),
    );
  }

  // ─── Service list ──────────────────────────────────────────────────────────────

  Widget _buildServiceList() {
    return BlocBuilder<CatalogCubit, CatalogState>(
      buildWhen: (_, s) => s is ServicesLoaded || s is CatalogLoading,
      builder: (_, state) {
        if (state is CatalogLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary)));
        }

        if (state is ServicesLoaded) {
          final services = state.services.where((s) {
            if (_filterToday  && !s.availableToday)  return false;
            if (_filterU499   && s.basePrice >= 499)  return false;
            if (_filterRating && s.avgRating < 4.5)   return false;
            return true;
          }).toList();

          if (services.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 56),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 72, height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5), shape: BoxShape.circle),
                    child: const Icon(Icons.search_off_rounded,
                        size: 32, color: AppColors.textHint)),
                  const SizedBox(height: 14),
                  const Text('No services found',
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Try a different subcategory or filter',
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 12,
                      color: AppColors.textSecondary)),
                ]),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: services
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ServiceCard(service: s),
                      ))
                  .toList(),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Filter chip ──────────────────────────────────────────────────────────────

class _InlineChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _InlineChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                selected ? AppColors.primary : const Color(0xFFDDDDDD)),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Text(label,
          style: TextStyle(
            fontFamily: 'Poppins', fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

// ─── Filter sheet tile ────────────────────────────────────────────────────────

class _FilterTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterTile({
    required this.icon, required this.label, required this.sub,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: value
                ? AppColors.primary.withValues(alpha: 0.1)
                : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18,
              color: value ? AppColors.primary : AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
              style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 14,
                fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(sub,
              style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 11.5,
                color: AppColors.textSecondary)),
          ]),
        ),
        Switch.adaptive(
          value: value, onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.primary,
        ),
      ]),
    );
  }
}

// ─── Service card ─────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final ServiceEntity service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final colors = _catColors(service.name);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.serviceDetailPath(service.id)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: service.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: service.imageUrl,
                    width: 88, height: 88,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _imgPlaceholder(colors),
                    errorWidget: (_, __, ___) => _imgPlaceholder(colors))
                : _imgPlaceholder(colors),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary, height: 1.3)),

                if (service.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 11.5,
                      color: AppColors.textSecondary, height: 1.4)),
                ],

                const SizedBox(height: 8),

                Row(children: [
                  const Icon(Icons.schedule_rounded,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(service.durationDisplay,
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  const Icon(Icons.people_alt_outlined,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text('${service.vendorCount} vendors',
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
                ]),

                const SizedBox(height: 5),

                if (service.availableToday)
                  const Text('Available today',
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600))
                else if (service.avgRating > 0)
                  Row(children: [
                    const Icon(Icons.star_rounded,
                        size: 12, color: Color(0xFFFFA000)),
                    const SizedBox(width: 3),
                    Text('${service.avgRating.toStringAsFixed(1)} avg rating',
                      style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
                  ]),

                const SizedBox(height: 10),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('₹${service.basePrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context
                          .push(AppRoutes.serviceDetailPath(service.id)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                          ],
                        ),
                        child: const Text('View Detail',
                          style: TextStyle(
                            fontFamily: 'Poppins', color: Colors.white,
                            fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _imgPlaceholder(List<Color> colors) {
    return Container(
      width: 88, height: 88,
      decoration: BoxDecoration(
        color: colors[1], borderRadius: BorderRadius.circular(12)),
      child: Icon(_catIcon(service.name), color: colors[0], size: 32),
    );
  }
}

// ─── Bottom vendor bar ────────────────────────────────────────────────────────

class _NeedVendorBar extends StatelessWidget {
  final VoidCallback onCheckSlots;
  const _NeedVendorBar({required this.onCheckSlots});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (_, state) {
        final count = state is ServicesLoaded
            ? state.services.where((s) => s.availableToday).length
            : 0;

        if (count == 0) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFCC80)),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Need a vendor today?',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                    fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  '$count verified expert${count == 1 ? '' : 's'} available right now.',
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 11,
                    color: AppColors.textSecondary, height: 1.4)),
              ]),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onCheckSlots,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20)),
                child: const Text('Check Slots',
                  style: TextStyle(
                    fontFamily: 'Poppins', color: Colors.white,
                    fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ),
          ]),
        );
      },
    );
  }
}

// ─── Error body ───────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5), shape: BoxShape.circle),
            child: const Icon(Icons.wifi_off_rounded,
                size: 32, color: AppColors.textHint)),
          const SizedBox(height: 16),
          Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 14,
              color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12)),
              child: const Text('Retry',
                style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 14,
                  fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}
