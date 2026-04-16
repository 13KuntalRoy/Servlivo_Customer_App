import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category_entity.dart';
import '../cubit/catalog_cubit.dart';

// ─── helpers (reused from catalog_screen) ─────────────────────────────────────

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

// ─── What's included list per category ───────────────────────────────────────

List<String> _inclusions(String name) {
  final k = name.toLowerCase();
  if (k.contains('clean')) return [
    'Full room / area sweep & mop',
    'Dusting of surfaces & fixtures',
    'Bathroom and kitchen scrub',
    'Trash removal',
    'Equipment & supplies included',
  ];
  if (k.contains('plumb')) return [
    'Leak detection & repair',
    'Pipe fitting & replacement',
    'Drain unclogging',
    'Tap/fixture installation',
    'Post-work cleanup',
  ];
  if (k.contains('electr')) return [
    'Wiring & socket repair',
    'MCB / fuse replacement',
    'Fan & light installation',
    'Safety inspection',
    'Post-work testing',
  ];
  if (k.contains('beauty') || k.contains('spa') || k.contains('massage')) return [
    'Skin & hair assessment',
    'Premium products used',
    'Hygienic tools & kit',
    'Relaxation technique',
    'Post-service consultation',
  ];
  if (k.contains('pest')) return [
    'Pest identification & survey',
    'Safe chemical treatment',
    'All entry points covered',
    'Post-treatment inspection',
    '30-day service warranty',
  ];
  if (k.contains('ac') || k.contains('appliance')) return [
    'Appliance inspection',
    'Deep cleaning / servicing',
    'Parts check & lubrication',
    'Performance testing',
    'Service report provided',
  ];
  return [
    'Professional & trained expert',
    'On-time arrival guarantee',
    'Quality materials & tools',
    'Satisfaction guarantee',
    'Post-service cleanup',
  ];
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ServiceDetailScreen extends StatelessWidget {
  final String serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        if (state is CatalogLoading) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: AppColors.primary)));
        }
        if (state is CatalogError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.message)),
          );
        }
        if (state is ServiceDetailLoaded) {
          return _DetailBody(service: state.service);
        }
        return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: AppColors.primary)));
      },
    );
  }
}

