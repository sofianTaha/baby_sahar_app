import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const BabySaharApp());
}

class BabySaharApp extends StatelessWidget {
  const BabySaharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baby Sahar Monitor',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF9F7FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF7E95),
          primary: const Color(0xFFFF7E95),
          secondary: const Color(0xFF8E8AFF),
        ),
        useMaterial3: true,
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isMonitoring = false;
  double _sensitivity = 65.0; // عتبة الحساسية بالديسيبل
  double _currentDecibel = 32.0; // ديسيبل تجريبي متحرك
  bool _isAlarmTriggered = false;
  Timer? _soundSimulatorTimer;

  // بيانات الطفل
  String babyName = "سحر";
  String babyAge = "4 أشهر و 15 يوماً";

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.85,
      upperBound: 1.15,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _soundSimulatorTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleMonitoring() {
    setState(() {
      _isMonitoring = !_isMonitoring;
      if (_isMonitoring) {
        // محاكي حي لتغيرات الصوت لإظهار حركة الواجهة
        _soundSimulatorTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
          setState(() {
            _currentDecibel = 28.0 + (DateTime.now().millisecond % 50);
            if (_currentDecibel > _sensitivity) {
              _isAlarmTriggered = true;
            }
          });
        });
      } else {
        _soundSimulatorTimer?.cancel();
        _isAlarmTriggered = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _currentIndex == 0
            ? _buildMonitorScreen()
            : _currentIndex == 1
                ? _buildSoothingSoundsScreen()
                : _buildCryLogsScreen(),
        bottomNavigationBar: _buildModernBottomBar(),
      ),
    );
  }

  Widget _buildMonitorScreen() {
    return Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildBabyProfileCard(),
                const SizedBox(height: 25),
                _buildAudioVisualizer(),
                const SizedBox(height: 25),
                _buildSensitivitySlider(),
                const SizedBox(height: 30),
                _buildMainControlButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        if (_isAlarmTriggered) _buildAlarmOverlay(),
      ],
    );
  }

  // رأس الشاشة
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: const Icon(Icons.menu_rounded, color: Color(0xFF4A4A68)),
        ),
        const Text(
          'مراقب الطفل الذكي',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2E2D4D)),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: const Icon(Icons.settings_outlined, color: Color(0xFF4A4A68)),
        ),
      ],
    );
  }

  // كرت الطفل
  Widget _buildBabyProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF94A8), Color(0xFFFF6D8A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFF6D8A).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFF3E5F5),
              child: Icon(Icons.child_care_rounded, size: 36, color: Color(0xFFFF6D8A)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  babyName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'العمر: $babyAge',
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(_isMonitoring ? Icons.mic_rounded : Icons.mic_off_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _isMonitoring ? 'نشط' : 'متوقف',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // مؤشر الصوت النابض
  Widget _buildAudioVisualizer() {
    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isMonitoring)
            ScaleTransition(
              scale: _pulseController,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF7E95).withOpacity(0.12),
                ),
              ),
            ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isMonitoring
                    ? [const Color(0xFF8E8AFF), const Color(0xFF6B65FF)]
                    : [Colors.grey.shade300, Colors.grey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isMonitoring ? const Color(0xFF8E8AFF) : Colors.grey).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isMonitoring ? '${_currentDecibel.toInt()}' : '--',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  'dB ديسيبل',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 15,
            child: Text(
              _isMonitoring
                  ? (_currentDecibel > 50 ? '🔊 يوجد ضجيج بالغرفة' : '💤 الغرفة هادئة جداً')
                  : 'المراقبة غير مفعلة',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _isMonitoring ? const Color(0xFF4A4A68) : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // شريط التحكم في حساسية الالتقاط
  Widget _buildSensitivitySlider() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'حساسية التقاط البكاء',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E2D4D)),
              ),
              Text(
                '${_sensitivity.toInt()} dB',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF7E95)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'قلل القيمة لالتقاط الأصوات البعيدة والهمسات الخافتة',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFFF7E95),
              thumbColor: const Color(0xFFFF7E95),
              overlayColor: const Color(0xFFFF7E95).withOpacity(0.2),
              inactiveTrackColor: Colors.grey.shade200,
              trackHeight: 6,
            ),
            child: Slider(
              value: _sensitivity,
              min: 30.0,
              max: 90.0,
              onChanged: (val) {
                setState(() {
                  _sensitivity = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // زر بدء / إيقاف المراقبة
  Widget _buildMainControlButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isMonitoring ? const Color(0xFFFE5B78) : const Color(0xFF8E8AFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 4,
          shadowColor: (_isMonitoring ? const Color(0xFFFE5B78) : const Color(0xFF8E8AFF)).withOpacity(0.4),
        ),
        onPressed: _toggleMonitoring,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_isMonitoring ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              _isMonitoring ? 'إيقاف المراقبة الآن' : 'تشغيل وضع حراسة الطفل',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // نافذة التنبيه الفوري عند البكاء
  Widget _buildAlarmOverlay() {
    return Container(
      color: const Color(0xFFFE5B78).withOpacity(0.95),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_active_rounded, size: 85, color: Colors.white),
          const SizedBox(height: 20),
          Text(
            'تنبيه! $babyName تبكي الآن 😭',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            'مستوى الصوت المرتفع: ${_currentDecibel.toInt()} ديسيبل',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              setState(() {
                _isAlarmTriggered = false;
              });
            },
            child: const Text(
              'إيقاف التنبيه',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFE5B78)),
            ),
          ),
        ],
      ),
    );
  }

  // شاشة الأصوات المهدئة
  Widget _buildSoothingSoundsScreen() {
    final sounds = [
      {'title': 'صوت المطر الهادئ', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFF64B5F6)},
      {'title': 'ضوضاء بيضاء (White Noise)', 'icon': Icons.waves_rounded, 'color': const Color(0xFF81C784)},
      {'title': 'دقات قلب الأم', 'icon': Icons.favorite_rounded, 'color': const Color(0xFFE57373)},
      {'title': 'تهويدة النوم الكلاسيكية', 'icon': Icons.music_note_rounded, 'color': const Color(0xFFBA68C8)},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أصوات مهدئة للنوم', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text('شغّل هذه الأصوات لمساعدة طفلك على الاستغراق في النوم مجدداً', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                ),
                itemCount: sounds.length,
                itemBuilder: (context, index) {
                  final sound = sounds[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: (sound['color'] as Color).withOpacity(0.15),
                          child: Icon(sound['icon'] as IconData, color: sound['color'] as Color, size: 28),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            sound['title'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // شاشة سجل البكاء
  Widget _buildCryLogsScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('سجل نوبات البكاء', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text('أوقات التنبيهات السابقة ومدة استمرارها', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildLogTile('اليوم - 02:15 م', 'استمر لمدة دقيقة و 20 ثانية', 'شدة الصوت: 76 dB'),
                  _buildLogTile('اليوم - 11:40 ص', 'استمر لمدة 45 ثانية', 'شدة الصوت: 68 dB'),
                  _buildLogTile('أمس - 09:10 م', 'استمر لمدة دقيقتين', 'شدة الصوت: 82 dB'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogTile(String time, String duration, String decibel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, color: Color(0xFFFF7E95)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(duration, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          Text(decibel, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8E8AFF), fontSize: 13)),
        ],
      ),
    );
  }

  // الشريط السفلي للتنقل
  Widget _buildModernBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFF7E95),
        unselectedItemColor: Colors.grey.shade400,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mic_none_rounded), activeIcon: Icon(Icons.mic_rounded), label: 'المراقبة'),
          BottomNavigationBarItem(icon: Icon(Icons.nightlight_outlined), activeIcon: Icon(Icons.nightlight_rounded), label: 'أصوات النوم'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long_rounded), label: 'السجل'),
        ],
      ),
    );
  }
}
