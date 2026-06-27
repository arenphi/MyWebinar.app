import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_webinar/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primary,
      systemNavigationBarColor: AppColors.primaryDark,
    ),
  );
  runApp(const MyWebinarApp());
}

class MyWebinarApp extends StatefulWidget {
  const MyWebinarApp({super.key});

  @override
  State<MyWebinarApp> createState() => _MyWebinarAppState();
}

class _MyWebinarAppState extends State<MyWebinarApp> {
  AppLocaleState localeState = AppLocaleState.indonesia();

  void updateLocale(AppLocaleState state) {
    setState(() => localeState = state);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyWebinar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(onLocaleDetected: updateLocale),
      routes: {
        '/home': (_) => MainShell(localeState: localeState),
      },
    );
  }
}

class AppLocaleState {
  final String countryCode;
  final String languageCode;
  final String countryName;
  final String flagEmoji;
  final bool isEnglish;

  const AppLocaleState({
    required this.countryCode,
    required this.languageCode,
    required this.countryName,
    required this.flagEmoji,
    required this.isEnglish,
  });

  factory AppLocaleState.indonesia() {
    return const AppLocaleState(
      countryCode: 'ID',
      languageCode: 'id',
      countryName: 'Indonesia',
      flagEmoji: '🇮🇩',
      isEnglish: false,
    );
  }

  factory AppLocaleState.usa() {
    return const AppLocaleState(
      countryCode: 'US',
      languageCode: 'en',
      countryName: 'United States',
      flagEmoji: '🇺🇸',
      isEnglish: true,
    );
  }

  factory AppLocaleState.fromPosition(Position? position) {
    if (position == null) return AppLocaleState.indonesia();

    // Approximate bounding box for United States.
    final lat = position.latitude;
    final lon = position.longitude;
    final isUnitedStates = lat >= 24 && lat <= 49.5 && lon >= -125 && lon <= -66;

    return isUnitedStates ? AppLocaleState.usa() : AppLocaleState.indonesia();
  }
}

class LocationService {
  static Future<AppLocaleState> detectLocale() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return AppLocaleState.indonesia();

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return AppLocaleState.indonesia();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 8),
      );
      return AppLocaleState.fromPosition(position);
    } catch (_) {
      return AppLocaleState.indonesia();
    }
  }
}

class SplashScreen extends StatefulWidget {
  final ValueChanged<AppLocaleState> onLocaleDetected;

  const SplashScreen({super.key, required this.onLocaleDetected});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppLocaleState localeState = AppLocaleState.indonesia();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final state = await LocationService.detectLocale();
    if (!mounted) return;
    setState(() => localeState = state);
    widget.onLocaleDetected(state);
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final title = localeState.isEnglish ? 'MyWebinar' : 'MyWebinar';
    final subtitle = localeState.isEnglish
        ? 'Find, join, and manage webinars easily'
        : 'Temukan, ikuti, dan kelola webinar dengan mudah';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -50,
              child: _GlowCircle(size: 210, color: Colors.white.withValues(alpha: 0.12)),
            ),
            Positioned(
              bottom: -90,
              left: -60,
              child: _GlowCircle(size: 260, color: Colors.white.withValues(alpha: 0.10)),
            ),
            Center(
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'app-logo',
                      child: Container(
                        height: 112,
                        width: 112,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadius.borderRadiusXl,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.20),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.video_camera_front_rounded,
                          color: AppColors.primary,
                          size: 58,
                        ),
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                    ).animate().fadeIn(delay: 250.ms, duration: 600.ms),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: AppRadius.borderRadiusFull,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(localeState.flagEmoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            '${localeState.countryName} • ${localeState.languageCode.toUpperCase()}',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),
                    const SizedBox(height: AppSpacing.xl),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final AppLocaleState localeState;

  const MainShell({super.key, required this.localeState});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(localeState: widget.localeState),
      AdminScreen(localeState: widget.localeState),
      CertificateScreen(localeState: widget.localeState),
      ChatbotScreen(localeState: widget.localeState),
      ProfileScreen(localeState: widget.localeState),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.35),
        onDestinationSelected: (value) => setState(() => currentIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Admin'),
          NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), selectedIcon: Icon(Icons.workspace_premium), label: 'Sertifikat'),
          NavigationDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const CreateWebinarSheet(),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Buat Webinar'),
            )
          : null,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final AppLocaleState localeState;

  const HomeScreen({super.key, required this.localeState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = demoWebinars
        .where((item) =>
            item.title.toLowerCase().contains(query.toLowerCase()) ||
            item.speaker.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.localeState.isEnglish ? 'Explore Webinars' : 'Jelajahi Webinar',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              background: _HeroHeader(localeState: widget.localeState),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchField(
                    hintText: widget.localeState.isEnglish ? 'Search webinar or speaker...' : 'Cari webinar atau narasumber...',
                    onChanged: (value) => setState(() => query = value),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionTitle(
                    title: widget.localeState.isEnglish ? 'Upcoming Webinars' : 'Webinar Terbaru',
                    action: '${filtered.length} event',
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            sliver: SliverList.separated(
              itemBuilder: (context, index) => WebinarCard(webinar: filtered[index])
                  .animate()
                  .fadeIn(delay: (80 * index).ms)
                  .slideX(begin: 0.05),
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemCount: filtered.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final AppLocaleState localeState;

  const _HeroHeader({required this.localeState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 70, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            const Hero(
              tag: 'app-logo',
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.video_camera_front_rounded, color: AppColors.primary, size: 30),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                localeState.isEnglish
                    ? 'Manage registration, discussion, certificates, and AI webinar assistant.'
                    : 'Kelola pendaftaran, diskusi, sertifikat, dan asisten AI webinar.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
              ),
            ),
            Text(localeState.flagEmoji, style: const TextStyle(fontSize: 28)),
          ],
        ),
      ),
    );
  }
}

