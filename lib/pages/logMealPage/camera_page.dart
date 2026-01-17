import 'package:Calogotchi/pages/logMealPage/analysisResultPage.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({super.key});

  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;

  String _currentMode = 'ai';
  bool _isFlashOn = false;
  final ImagePicker _picker = ImagePicker();

  // ✅ เพิ่ม state สำหรับเก็บรูปที่ถ่าย
  String? _capturedImagePath;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (!mounted) return;
        setState(() => _isReady = true);
      }
    } catch (e) {
      print('Error setting up camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    _isFlashOn = !_isFlashOn;
    await _controller!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  Future<void> _openGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print("📸 Selected image from gallery: ${image.path}");
        setState(() {
          _capturedImagePath = image.path;
        });
      }
    } catch (e) {
      print('Error opening gallery: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      setState(() => _isProcessing = true);

      final image = await _controller!.takePicture();
      print("📸 Picture taken: ${image.path}");

      setState(() {
        _capturedImagePath = image.path;
        _isProcessing = false;
      });
    } catch (e) {
      print('Error taking picture: $e');
      setState(() => _isProcessing = false);
    }
  }

  void _retakePicture() {
    setState(() {
      _capturedImagePath = null;
    });
  }

  void _confirmPicture() {
    if (_capturedImagePath == null) return;

    print("✅ Confirmed image: $_capturedImagePath");
    print("📊 Mode: $_currentMode");

    // ส่งค่า imagePath และ mode ไปที่หน้า AnalysisResultPage

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisResultPage(
          imagePath: _capturedImagePath!,
          mode: _currentMode,
        ),
      ),
    ).then((_) {
      // หลังจากผู้ใช้กด Back กลับมาจากหน้าผลลัพธ์
      // เราจะทำการ Reset ค่า เพื่อให้ผู้ใช้ถ่ายรูปใหม่ได้ทันที
      setState(() {
        _capturedImagePath = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Initializing camera...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview หรือ Captured Image
          Positioned.fill(
            child: _capturedImagePath != null
                ? Image.file(File(_capturedImagePath!), fit: BoxFit.cover)
                : CameraPreview(_controller!),
          ),

          // Overlay + Frame (เฉพาะ Food Label)
          if (_currentMode == 'label') ...[
            // Dark overlay
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6),
                  BlendMode.srcOut,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 320,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // White corners frame
            Center(
              child: SizedBox(
                width: 320,
                height: 180,
                child: Stack(
                  children: [
                    _buildCorner(top: 0, left: 0, isTop: true, isLeft: true),
                    _buildCorner(top: 0, right: 0, isTop: true, isLeft: false),
                    _buildCorner(
                      bottom: 0,
                      left: 0,
                      isTop: false,
                      isLeft: true,
                    ),
                    _buildCorner(
                      bottom: 0,
                      right: 0,
                      isTop: false,
                      isLeft: false,
                    ),
                  ],
                ),
              ),
            ),

            // Instruction text
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  'Align nutrition label inside frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                ),
              ),
            ),
          ],

          // Back button
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Top info banner
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    _currentMode == 'ai'
                        ? Icons.auto_awesome
                        : Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _currentMode == 'ai'
                          ? 'Point at your food to analyze'
                          : 'Scan nutrition label',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _capturedImagePath != null
                ? _buildConfirmControls() // แสดงปุ่มยืนยัน/ถ่ายใหม่
                : _buildCameraControls(), // แสดงปุ่มถ่ายรูปปกติ
          ),
        ],
      ),
    );
  }

  // ✅ ปุ่มควบคุมกล้องปกติ
  Widget _buildCameraControls() {
    return Column(
      children: [
        // Mode tabs
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeTab(
              'AI Calculator',
              Icons.auto_awesome,
              _currentMode == 'ai',
              'ai',
            ),
            const SizedBox(width: 15),
            _buildModeTab(
              'Food Label',
              Icons.document_scanner,
              _currentMode == 'label',
              'label',
            ),
          ],
        ),

        const SizedBox(height: 35),

        // Camera controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Flash button
            _buildCircleIcon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              _toggleFlash,
              _isFlashOn ? Colors.amber : Colors.white,
            ),

            // Shutter button
            GestureDetector(
              onTap: _isProcessing ? null : _takePicture,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isProcessing ? Colors.grey : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: _isProcessing
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            ),

            // Gallery button
            _buildCircleIcon(Icons.photo_library, _openGallery, Colors.white),
          ],
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ✅ ปุ่มยืนยัน/ถ่ายใหม่
  Widget _buildConfirmControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Retake button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _retakePicture,
              icon: const Icon(Icons.refresh, size: 24),
              label: const Text(
                'Retake',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Confirm button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _confirmPicture,
              icon: const Icon(Icons.check_circle, size: 24),
              label: const Text(
                'Use Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab(
    String label,
    IconData icon,
    bool isActive,
    String mode,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _currentMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFFFA726) : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF5D4037) : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}
