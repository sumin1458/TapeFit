import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/tape_analyzer.dart';

/// 화면 한 장을 가져오는 통로. 카메라가 준비되면 [grab]이 채워진다.
class FrameGrabber {
  Future<RawFrame?> Function()? grab;
}

/// 카메라 영상을 그리는 위젯 빌더. 테스트에서는 가짜로 바꾼다.
typedef CameraFeedBuilder = Widget Function(BuildContext context, FrameGrabber grabber);

final cameraFeedBuilderProvider =
    Provider<CameraFeedBuilder>((ref) => (context, grabber) => CameraFeed(grabber: grabber));

/// 실제 카메라 미리보기. 영상은 화면에만 표시하고 저장·전송하지 않는다.
class CameraFeed extends StatefulWidget {
  const CameraFeed({super.key, required this.grabber});
  final FrameGrabber grabber;

  @override
  State<CameraFeed> createState() => _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  CameraController? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('noCamera', '사용 가능한 카메라가 없어요.');
      }
      final back = cameras.where((c) => c.lensDirection == CameraLensDirection.back);
      final controller = CameraController(
        back.isNotEmpty ? back.first : cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      widget.grabber.grab = _grab;
      setState(() => _controller = controller);
    } catch (_) {
      if (mounted) setState(() => _error = '카메라를 사용할 수 없어요. 브라우저·기기의 카메라 권한을 확인해 주세요.');
    }
  }

  // 분석용으로 작게 줄인 한 장만 메모리에서 쓰고 저장·전송하지 않는다.
  Future<RawFrame?> _grab() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return null;
    final bytes = await (await c.takePicture()).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 160);
    final img = (await codec.getNextFrame()).image;
    final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) return null;
    return RawFrame(img.width, img.height, data.buffer.asUint8List());
  }

  @override
  void dispose() {
    widget.grabber.grab = null;
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        ),
      );
    }
    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: c.value.previewSize?.height ?? 480,
        height: c.value.previewSize?.width ?? 640,
        child: CameraPreview(c),
      ),
    );
  }
}
