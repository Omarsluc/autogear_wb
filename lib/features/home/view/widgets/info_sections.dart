import '../../../../../core/localization/app_strings.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > 900;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 64),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _AboutContent()),
                const SizedBox(width: 48),
                Expanded(child: _ProcessSteps()),
              ],
            )
          : Column(
              children: [
                _AboutContent(),
                const SizedBox(height: 48),
                _ProcessSteps(),
              ],
            ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.tr(context, 'about_title'), style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text(
          'Your Trusted Global Auto Parts Partner',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        const Text(
          'Founded with a commitment to customer satisfaction, Auto Gear has grown into a leading '
          'aftermarket auto parts supplier. We offer a diverse selection of over 40,000 SKUs covering '
          'various car makes and systems, ensuring we meet the needs of every customer.',
        ),
        const SizedBox(height: 24),
        const _FeatureItem(
          icon: Icons.public,
          title: 'Global Reach',
          description: 'Exporting to more than 120 countries worldwide.',
        ),
        const _FeatureItem(
          icon: Icons.inventory_2,
          title: 'Extensive Product Range',
          description: 'Over 40,000 SKUs covering all major vehicle systems.',
        ),
        const _FeatureItem(
          icon: Icons.verified,
          title: 'Quality Assurance',
          description: 'Rigorous quality control on every part we supply.',
        ),
        const _FeatureItem(
          icon: Icons.local_shipping,
          title: 'Fast Delivery',
          description: 'Efficient logistics with 3–6 day shipping worldwide.',
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessSteps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = [
      ('Step 1: Inquiry & Quote', 'Tell us your needs and receive a customized quote.'),
      ('Step 2: Product & Branding', 'We collaborate on product development and branding.'),
      ('Step 3: Order & Production', 'Confirm your order with efficient quality-controlled production.'),
      ('Step 4: Delivery & Support', 'Ship within 3–6 days with continued support.'),
    ];

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Collaborate with Ease',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our commitment to quality and service ensures your auto parts business thrives.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 32),
          for (var i = 0; i < steps.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i].$1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[i].$2,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i < steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 17, top: 8, bottom: 8),
                child: Container(
                  width: 2,
                  height: 20,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class PackagingSection extends StatelessWidget {
  const PackagingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > 900;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 64),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: isWide
            ? Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/packaging.jpg',
                          height: 380,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          cacheHeight: 760,
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.15),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_user, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Custom Packaging & Export',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'OEM BRANDING & PACKAGING',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Premium Protective Packaging',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Every order is packaged to international export standards with customized '
                            'branding options, heavy-duty anti-corrosion protection, and reinforced boxes '
                            'ensuring zero-damage delivery across 120+ countries.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.6,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Row(
                            children: [
                              _PackagingFeatureBadge(icon: Icons.shield_outlined, label: 'Damage-Proof'),
                              SizedBox(width: 16),
                              _PackagingFeatureBadge(icon: Icons.branding_watermark_outlined, label: 'Custom Branding'),
                              SizedBox(width: 16),
                              _PackagingFeatureBadge(icon: Icons.local_shipping_outlined, label: 'Global Dispatch'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        'assets/images/packaging.jpg',
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        cacheHeight: 480,
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'Custom Packaging & Export',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'OEM BRANDING & PACKAGING',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Premium Protective Packaging',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Every order is packaged to international export standards with customized '
                          'branding options, heavy-duty protection, and reinforced boxes.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _PackagingFeatureBadge(icon: Icons.shield_outlined, label: 'Damage-Proof'),
                            _PackagingFeatureBadge(icon: Icons.branding_watermark_outlined, label: 'Custom Branding'),
                            _PackagingFeatureBadge(icon: Icons.local_shipping_outlined, label: 'Global Dispatch'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PackagingFeatureBadge extends StatelessWidget {
  const _PackagingFeatureBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > 900;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Us', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Leave us a message about your requirements. We respond within 12 hours.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _ContactForm(formKey: _formKey)),
                    const SizedBox(width: 48),
                    Expanded(child: _ContactInfo()),
                  ],
                )
              : Column(
                  children: [
                    _ContactForm(formKey: _formKey),
                    const SizedBox(height: 32),
                    _ContactInfo(),
                  ],
                ),
        ],
      ),
    );
  }
}

class _ContactForm extends StatelessWidget {
  const _ContactForm({required this.formKey});

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email *'),
                validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Message (Other details) *'),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you! We will respond within 12 hours.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                },
                child: const Text('SUBMIT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBlock(
          icon: Icons.location_on,
          title: 'Company Address',
          content: '4123 upper Merage Zahraa al Maadi Cairo EG',
        ),
        const SizedBox(height: 24),
        _InfoBlock(
          icon: Icons.phone,
          title: 'Phone',
          content: '+20 1122291859',
        ),
        const SizedBox(height: 24),
        _InfoBlock(
          icon: Icons.email,
          title: 'Email',
          content: 'autoGear-autoparts@autogear.com',
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Still not finding what you need?',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Contact our consultants for hard-to-find auto parts. '
                'Let there be no hard-to-find parts in the world.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(content, style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 600;

    return Container(
      color: AppColors.primaryDark,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 40),
      child: Column(
        children: [
          isWide
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BrandBlock(),
                    Row(
                      children: [
                        _FooterLink('Catalog'),
                        _FooterLink('About'),
                        _FooterLink('Contact'),
                        _FooterLink('FAQ'),
                      ],
                    ),
                  ],
                )
              : _BrandBlock(),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'Copyright © 2026, Auto Gear. All rights reserved.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AUTO GEAR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Reliable Aftermarket Auto Parts Supplier',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Text(
        label,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
      ),
    );
  }
}