class WebinarCard extends StatelessWidget {
  final Webinar webinar;

  const WebinarCard({super.key, required this.webinar});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.borderRadiusLg,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => WebinarDetailScreen(webinar: webinar)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                gradient: LinearGradient(
                  colors: [webinar.color, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -35,
                    top: -25,
                    child: _GlowCircle(size: 125, color: Colors.white.withValues(alpha: 0.16)),
                  ),
                  Center(
                    child: Icon(webinar.icon, size: 64, color: Colors.white),
                  ),
                  if (webinar.hasCertificate)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _Badge(text: 'E-Sertifikat', icon: Icons.verified_outlined),
                    ),
                ],
              ),
            ),
            Padding(
              padding: AppSpacing.paddingMd,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: webinar.color.withValues(alpha: 0.16),
                    child: Text(webinar.hostInitial, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(webinar.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(webinar.speaker, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${webinar.date} • ${webinar.time}', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebinarDetailScreen extends StatelessWidget {
  final Webinar webinar;

  const WebinarDetailScreen({super.key, required this.webinar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Webinar')),
      body: ListView(
        padding: AppSpacing.paddingMd,
        children: [
          WebinarCard(webinar: webinar),
          const SizedBox(height: AppSpacing.md),
          _InfoPanel(
            title: 'Deskripsi',
            children: [
              Text(webinar.description, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoPanel(
            title: 'Informasi Webinar',
            children: [
              _InfoRow(icon: Icons.person, label: 'Narasumber', value: webinar.speaker),
              _InfoRow(icon: Icons.event, label: 'Tanggal', value: webinar.date),
              _InfoRow(icon: Icons.access_time, label: 'Waktu', value: webinar.time),
              _InfoRow(icon: Icons.groups, label: 'Kuota', value: '${webinar.quota} peserta'),
              _InfoRow(icon: Icons.workspace_premium, label: 'Sertifikat', value: webinar.hasCertificate ? 'Ya' : 'Tidak'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.how_to_reg_rounded),
            label: const Text('Daftar Webinar'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.forum_outlined),
            label: const Text('Masuk Diskusi'),
          ),
        ],
      ),
    );
  }
}

class CreateWebinarSheet extends StatelessWidget {
  const CreateWebinarSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 46, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadius.borderRadiusFull)),
            const SizedBox(height: AppSpacing.md),
            Text('Buat Webinar', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: AppSpacing.md),
            const TextField(decoration: InputDecoration(labelText: 'Judul Webinar')),
            const SizedBox(height: AppSpacing.sm),
            const TextField(decoration: InputDecoration(labelText: 'Narasumber')),
            const SizedBox(height: AppSpacing.sm),
            const TextField(decoration: InputDecoration(labelText: 'Link Meeting')),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: const [
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Tanggal'))),
                SizedBox(width: 10),
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Waktu'))),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const TextField(maxLines: 3, decoration: InputDecoration(labelText: 'Deskripsi')),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.publish_rounded),
                label: const Text('Terbitkan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminScreen extends StatelessWidget {
  final AppLocaleState localeState;

  const AdminScreen({super.key, required this.localeState});

  @override
  Widget build(BuildContext context) {
    return _SimplePage(
      title: 'Admin Dashboard',
      icon: Icons.dashboard_customize_rounded,
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(child: _StatCard(label: 'Webinar', value: '12', icon: Icons.video_call)),
              SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Peserta', value: '842', icon: Icons.groups)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: _StatCard(label: 'Sertifikat', value: '530', icon: Icons.workspace_premium)),
              SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Diskusi', value: '76', icon: Icons.forum)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoPanel(
            title: 'Migrasi dari Website',
            children: const [
              Text('Fitur yang dimigrasikan: CRUD webinar, pencarian, pagination/list, pendaftaran peserta, profil, diskusi, unduh sertifikat, dan dashboard admin.'),
            ],
          ),
        ],
      ),
    );
  }
}

class CertificateScreen extends StatelessWidget {
  final AppLocaleState localeState;

  const CertificateScreen({super.key, required this.localeState});

  @override
  Widget build(BuildContext context) {
    return _SimplePage(
      title: 'Sertifikat',
      icon: Icons.workspace_premium_rounded,
      child: Column(
        children: demoWebinars
            .where((webinar) => webinar.hasCertificate)
            .map((webinar) => _CertificateTile(webinar: webinar))
            .toList(),
      ),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  final AppLocaleState localeState;

  const ChatbotScreen({super.key, required this.localeState});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final messages = <String>[
    'Halo! Saya asisten AI MyWebinar. Tanyakan jadwal, topik, atau teknis webinar.',
  ];
  final controller = TextEditingController();

  void send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add(text);
      messages.add('Rekomendasi: Coba webinar "Flutter UI/UX Masterclass" untuk topik mobile development.');
    });
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chatbot'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text(widget.localeState.flagEmoji, style: const TextStyle(fontSize: 24))),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: AppSpacing.paddingMd,
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final isUser = index.isOdd;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: AppSpacing.paddingMd,
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : Colors.white,
                      borderRadius: AppRadius.borderRadiusLg,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12),
                      ],
                    ),
                    child: Text(
                      messages[index],
                      style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                );
              },
            ),
          ),
          Padding(
            padding: AppSpacing.paddingMd,
            child: Row(
              children: [
                Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Tulis pesan...'))),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: send,
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final AppLocaleState localeState;

  const ProfileScreen({super.key, required this.localeState});

  @override
  Widget build(BuildContext context) {
    return _SimplePage(
      title: 'Profil',
      icon: Icons.person_rounded,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person, size: 54, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Reynaldi Nugraha Putra', style: Theme.of(context).textTheme.headlineMedium),
          Text('Peserta MyWebinar • ${localeState.flagEmoji} ${localeState.countryName}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          _InfoPanel(
            title: 'Akun',
            children: const [
              _InfoRow(icon: Icons.email, label: 'Email', value: 'user@mywebinar.app'),
              _InfoRow(icon: Icons.language, label: 'Bahasa', value: 'Auto by location'),
              _InfoRow(icon: Icons.verified_user, label: 'Role', value: 'Peserta / Admin'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimplePage extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SimplePage({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: AppSpacing.paddingMd,
        children: [
          Container(
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: AppRadius.borderRadiusXl,
            ),
            child: Icon(icon, size: 68, color: Colors.white),
          ).animate().fadeIn().scale(),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: const Icon(Icons.tune_rounded),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String action;

  const _SectionTitle({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.displaySmall),
        _Badge(text: action, icon: Icons.event_available),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Badge({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: AppRadius.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoPanel({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.vPaddingSm,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14)],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 34),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.displaySmall),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _CertificateTile extends StatelessWidget {
  final Webinar webinar;

  const _CertificateTile({required this.webinar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.workspace_premium, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(webinar.title, style: Theme.of(context).textTheme.titleLarge)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.download_rounded, color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }
}

class Webinar {
  final String title;
  final String speaker;
  final String date;
  final String time;
  final int quota;
  final bool hasCertificate;
  final String description;
  final IconData icon;
  final Color color;
  final String hostInitial;

  const Webinar({
    required this.title,
    required this.speaker,
    required this.date,
    required this.time,
    required this.quota,
    required this.hasCertificate,
    required this.description,
    required this.icon,
    required this.color,
    required this.hostInitial,
  });
}

const demoWebinars = [
  Webinar(
    title: 'Flutter UI/UX Masterclass',
    speaker: 'Donny Maulana',
    date: '28 Jun 2026',
    time: '19:00',
    quota: 250,
    hasCertificate: true,
    description: 'Pelajari cara membangun UI mobile modern, clean architecture, dan animasi interaksi halus menggunakan Flutter.',
    icon: Icons.phone_android_rounded,
    color: Color(0xFF7E57C2),
    hostInitial: 'D',
  ),
  Webinar(
    title: 'AI Chatbot untuk Aplikasi Mobile',
    speaker: 'Reynaldi Nugraha',
    date: '05 Jul 2026',
    time: '20:00',
    quota: 180,
    hasCertificate: true,
    description: 'Membangun asisten cerdas untuk membantu pengguna mencari webinar dan menjawab pertanyaan teknis.',
    icon: Icons.smart_toy_rounded,
    color: Color(0xFF5E35B1),
    hostInitial: 'R',
  ),
  Webinar(
    title: 'Strategi Personal Branding Digital',
    speaker: 'Narasumber Profesional',
    date: '12 Jul 2026',
    time: '10:00',
    quota: 300,
    hasCertificate: false,
    description: 'Webinar pengembangan diri untuk membangun personal branding di platform digital.',
    icon: Icons.campaign_rounded,
    color: Color(0xFF8E24AA),
    hostInitial: 'N',
  ),
];