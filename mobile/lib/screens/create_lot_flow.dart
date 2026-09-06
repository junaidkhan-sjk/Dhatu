import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lot_model.dart';
import '../models/recycler_model.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/localization_service.dart';
import '../services/sync_engine.dart';
import 'recycler_profile_screen.dart';
import 'recycler_offer_screen.dart';
import 'main_shell.dart';
import '../services/ai_classifier_service.dart';
import '../services/local_database.dart';
import '../widgets/core/audio_playback_button.dart';
import 'package:uuid/uuid.dart';
class CreateLotFlow extends StatefulWidget {
  const CreateLotFlow({super.key});

  @override
  State<CreateLotFlow> createState() => _CreateLotFlowState();
}

class _CreateLotFlowState extends State<CreateLotFlow> {
  int _currentStep = 1; // 1 of 5
  String _selectedCategory = 'PCB';
  String? _subCategory = 'Mixed Grade Motherboard';
  double _weightKg = 12.5;
  String _photoUrl = '/uploads/sample_pcb.jpg';
  String _predictedCategory = 'PCB';
  int _aiConfidence = 88;
  double _estMinInr = 1500;
  double _estMaxInr = 1800;
  bool _loading = false;
  List<RecyclerRank> _matchedRecyclers = [];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'PCB', 'label': 'सर्किट बोर्ड\n(PCB)', 'icon': Icons.memory_rounded, 'color': Colors.greenAccent},
    {'name': 'Battery', 'label': 'बैटरी\n(Battery)', 'icon': Icons.battery_charging_full_rounded, 'color': Colors.amberAccent},
    {'name': 'Cable', 'label': 'केबल / तार\n(Wire)', 'icon': Icons.cable_rounded, 'color': Colors.blueAccent},
    {'name': 'CRT', 'label': 'सीआरटी टीवी\n(CRT Tube)', 'icon': Icons.tv_rounded, 'color': Colors.purpleAccent},
    {'name': 'Motor', 'label': 'मोटर / कॉइल\n(Motor)', 'icon': Icons.settings_rounded, 'color': Colors.orangeAccent},
  ];

  @override
  void initState() {
    super.initState();
    _recalculateEstimates();
  }

  void _recalculateEstimates() async {
    final res = await ApiService().estimateValue(_selectedCategory, _weightKg);
    setState(() {
      _estMinInr = (res['estimatedValueMinInr'] as num).toDouble();
      _estMaxInr = (res['estimatedValueMaxInr'] as num).toDouble();
    });
  }

  void _fetchMatchingRecyclers() async {
    setState(() => _loading = true);
    final rankings = await ApiService().getMatchedRecyclers(_selectedCategory);
    setState(() {
      _matchedRecyclers = rankings;
      _loading = false;
    });
  }

  void _saveLotOffline() async {
    final sync = Provider.of<SyncEngine>(context, listen: false);
    await sync.addOfflineLot(
      category: _selectedCategory,
      subCategory: _subCategory,
      weightKg: _weightKg,
      estMinInr: _estMinInr,
      estMaxInr: _estMaxInr,
      imageUrl: _photoUrl,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('लॉट ऑफ़लाइन सहेजा गया! (Lot Saved Offline)'),
          backgroundColor: Color(0xFF0F6B6B),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell(initialTabIndex: 1)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'नया लॉट बनाएं (Create Lot)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'चरण $_currentStep / 5 (Step $_currentStep of 5)',
              style: const TextStyle(fontSize: 11, color: Color(0xFFE0A526)),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Progress Bar
            LinearProgressIndicator(
              value: _currentStep / 5.0,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE0A526)),
              minHeight: 4,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildCurrentStepView(loc),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepView(LocalizationService loc) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Camera(loc);
      case 2:
        return _buildStep2CategoryAndAi(loc);
      case 3:
        return _buildStep3Weight(loc);
      case 4:
        return _buildStep4EstimatedValue(loc);
      case 5:
        return _buildStep5RecyclerMatch(loc);
      default:
        return const SizedBox();
    }
  }

  // STEP 1: Camera & Image Upload
  Widget _buildStep1Camera(LocalizationService loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'सामग्री की फोटो लें\nCapture Material Photo',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'कैमरा से साफ फोटो खींचें ताकि AI सही पहचान कर सके।',
          style: TextStyle(fontSize: 13, color: Colors.white60),
        ),
        const SizedBox(height: 24),

        // Photo Frame
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF0F6B6B), width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F6B6B).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 54, color: Color(0xFFE0A526)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'फोटो तैयार है (Photo Captured)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'sample_pcb.jpg · 2.4 MB',
                    style: TextStyle(fontSize: 11, color: Colors.white54, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera simulated / Photo refreshed')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('दोबारा लें (Retake)', style: TextStyle(color: Colors.white70)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() => _loading = true);
                  final predicted = await AiClassifierService().classifyImage(_photoUrl);
                  setState(() {
                    _predictedCategory = predicted;
                    _selectedCategory = predicted;
                    _subCategory = 'Standard $predicted';
                    _aiConfidence = 92;
                    _currentStep = 2;
                    _loading = false;
                  });
                  _recalculateEstimates();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F6B6B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const Text(
                      'फोटो चुनें (Use Photo) →',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 2: AI Classification & Manual Override
  Widget _buildStep2CategoryAndAi(LocalizationService loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // AI Suggestion Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0F6B6B).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF0F6B6B), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F6B6B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFE0A526), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'AI पहचान सुझाव',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0A526),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$_aiConfidence% विश्वासी',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'अनुशंसित: $_selectedCategory ($_subCategory)',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'सामग्री श्रेणी चुनें (Select Category)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'यदि AI सुझाव गलत है, तो नीचे से सही श्रेणी पर टैप करें:',
          style: TextStyle(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 16),

        // 5-Category Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final isSelected = _selectedCategory == cat['name'];

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = cat['name'];
                  _subCategory = 'Standard ${cat['name']}';
                });
                _recalculateEstimates();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0F6B6B).withOpacity(0.3) : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFE0A526) : Colors.white12,
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat['icon'] as IconData, size: 36, color: cat['color'] as Color),
                    const SizedBox(height: 10),
                    Text(
                      cat['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              if (_predictedCategory != _selectedCategory) {
                // Log the override
                final db = LocalDatabase.instance.database;
                await (await db).insert('ai_feedback', {
                  'id': const Uuid().v4(),
                  'imagePath': _photoUrl,
                  'predictedCategory': _predictedCategory,
                  'actualCategory': _selectedCategory,
                  'syncStatus': 'Saved Offline',
                  'createdAt': DateTime.now().toIso8601String(),
                });
              }
              setState(() => _currentStep = 3);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F6B6B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'वजन दर्ज करें (Enter Weight) →',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // STEP 3: Weight Entry
  Widget _buildStep3Weight(LocalizationService loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'सामग्री का वजन दर्ज करें\nEnter Approximate Weight',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'कांटे पर देखा गया वजन किलोग्राम में सेट करें:',
          style: TextStyle(fontSize: 13, color: Colors.white60),
        ),
        const SizedBox(height: 36),

        // Big-digit Display
        Container(
          padding: const EdgeInsets.symmetric(vertical: 36),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE0A526), width: 2),
          ),
          child: Column(
            children: [
              Text(
                '$_weightKg',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE0A526),
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'KILOGRAMS (किलो)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Stepper Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepperButton(
              label: '- 5 kg',
              onTap: () {
                if (_weightKg > 5) {
                  setState(() => _weightKg -= 5);
                  _recalculateEstimates();
                }
              },
            ),
            const SizedBox(width: 12),
            _buildStepperButton(
              label: '- 0.5 kg',
              onTap: () {
                if (_weightKg > 0.5) {
                  setState(() => _weightKg = ((_weightKg - 0.5) * 10).round() / 10);
                  _recalculateEstimates();
                }
              },
            ),
            const SizedBox(width: 12),
            _buildStepperButton(
              label: '+ 0.5 kg',
              onTap: () {
                setState(() => _weightKg = ((_weightKg + 0.5) * 10).round() / 10);
                _recalculateEstimates();
              },
            ),
            const SizedBox(width: 12),
            _buildStepperButton(
              label: '+ 5 kg',
              onTap: () {
                setState(() => _weightKg += 5);
                _recalculateEstimates();
              },
            ),
          ],
        ),
        const SizedBox(height: 40),

        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              _recalculateEstimates();
              setState(() => _currentStep = 4);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F6B6B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'अनुमानित मूल्य देखें (View Estimate) →',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepperButton({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // STEP 4: Estimated Value Range & Audio Playback
  Widget _buildStep4EstimatedValue(LocalizationService loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'अनुमानित बाज़ार मूल्य\nEstimated Market Valuation',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'यह दर हाल ही में अधिकृत रीसायकलर्स द्वारा खरीदे गए भावों पर आधारित है:',
          style: TextStyle(fontSize: 13, color: Colors.white60),
        ),
        const SizedBox(height: 24),

        // Valuation Range Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F6B6B), Color(0xFF073838)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE0A526), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x440F6B6B),
                blurRadius: 20,
                offset: Offset(0, 8),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedCategory · $_weightKg kg',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '±15% बाज़ार सीमा',
                      style: TextStyle(fontSize: 11, color: Color(0xFFE0A526)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '₹${_estMinInr.toInt()} – ₹${_estMaxInr.toInt()}',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE0A526),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '* यह एक अनुमान है, अंतिम दर रीसायकलर की भौतिक जांच के बाद तय होगी।',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.white60),
              ),
              const SizedBox(height: 20),

              // Audio Playback Button
              AudioPlaybackButton(
                textToSpeak: 'आपके $_weightKg किलो $_selectedCategory का अनुमानित मूल्य ${_estMinInr.toInt()} से ${_estMaxInr.toInt()} रुपये है।',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Action Buttons
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              _fetchMatchingRecyclers();
              setState(() => _currentStep = 5);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F6B6B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'नज़दीकी रीसायकलर्स देखें (See Recyclers) →',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),

        OutlinedButton(
          onPressed: _saveLotOffline,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text(
            'लॉट सहेजें और बाद में तय करें (Save for Later)',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // STEP 5: Smart Recycler Matching
  Widget _buildStep5RecyclerMatch(LocalizationService loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'सुझाए गए अधिकृत रीसायकलर्स\nMatched Authorized Recyclers',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'दूरी, भाव और सरकारी सत्यापन स्कोर के आधार पर रैंकिंग:',
          style: TextStyle(fontSize: 13, color: Colors.white60),
        ),
        const SizedBox(height: 20),

        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Color(0xFFE0A526)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _matchedRecyclers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final r = _matchedRecyclers[index];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: index == 0 ? const Color(0xFF0F6B6B) : Colors.white12,
                    width: index == 0 ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            r.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F6B6B).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF0F6B6B)),
                          ),
                          child: Text(
                            '${r.totalScore} Score',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      r.address,
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Text(
                          '₹${r.offeredRateInrPerKg.toInt()}/kg',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFE0A526)),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${r.distanceKm} km दूर',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        const Spacer(),
                        if (r.pickupAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'गाड़ी उपलब्ध (Pickup)',
                              style: TextStyle(fontSize: 10, color: Colors.blueAccent),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecyclerProfileScreen(recycler: r),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('प्रोफाइल देखें', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              final sync = Provider.of<SyncEngine>(context, listen: false);
                              final lot = await sync.addOfflineLot(
                                category: _selectedCategory,
                                subCategory: _subCategory,
                                weightKg: _weightKg,
                                estMinInr: _estMinInr,
                                estMaxInr: _estMaxInr,
                                imageUrl: _photoUrl,
                              );
                              await ApiService().matchLot(lot.id, r.recyclerId);

                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecyclerOfferScreen(
                                      lotId: lot.id,
                                      recyclerName: r.name,
                                      offeredRate: r.offeredRateInrPerKg,
                                      totalEstPrice: r.offeredRateInrPerKg * _weightKg,
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F6B6B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'लॉट भेजें (Send Lot)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
