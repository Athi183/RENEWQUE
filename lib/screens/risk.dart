import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/groq_api.dart';

// ─────────────────────────────────────────────────────────────────
//  API URL — automatically picks the right address:
//    Web/emulator  → localhost / 10.0.2.2
//    Real device   → your PC's LAN IP
// ─────────────────────────────────────────────────────────────────
const String _kLanIp   = '10.52.13.34';          // ← your PC's WiFi IP
const String _kApiBase = kIsWeb
    ? 'http://localhost:8000'
    : 'http://$_kLanIp:8000';  // works on real Android/iOS device

// ─────────────────────────────────────────────────────────────────
//  Colour palette  (eco-theme)
// ─────────────────────────────────────────────────────────────────
const _kBg       = Color(0xFFF8F7F6);
const _kSurface  = Color(0xFFFFFFFF);
const _kPrimaryG = Color(0xFF602D08); // matched to brand brown
const _kAccentG  = Color(0xFF8B4513); // earth / clay
const _kAccentB  = Color(0xFF704214); // muted bronze
const _kEarth    = Color(0xFF4E342E); // deep soil
const _kLow      = Color(0xFF2D6A4F); // keep green for safety
const _kMedium   = Color(0xFFD4813E); // earthy orange
const _kHigh     = Color(0xFFB03A2E); // muted deep red
const _kText     = Color(0xFF1B130D);
const _kSubtext  = Color(0xFF795548);

class RiskPage extends StatefulWidget {
  const RiskPage({super.key});

  @override
  State<RiskPage> createState() => _RiskPageState();
}

