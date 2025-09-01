import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

/// ---------- Preview Screen ----------
class MeetingPreviewPage extends StatefulWidget {
  final String meetingCode;
  final bool isHost;

  const MeetingPreviewPage({
    Key? key,
    required this.meetingCode,
    required this.isHost,
  }) : super(key: key);

  @override
  State<MeetingPreviewPage> createState() => _MeetingPreviewPageState();
}

class _MeetingPreviewPageState extends State<MeetingPreviewPage> {
  CameraController? _controller;
  bool _camReady = false;
  bool _isCamOn = true;
  bool _isMicOn = true;
  bool _permDeniedForever = false;

  @override
  void initState() {
    super.initState();
    _initPermissionsAndCamera();
  }

  Future<void> _initPermissionsAndCamera() async {
    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (camStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      setState(() => _permDeniedForever = true);
      return;
    }
    if (!camStatus.isGranted || !micStatus.isGranted) {
      setState(() => _permDeniedForever = false);
      return;
    }

    final desc = await _pickFrontOrFirstCamera();
    _controller =
        CameraController(desc, ResolutionPreset.medium, enableAudio: true);
    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _camReady = true);
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<CameraDescription> _pickFrontOrFirstCamera() async {
    final cams = await availableCameras();
    if (cams.isEmpty) throw Exception('No cameras found');
    try {
      return cams
          .firstWhere((c) => c.lensDirection == CameraLensDirection.front);
    } catch (_) {
      return cams.first; // fallback
    }
  }

  @override
  void dispose() {
    // ❌ controller dispose mat karo (kyunki MeetingRoomPage use karega)
    super.dispose();
  }

  void _showMeetingInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 8),
                  const Text("Meeting details",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.meetingCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Meeting ID copied")));
                    },
                    icon: const Icon(Icons.copy),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _kv("Meeting ID", widget.meetingCode),
              _kv("Role", widget.isHost ? "Host" : "Participant"),
              _kv("Created", TimeOfDay.now().format(context)),
              _kv("Security", "Only people with this code can join"),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
        const Spacer(),
        Flexible(child: Text(v, textAlign: TextAlign.right)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(widget.isHost ? "Ready to start?" : "Ready to join?"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showMeetingInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview Area
          Expanded(
            child: Center(
              child: !_isCamOn
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.videocam_off,
                      color: Colors.white54, size: 72),
                  SizedBox(height: 8),
                  Text("Camera off",
                      style: TextStyle(color: Colors.white70)),
                ],
              )
                  : (_camReady
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.previewSize?.height,
                    height: _controller!.value.previewSize?.width,
                    child: CameraPreview(_controller!),
                  ),
                ),

              )
                  : (_permDeniedForever
                  ? _permUI(
                text:
                "Permissions permanently denied.\nOpen settings to enable Camera & Microphone.",
                action: () => openAppSettings(),
                actionText: "Open Settings",
              )
                  : _permUI(
                text:
                "Allow Camera & Microphone permissions to continue.",
                action: _initPermissionsAndCamera,
                actionText: "Try Again",
              ))),
            ),
          ),

          // bottom controls
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Text(
                  "Meeting Code: ${widget.meetingCode}",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _roundToggle(
                      iconOn: Icons.mic,
                      iconOff: Icons.mic_off,
                      isOn: _isMicOn,
                      onTap: () => setState(() => _isMicOn = !_isMicOn),
                    ),
                    const SizedBox(width: 16),
                    _roundToggle(
                      iconOn: Icons.videocam,
                      iconOff: Icons.videocam_off,
                      isOn: _isCamOn,
                      onTap: () => setState(() => _isCamOn = !_isCamOn),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MeetingRoomPage(
                            controller: _controller!,
                            meetingCode: widget.meetingCode,
                            isHost: widget.isHost,
                          ),
                        ),
                      );
                    },
                    child: Text(widget.isHost ? "Start Meeting" : "Join Now"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _permUI(
      {required String text,
        required VoidCallback action,
        required String actionText}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.perm_camera_mic, size: 72, color: Colors.white54),
        const SizedBox(height: 12),
        Text(text,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: action, child: Text(actionText)),
      ],
    );
  }

  Widget _roundToggle({
    required IconData iconOn,
    required IconData iconOff,
    required bool isOn,
    required VoidCallback onTap,
  }) {
    return InkResponse(
      onTap: onTap,
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white10,
        child: Icon(isOn ? iconOn : iconOff, color: Colors.white),
      ),
    );
  }
}

/// ---------- Meeting Room ----------
/// ---------- Meeting Room ----------
class MeetingRoomPage extends StatefulWidget {
  final CameraController controller;
  final String meetingCode;
  final bool isHost;

  const MeetingRoomPage({
    Key? key,
    required this.controller,
    required this.meetingCode,
    required this.isHost,
  }) : super(key: key);

  @override
  State<MeetingRoomPage> createState() => _MeetingRoomPageState();
}

class _MeetingRoomPageState extends State<MeetingRoomPage> {
  bool _isMicOn = true;
  bool _isCamOn = true;

  void _showMeetingInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: const [
              Icon(Icons.info_outline),
              SizedBox(width: 8),
              Text("Meeting details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 12),
            _infoRow("Meeting ID", widget.meetingCode),
            _infoRow("Role", widget.isHost ? "Host" : "Participant"),
            _infoRow("Status", "Connected (demo)"),
          ],
        ),
      ),
    );
  }

  static Widget _infoRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Flexible(child: Text(v, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Meeting Room"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showMeetingInfo(context),
          ),
        ],
      ),

      body: Center(
        child: !_isCamOn
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.videocam_off, color: Colors.white54, size: 72),
            SizedBox(height: 8),
            Text("Camera off",
                style: TextStyle(color: Colors.white70)),
          ],
        )
            : FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: widget.controller.value.previewSize?.height,
            height: widget.controller.value.previewSize?.width,
            child: CameraPreview(widget.controller),
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _RoundControl(
              icon: _isMicOn ? Icons.mic : Icons.mic_off,
              onTap: () => setState(() => _isMicOn = !_isMicOn),
            ),
            _RoundControl(
              icon: _isCamOn ? Icons.videocam : Icons.videocam_off,
              onTap: () => setState(() => _isCamOn = !_isCamOn),
            ),
            _RoundControl(
              icon: Icons.call_end,
              color: Colors.red,
              onTap: () => Navigator.pop(context), // Hang up = exit meeting
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoundControl({
    Key? key,
    required this.icon,
    this.color = Colors.white,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white12,
        child: Icon(icon, color: color),
      ),
    );
  }
}
