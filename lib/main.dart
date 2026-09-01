import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  double _sensitivity = 65.0; 
  double _currentDecibel = 30.0;
  bool _isAlarmTriggered = false;
  Timer? _timer;

  final AudioPlayer _audioPlayer = AudioPlayer();

  String babyName = "سحر";
  String babyAge = "4 أشهر و 15 يوماً";

  List<Map<String, String>> cryLogs = [
    {'time': 'اليوم - 02:15 م', 'duration': 'دقيقة و 20 ثانية', 'decibel': '76 dB'},
  ];

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.85,
      upperBound: 1.15,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleMonitoring() {
    setState(() {
      _isMonitoring = !_isMonitoring;
      if (_isMonitoring) {
        _timer = Timer.periodic(const Duration(milliseconds: 400), (t) {
          setState(() {
            _currentDecibel = 30.0 + (DateTime.now().millisecond % 50);
            if (_currentDecibel > _sensitivity && !_isAlarmTriggered) {
              _triggerAlarm();
            }
          });
        });
      } else {
        _timer?.cancel();
        _isAlarmTriggered = false;
        _currentDecibel = 0.0;
      }
    });
  }

  void _triggerAlarm() {
    setState(() {
      _isAlarmTriggered = true;
      cryLogs.insert(0, {
        'time': 'الآن',
        'duration': 'جاري البكاء',
        'decibel': '${_currentDecibel.toInt()} dB',
      });
    });
  }

  void _stopAlarm() {
    setState(() {
      _isAlarmTriggered = false;
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFFF7E95),
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.mic_rounded), label: 'المراقبة'),
            BottomNavigationBarItem(icon: Icon(Icons.nightlight_rounded), label: 'أصوات النوم'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'السجل'),
          ],
        ),
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
              ],
            ),
          ),
        ),
        if (_isAlarmTriggered) _buildAlarmOverlay(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Icon(Icons.child_friendly_rounded, color: Color(0xFFFF7E95), size: 28),
        Text('مراقب الطفل الذكي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E2D4D))),
        Icon(Icons.shield_outlined, color: Color(0xFF8E8AFF), size: 28),
      ],
    );
  }

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
              radius: 28,
              backgroundColor: Color(0xFFF3E5F5),
              child: Icon(Icons.face_rounded, size: 34, color: Color(0xFFFF6D8A)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(babyName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('العمر: $babyAge', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9))),
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

  Widget _buildAudioVisualizer() {
    return Container(
      height: 220,
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
                  color: const Color(0xFFFF7E95).withOpacity(0.15),
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
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isMonitoring ? '${_currentDecibel.toInt()}' : '--',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text('dB ديسيبل', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          Positioned(
            bottom: 15,
            child: Text(
              _isMonitoring
                  ? (_currentDecibel > _sensitivity ? '🚨 تم التقاط بكاء!' : '💤 الغرفة هادئة')
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
              const Text('حساسية التقاط البكاء', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('${_sensitivity.toInt()} dB', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF7E95))),
            ],
          ),
          const SizedBox(height: 5),
          const Text('اسحب لتحديد مستوى الحساسية المرغوب', style: TextStyle(fontSize: 11, color: Colors.grey)),
          Slider(
            value: _sensitivity,
            min: 30.0,
            max: 90.0,
            activeColor: const Color(0xFFFF7E95),
            inactiveColor: Colors.grey.shade200,
            onChanged: (val) {
              setState(() {
                _sensitivity = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainControlButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isMonitoring ? const Color(0xFFFE5B78) : const Color(0xFF8E8AFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: _toggleMonitoring,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_isMonitoring ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              _isMonitoring ? 'إيقاف المراقبة' : 'بدء تشغيل المراقبة',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

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
          Text('تنبيه! $babyName تبكي الآن 😭', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          Text('شدة الصوت: ${_currentDecibel.toInt()} ديسيبل', style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: _stopAlarm,
            child: const Text('إيقاف التنبيه', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFE5B78))),
          ),
        ],
      ),
    );
  }

  Widget _buildSoothingSoundsScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أصوات مهدئة للنوم', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildSoundTile('صوت المطر الهادئ', Icons.water_drop_rounded, const Color(0xFF64B5F6)),
                  _buildSoundTile('الضوضاء البيضاء', Icons.waves_rounded, const Color(0xFF81C784)),
                  _buildSoundTile('دقات قلب الأم', Icons.favorite_rounded, const Color(0xFFE57373)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundTile(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          IconButton(
            icon: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF8E8AFF), size: 32),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تشغيل: $title')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCryLogsScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('سجل البكاء', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cryLogs.length,
                itemBuilder: (context, index) {
                  final log = cryLogs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log['time']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(log['duration']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        Text(log['decibel']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8E8AFF))),
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
}