class _RiskPageState extends State<RiskPage> with TickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────────────
  XFile?      _pickedFile;     // cross-platform image handle
  Uint8List?  _imageBytes;     // raw bytes — works on web + mobile
  bool    _loading   = false;
  bool    _hasResult = false;
  String? _error;

  double _carbon    = 0;
  double _water     = 0;
  double _waste     = 0;
  double _eis       = 0;
  String _riskLevel = '';
  String? _aiExplanation;
  List<dynamic> _confidences = [];
  String _detectedFabric = '';

  // ── Animation ────────────────────────────────────────────────────
  late AnimationController _fadeController;
  late Animation<double>   _fadeAnimation;
  late AnimationController _gaugeController;
  late Animation<double>   _gaugeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnimation = CurvedAnimation(
        parent: _fadeController, curve: Curves.easeInOut);

    _gaugeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _gaugeAnimation = CurvedAnimation(
        parent: _gaugeController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _gaugeController.dispose();
    super.dispose();
  }

  // ── Image picker ─────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1024);
    if (picked == null) return;
    final bytes = await picked.readAsBytes(); // works on web + mobile
    setState(() {
      _pickedFile  = picked;
      _imageBytes  = bytes;
      _hasResult   = false;
      _error       = null;
    });
    _fadeController.reset();
    _gaugeController.reset();
  }

  // ── API call ─────────────────────────────────────────────────────
  Future<void> _analyzeImage() async {
    if (_imageBytes == null) {
      _showSnack('Please select an image first.');
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      final uri = Uri.parse('$_kApiBase/predict');
      final request = http.MultipartRequest('POST', uri);

      // Use bytes — works on web AND real mobile devices
      final filename = _pickedFile?.name ?? 'image.jpg';
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _imageBytes!,
        filename: filename,
      ));

      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          _carbon    = (data['Carbon']  as num).toDouble();
          _water     = (data['Water']   as num).toDouble();
          _waste     = (data['Waste']   as num).toDouble();
          _eis       = (data['EIS']     as num).toDouble().clamp(0.0, 1.0);
          _riskLevel = data['Risk_Level'] as String;
          _aiExplanation = data['explanation'] as String?;
          _confidences   = data['confidence_breakdown'] as List<dynamic>? ?? [];
          _hasResult = true;
          _loading   = false;
        });

        // --- Fetch professional XAI Explanation from Groq ---
        try {
          final prompt = "Explain the sustainability risk assessment for a garment with these metrics: "
              "Carbon: ${_carbon.toStringAsFixed(2)}kg CO2, "
              "Water: ${_water.toStringAsFixed(1)}L, "
              "Waste: ${_waste.toStringAsFixed(3)}kg, "
              "EIS Score: ${_eis.toStringAsFixed(2)}, "
              "Risk Level: $_riskLevel. "
              "STRICT RULE: Do NOT mention any specific material, fabric type, or fiber names (like Polyester, Cotton, Linen, etc). "
              "Focus only on the environmental impact of these specific numbers. Keep it to 2-3 sentences.";
          
          final xaiResponse = await GroqService.sendMessage(text: prompt);
          setState(() {
            _aiExplanation = xaiResponse;
          });
        } catch (e) {
          debugPrint("XAI Error: $e");
          // Fallback to local explanation if Groq fails
        }

        _fadeController.forward(from: 0);
        _gaugeController.forward(from: 0);
      } else {
        setState(() {
          _error   = 'Server error ${response.statusCode}:\n${response.body}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error   = 'Connection failed.\nURL tried: $_kApiBase/predict\n\n$e';
        _loading = false;
      });
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _kPrimaryG,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ─────────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _appBar(),
      body: Stack(children: [
        _body(),
        if (_loading) _loadingOverlay(),
      ]),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────
  PreferredSizeWidget _appBar() => AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: _kText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Risk Analysis',
            style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800, fontSize: 18, color: _kText)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x26_52B788), // _kAccentG ~15%
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                const Icon(Icons.eco, size: 14, color: _kAccentG),
                const SizedBox(width: 4),
                Text('AI Powered',
                    style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kAccentG)),
              ]),
            ),
          ),
        ],
      );

  // ── Loading overlay ──────────────────────────────────────────────
  Widget _loadingOverlay() => Container(
        color: const Color(0x73000000),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x332D6A4F),
                    blurRadius: 40,
                    offset: Offset(0, 10)),
              ],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_kAccentG)),
              ),
              const SizedBox(height: 20),
              Text('Analysing Sustainability…',
                  style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _kText)),
              const SizedBox(height: 6),
              Text('Verifying fabric fibers and texture',
                  style: GoogleFonts.manrope(fontSize: 12, color: _kSubtext)),
            ]),
          ),
        ),
      );

  // ── Body ─────────────────────────────────────────────────────────
  Widget _body() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _introSection(),
          const SizedBox(height: 20),
          _pickerCard(),
          const SizedBox(height: 16),
          _analyzeButton(),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _errorCard(),
          ],
          if (_hasResult) ...[
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(children: [
                _riskBadge(),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                _explanationCard(),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _fadeController,
                    curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
                  ),
                  child: _alternativeComparison(),
                ),
                const SizedBox(height: 24),
                _sectionLabel('SUSTAINABILITY METRICS'),
                const SizedBox(height: 12),
                _metricsRow(),
                const SizedBox(height: 16),
                _eisCard(),
                const SizedBox(height: 16),
                _wasteCard(),
                const SizedBox(height: 28),
                _sectionLabel('RECOMMENDATIONS'),
                const SizedBox(height: 12),
                _recommendations(),
              ]),
            ),
          ],
        ]),
      );

  // ─── Intro ────────────────────────────────────────────────────────
  Widget _introSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upload a garment photo',
              style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _kText)),
          const SizedBox(height: 6),
          Text(
              'Our AI analyses the fabric and returns its environmental '
              'impact score in seconds.',
              style: GoogleFonts.manrope(fontSize: 13, color: _kSubtext)),
        ],
      );

  // ─── Image Picker Card ────────────────────────────────────────────
  Widget _pickerCard() => Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Color(0x142D6A4F),
                blurRadius: 20,
                offset: Offset(0, 6)),
          ],
        ),
        child: Column(children: [
          // Preview
          GestureDetector(
            onTap: () => _pickImage(ImageSource.gallery),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: _imageBytes != null
                  ? Image.memory(_imageBytes!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover)
                  : Container(
                      height: 220,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0x142D6A4F), Color(0x1F52B788)],
                        ),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(
                                  color: Color(0x2652B788),
                                  shape: BoxShape.circle),
                              child: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 40,
                                  color: _kAccentG),
                            ),
                            const SizedBox(height: 14),
                            Text('Tap to select from gallery',
                                style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: _kPrimaryG)),
                            const SizedBox(height: 4),
                            Text('JPG, PNG up to 10 MB',
                                style: GoogleFonts.manrope(
                                    fontSize: 11, color: _kSubtext)),
                          ]),
                    ),
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              _pickerBtn(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery)),
              const SizedBox(width: 12),
              _pickerBtn(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera)),
              if (_imageBytes != null) ...[
                const SizedBox(width: 12),
                _pickerBtn(
                    icon: Icons.delete_outline,
                    label: 'Clear',
                    color: _kHigh,
                    onTap: () => setState(() {
                          _pickedFile  = null;
                          _imageBytes  = null;
                          _hasResult   = false;
                          _error       = null;
                        })),
              ],
            ]),
          ),
        ]),
      );

  Widget _pickerBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = _kPrimaryG,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Color.fromARGB(
                  (0.09 * 255).round(), color.r.round(), color.g.round(), color.b.round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: color)),
            ]),
          ),
        ),
      );

  // ─── Analyse Button ───────────────────────────────────────────────
  Widget _analyzeButton() => GestureDetector(
        onTap: _imageBytes == null ? null : _analyzeImage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _imageBytes == null
                  ? [Colors.grey.shade300, Colors.grey.shade300]
                  : const [_kPrimaryG, _kAccentG],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _imageBytes == null
                ? []
                : [
                    BoxShadow(
                        color: _kPrimaryG.withAlpha(80),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.analytics_outlined,
                color: _imageBytes == null ? Colors.grey : Colors.white,
                size: 22),
            const SizedBox(width: 10),
            Text('Analyse Sustainability',
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: _imageBytes == null ? Colors.grey : Colors.white)),
          ]),
        ),
      );

  // ─── Error Card ───────────────────────────────────────────────────
  Widget _errorCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x14E63946),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x4DE63946)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.error_outline, color: _kHigh, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(_error!,
                  style: GoogleFonts.manrope(fontSize: 13, color: _kHigh))),
        ]),
      );

  // ─── Risk Badge ───────────────────────────────────────────────────
  Widget _riskBadge() {
    final rc  = _riskColor(_riskLevel);
    final rv  = _riskValue(_riskLevel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          rc.withAlpha(30),
          rc.withAlpha(10),
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rc.withAlpha(64), width: 1.5),
      ),
      child: Row(children: [
        SizedBox(
          width: 90,
          height: 90,
          child: AnimatedBuilder(
            animation: _gaugeAnimation,
            builder: (ctx, _) {
              final v = rv * _gaugeAnimation.value;
              return Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                  value: v,
                  strokeWidth: 7,
                  backgroundColor: rc.withAlpha(38),
                  valueColor: AlwaysStoppedAnimation<Color>(rc),
                  strokeCap: StrokeCap.round,
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${(rv * 100 * _gaugeAnimation.value).toInt()}%',
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: rc)),
                  Text('RISK',
                      style: GoogleFonts.manrope(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: rc.withAlpha(179),
                          letterSpacing: 1.5)),
                ]),
              ]);
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('⚠️  $_riskLevel Risk',
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: rc)),
            const SizedBox(height: 6),
            Text(_riskTagline(_riskLevel),
                style: GoogleFonts.manrope(
                    fontSize: 13,
                    height: 1.5,
                    color: _kText.withAlpha(191))),
          ]),
        ),
      ]),
    );
  }

  // ─── Impact Summary ───────────────────────────────────────────────
  Widget _impactCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _kPrimaryG,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Color(0x662D6A4F),
                blurRadius: 24,
                offset: Offset(0, 8)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.lightbulb_outline, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text('IMPACT SUMMARY',
                style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                    letterSpacing: 1.4)),
          ]),
          const SizedBox(height: 10),
          Text(_impactSummary(_riskLevel, _carbon, _water, _waste),
              style: GoogleFonts.manrope(
                  fontSize: 14, height: 1.6, color: Colors.white)),
        ]),
      );

  // ─── Section label ────────────────────────────────────────────────
  Widget _sectionLabel(String label) => Text(label,
      style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _kSubtext,
          letterSpacing: 1.4));

  // ─── Carbon & Water ───────────────────────────────────────────────
  Widget _metricsRow() => Row(children: [
        Expanded(
          child: _MetricCard(
            emoji: '🌍',
            label: 'Carbon',
            value: _carbon.toStringAsFixed(2),
            unit: 'kg CO₂',
            color: _kEarth,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            emoji: '💧',
            label: 'Water',
            value: _water.toStringAsFixed(1),
            unit: 'litres',
            color: _kAccentB,
          ),
        ),
      ]);

  // ─── EIS gauge ───────────────────────────────────────────────────
  Widget _eisCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 16,
                offset: Offset(0, 4)),
          ],
        ),
        child: Row(children: [
          AnimatedBuilder(
            animation: _gaugeAnimation,
            builder: (ctx, _) {
              final ae = (_eis * _gaugeAnimation.value).clamp(0.0, 1.0);
              final ec = _eis > 0.66
                  ? _kHigh
                  : _eis > 0.33
                      ? _kMedium
                      : _kLow;
              return SizedBox(
                width: 80,
                height: 80,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(
                    value: ae,
                    strokeWidth: 8,
                    backgroundColor: ec.withAlpha(31),
                    valueColor: AlwaysStoppedAnimation<Color>(ec),
                    strokeCap: StrokeCap.round,
                  ),
                  Text('${(ae * 100).toInt()}',
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: ec)),
                ]),
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('📊  EIS',
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: _kText)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _kSubtext.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Impact Score',
                      style: GoogleFonts.manrope(
                          fontSize: 9, color: _kSubtext)),
                ),
              ]),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _gaugeAnimation,
                builder: (ctx, _) {
                  final ae = (_eis * _gaugeAnimation.value).clamp(0.0, 1.0);
                  final ec = _eis > 0.66
                      ? _kHigh
                      : _eis > 0.33
                          ? _kMedium
                          : _kLow;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: ae,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(ec),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(_eisDescription(_eis),
                  style: GoogleFonts.manrope(
                      fontSize: 12, color: _kSubtext)),
            ]),
          ),
        ]),
      );

  // ─── Waste card ───────────────────────────────────────────────────
  Widget _wasteCard() => _MetricCard(
        emoji: '♻️',
        label: 'Waste',
        value: _waste.toStringAsFixed(3),
        unit: 'kg',
        color: _kAccentG,
        fullWidth: true,
        subtitle: "Fabric waste generated during this garment's lifecycle",
      );

  // ─── Recommendations ──────────────────────────────────────────────
  Widget _recommendations() => Column(
        children: _tips(_riskLevel).asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 12,
                      offset: Offset(0, 3)),
                ],
              ),
              child: Row(children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      color: Color(0x1F52B788), shape: BoxShape.circle),
                  child: Center(
                      child: Text(e.value[0],
                          style: const TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(e.value.substring(2).trim(),
                      style: GoogleFonts.manrope(
                          fontSize: 13, color: _kText, height: 1.4)),
                ),
              ]),
            ),
          );
        }).toList(),
      );

  // ─────────────────────────────────────────────────────────────────
  //  Pure helpers
  // ─────────────────────────────────────────────────────────────────
  Color  _riskColor(String l) => l.toLowerCase() == 'low'
      ? _kLow
      : l.toLowerCase() == 'medium'
          ? _kMedium
          : _kHigh;

  double _riskValue(String l) => l.toLowerCase() == 'low'
      ? 0.25
      : l.toLowerCase() == 'medium'
          ? 0.55
          : 0.85;

  String _riskTagline(String l) {
    if (l.toLowerCase() == 'low') {
      return 'Excellent choice! This garment has a low environmental footprint.';
    } else if (l.toLowerCase() == 'medium') {
      return 'Moderate impact detected. Small changes can improve sustainability.';
    }
    return 'High environmental impact. Consider eco-friendly alternatives.';
  }

  String _impactSummary(String l, double c, double w, double ws) {
    if (l.toLowerCase() == 'low') {
      return '🌿 Low risk – sustainable choice! This garment produces only '
          '${c.toStringAsFixed(1)} kg CO₂ and uses ${w.toStringAsFixed(0)} L of water. '
          'Keep making eco-conscious decisions!';
    } else if (l.toLowerCase() == 'medium') {
      return '⚡ Medium risk – room for improvement. With ${c.toStringAsFixed(1)} kg CO₂ '
          'and ${w.toStringAsFixed(0)} L water usage, consider certified sustainable fabrics.';
    }
    return '🔴 High risk – consider alternatives. This garment generates '
        '${c.toStringAsFixed(1)} kg CO₂ and consumes ${w.toStringAsFixed(0)} L of water. '
        'Switching to natural or recycled fibres can reduce impact by up to 60%.';
  }

  String _eisDescription(double eis) {
    if (eis < 0.33) return 'Low impact — eco-friendly material likely';
    if (eis < 0.66) return 'Moderate impact — mixed material composition';
    return 'High impact — synthetic or resource-intensive fabric';
  }

  List<String> _tips(String l) {
    if (l.toLowerCase() == 'low') {
      return [
        '🌱 Share your sustainability success to inspire others.',
        '♻️ When this garment ends its life, donate or compost it.',
        '🛍️ Look for similar eco-certified brands to grow your green wardrobe.',
      ];
    } else if (l.toLowerCase() == 'medium') {
      return [
        '🔄 Wash at lower temperatures to reduce energy and water use.',
        '🌍 Offset carbon by supporting reforestation programs.',
        '🪡 Choose GOTS or OEKO-TEX certified garments next time.',
      ];
    }
    return [
      '🚫 Avoid fast fashion — certain synthetic treatments are major textile pollutants.',
      '💡 Switch to eco-certified or low-impact fabrics where possible.',
      '🔃 Explore upcycling this garment into accessories to reduce waste.',
      '📊 Track your full wardrobe carbon footprint with our dashboard.',
    ];
  }

  String _generateExplanation() {
    List<String> reasons = [];

    if (_carbon > 7) reasons.add("high carbon footprint");
    if (_water > 5000) reasons.add("high water usage");
    if (_waste > 0.15) reasons.add("high waste generation");

    if (reasons.isEmpty) {
      return "Low environmental impact with minimal resource usage.";
    }

    // Join reasons
    final explanation = reasons.join(', ');
    return "Risk due to $explanation.";
  }

  Widget _explanationCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kAccentG.withAlpha(46), width: 1.2),
          boxShadow: [
            BoxShadow(
                color: _kAccentG.withAlpha(20),
                blurRadius: 15,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _kAccentG.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: _kAccentG, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('XAI EXPLANATION',
                          style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _kAccentG,
                              letterSpacing: 1.2)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(_aiExplanation ?? _generateExplanation(),
                      style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kText,
                          height: 1.5)),
                ]),
          ),
        ]),
      );

  // ─── Confidence Section ───────────────────────────────────────────
  Widget _confidenceSection() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 20,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('FABRIC DETECTION CONFIDENCE'),
            const SizedBox(height: 16),
            ..._confidences.map((c) {
              final name = c['name'] as String;
              final conf = (c['confidence'] as num).toDouble();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name,
                            style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _kText)),
                        Text('${conf.toInt()}%',
                            style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _kPrimaryG)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: conf / 100,
                        minHeight: 6,
                        backgroundColor: _kBg,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            conf > 70 ? _kAccentG : _kMedium),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (_confidences.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 12, color: _kSubtext),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Multiple materials detected. Score is weighted by confidence.',
                        style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: _kSubtext),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );

  // ─── Alternative Comparison ───────────────────────────────────────
  Widget _alternativeComparison() {
    // Basic logic for a "What if" scenario
    bool isSynthetic = ['Polyester', 'Nylon', 'Acrylic', 'Denim/Jean', 'Leather'].contains(_detectedFabric);
    String altFabric = isSynthetic ? 'Linen' : 'Recycled Polyester';
    double reduction = isSynthetic ? 70 : 40;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows, color: _kPrimaryG, size: 18),
              const SizedBox(width: 8),
              Text('ECO-SWAP INSIGHT',
                  style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _kPrimaryG,
                      letterSpacing: 1.1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Switching to low-impact production methods could reduce the environmental impact by up to $reduction%!',
            style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kPrimaryG,
                height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Prioritizing water-efficient harvesting and zero-waste fabrication can significantly improve this garment\'s profile.',
            style: GoogleFonts.manrope(
                fontSize: 12,
                color: _kPrimaryG.withAlpha(200),
                height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Reusable Metric Card
// ─────────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final String unit;
  final Color  color;
  final bool   fullWidth;
  final String? subtitle;

  const _MetricCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.fullWidth = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(31),
              blurRadius: 18,
              offset: const Offset(0, 5)),
        ],
      ),
      child: fullWidth ? _wide() : _compact(),
    );
  }

  Widget _emojiBox() => Container(
        padding: EdgeInsets.all(fullWidth ? 12 : 10),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(fullWidth ? 14 : 12),
        ),
        child: Text(emoji,
            style: TextStyle(fontSize: fullWidth ? 26.0 : 22.0)),
      );

  Widget _compact() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _emojiBox(),
        const SizedBox(height: 12),
        Text(label,
            style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _kSubtext,
                letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value,
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    color: color)),
            const SizedBox(width: 4),
            Text(unit,
                style: GoogleFonts.manrope(fontSize: 11, color: _kSubtext)),
          ],
        ),
      ]);

  Widget _wide() => Row(children: [
        _emojiBox(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _kSubtext,
                    letterSpacing: 0.8)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        color: color)),
                const SizedBox(width: 5),
                Text(unit,
                    style: GoogleFonts.manrope(fontSize: 13, color: _kSubtext)),
              ],
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(subtitle!,
                    style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: _kSubtext,
                        fontStyle: FontStyle.italic)),
              ),
          ]),
        ),
      ]);
}