// ─── Detail body ──────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  final ServiceEntity service;
  const _DetailBody({required this.service});

  @override
  Widget build(BuildContext context) {
    final colors     = _catColors(service.name);
    final topPad     = MediaQuery.of(context).padding.top;
    final bottomPad  = MediaQuery.of(context).padding.bottom;
    final inclusions = _inclusions(service.name);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(children: [
        // ── Scrollable content ─────────────────────────────────────────
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 100 + bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Hero ──────────────────────────────────────────────────
              _HeroSection(
                service: service,
                colors: colors,
                topPad: topPad,
              ),

              const SizedBox(height: 16),

              // ── Stats row ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  _StatCard(
                    icon: Icons.schedule_rounded,
                    label: 'Duration',
                    value: service.durationDisplay,
                    color: colors[0],
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    icon: Icons.people_alt_outlined,
                    label: 'Vendors',
                    value: '${service.vendorCount}+',
                    color: const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    icon: Icons.star_rounded,
                    label: 'Rating',
                    value: service.avgRating > 0
                        ? service.avgRating.toStringAsFixed(1)
                        : 'New',
                    color: const Color(0xFFF59E0B),
                  ),
                ]),
              ),

              const SizedBox(height: 16),

              // ── About card ────────────────────────────────────────────
              if (service.description.isNotEmpty) ...[
                _SectionPad(
                  child: _InfoCard(
                    title: 'About this service',
                    icon: Icons.info_outline_rounded,
                    iconColor: colors[0],
                    child: Text(service.description,
                      style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 13.5,
                        color: AppColors.textSecondary, height: 1.6)),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── What's included ───────────────────────────────────────
              _SectionPad(
                child: _InfoCard(
                  title: "What's included",
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: const Color(0xFF16A34A),
                  child: Column(
                    children: inclusions.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20, height: 20,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded,
                                size: 12, color: Color(0xFF16A34A)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(item,
                              style: const TextStyle(
                                fontFamily: 'Poppins', fontSize: 13,
                                color: AppColors.textPrimary, height: 1.4)),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Availability badge ────────────────────────────────────
              if (service.availableToday)
                _SectionPad(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF86EFAC), width: 1.2)),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.bolt_rounded,
                            color: Color(0xFF16A34A), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Available Today',
                              style: TextStyle(
                                fontFamily: 'Poppins', fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D))),
                            Text('Experts are free and can visit today.',
                              style: TextStyle(
                                fontFamily: 'Poppins', fontSize: 11,
                                color: Color(0xFF16A34A))),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),

              // ── How it works ──────────────────────────────────────────
              const SizedBox(height: 12),
              _SectionPad(
                child: _InfoCard(
                  title: 'How it works',
                  icon: Icons.playlist_add_check_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  child: Column(children: [
                    _StepRow(step: '1', label: 'Book & confirm your slot'),
                    _StepRow(step: '2', label: 'Expert arrives on time'),
                    _StepRow(step: '3', label: 'Service is completed'),
                    _StepRow(step: '4', label: 'Pay & rate your experience',
                        last: true),
                  ]),
                ),
              ),

              const SizedBox(height: 12),

              // ── Price card ────────────────────────────────────────────
              _SectionPad(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Starting from',
                            style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 11,
                              color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${service.basePrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins', fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5)),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  service.priceType == 'hourly'
                                      ? '/ hr' : '/ visit',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 12,
                                    color: AppColors.textSecondary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text('Inclusive of all charges',
                            style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 11,
                              color: AppColors.textHint)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.local_offer_rounded,
                            size: 13, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(service.priceType.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                      ]),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),

        // ── Sticky Book Now button ─────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16, offset: const Offset(0, -4))],
            ),
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
            child: Row(children: [
              // Price summary
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Total price',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 11,
                    color: AppColors.textSecondary)),
                Text('₹${service.basePrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
              ]),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(
                    AppRoutes.bookingCreate,
                    extra: {
                      'service_id': service.id,
                      'service_price': service.basePrice,
                    },
                  ),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Center(
                      child: Text('Book Now',
                        style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 15,
                          fontWeight: FontWeight.w800, color: Colors.white,
                          letterSpacing: 0.3)),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─── Hero section ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final ServiceEntity service;
  final List<Color> colors;
  final double topPad;

  const _HeroSection({
    required this.service, required this.colors, required this.topPad});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Image / placeholder
      SizedBox(
        height: topPad + 280,
        width: double.infinity,
        child: service.imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: service.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _imgPlaceholder(colors),
              )
            : _imgPlaceholder(colors),
      ),

      // Gradient overlay bottom
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.75),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),

      // Back button
      Positioned(
        top: topPad + 12, left: 16,
        child: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3))),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: Colors.white),
          ),
        ),
      ),

      // Available today badge (top right)
      if (service.availableToday)
        Positioned(
          top: topPad + 12, right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.bolt_rounded, size: 12, color: Colors.white),
              SizedBox(width: 4),
              Text('Available Today',
                style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 10,
                  fontWeight: FontWeight.w700, color: Colors.white)),
            ]),
          ),
        ),

      // Name + rating at bottom of hero
      Positioned(
        bottom: 20, left: 16, right: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.name,
              style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 22,
                fontWeight: FontWeight.w800, color: Colors.white,
                height: 1.2, shadows: [
                  Shadow(color: Colors.black38,
                      blurRadius: 6, offset: Offset(0, 2))
                ])),
            const SizedBox(height: 8),
            Row(children: [
              if (service.avgRating > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFACC15),
                    borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(service.avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 12,
                        fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3))),
                child: Text(service.durationDisplay,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 11,
                    fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ]),
          ],
        ),
      ),
    ]);
  }

  Widget _imgPlaceholder(List<Color> c) => Container(
    color: c[1],
    child: Center(
      child: Icon(_catIcon(service.name), size: 80, color: c[0]),
    ),
  );
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.icon, required this.label,
    required this.value, required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 6),
        Text(value,
          style: TextStyle(
            fontFamily: 'Poppins', fontSize: 14,
            fontWeight: FontWeight.w800, color: color)),
        Text(label,
          style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 10,
            color: AppColors.textSecondary)),
      ]),
    ),
  );
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  const _InfoCard({
    required this.title, required this.icon,
    required this.iconColor, required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(title,
          style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary)),
      ]),
      const SizedBox(height: 14),
      child,
    ]),
  );
}

// ─── Step row ─────────────────────────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  final String step;
  final String label;
  final bool last;
  const _StepRow({required this.step, required this.label, this.last = false});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle),
          child: Center(
            child: Text(step,
              style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 11,
                fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
        if (!last)
          Container(width: 2, height: 20,
            color: const Color(0xFFE0E0E0)),
      ]),
      const SizedBox(width: 12),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(label,
          style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 13,
            color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
      ),
    ],
  );
}

// ─── Padding helper ───────────────────────────────────────────────────────────

class _SectionPad extends StatelessWidget {
  final Widget child;
  const _SectionPad({required this.child});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: child,
  );
}
