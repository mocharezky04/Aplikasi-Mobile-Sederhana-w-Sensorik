import 'dart:async';
import 'dart:math' as math;

import 'package:ambient_light/ambient_light.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const SensorApp());
}

class SensorApp extends StatelessWidget {
  const SensorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensor Demo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SensorMenuPage(),
    );
  }
}

enum SensorType { accelerometer, gyroscope, light }

class SensorMenuPage extends StatelessWidget {
  const SensorMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Sensor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pilih satu sensor untuk lihat data realtime dan ilustrasinya.',
          ),
          const SizedBox(height: 12),
          _SensorMenuCard(
            title: 'Accelerometer',
            subtitle: 'Gerak dan percepatan perangkat',
            icon: Icons.directions_run_rounded,
            color: const Color(0xFFE7F7F3),
            onTap: () => _openSensor(context, SensorType.accelerometer),
          ),
          _SensorMenuCard(
            title: 'Compass',
            subtitle: 'Arah hadap HP (N, E, S, W)',
            icon: Icons.explore_rounded,
            color: const Color(0xFFE9EEFF),
            onTap: () => _openSensor(context, SensorType.gyroscope),
          ),
          _SensorMenuCard(
            title: 'Light Sensor',
            subtitle: 'Tampilan ikut gelap/terang sesuai cahaya',
            icon: Icons.wb_sunny_rounded,
            color: const Color(0xFFFFF3E0),
            onTap: () => _openSensor(context, SensorType.light),
          ),
        ],
      ),
    );
  }

  void _openSensor(BuildContext context, SensorType sensor) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => SensorDetailPage(sensor: sensor)),
    );
  }
}

class _SensorMenuCard extends StatelessWidget {
  const _SensorMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class SensorDetailPage extends StatelessWidget {
  const SensorDetailPage({required this.sensor, super.key});

  final SensorType sensor;

  @override
  Widget build(BuildContext context) {
    switch (sensor) {
      case SensorType.accelerometer:
        return const AccelerometerPage();
      case SensorType.gyroscope:
        return const GyroscopePage();
      case SensorType.light:
        return const LightPage();
    }
  }
}

class AccelerometerPage extends StatefulWidget {
  const AccelerometerPage({super.key});

  @override
  State<AccelerometerPage> createState() => _AccelerometerPageState();
}

class _AccelerometerPageState extends State<AccelerometerPage> {
  StreamSubscription<AccelerometerEvent>? _subscription;
  bool _hasData = false;
  DateTime? _lastTick;
  double _speedMps = 0.0;
  double _distanceM = 0.0;

  @override
  void initState() {
    super.initState();
    _subscription = accelerometerEventStream().listen(_onEvent);
  }

  void _onEvent(AccelerometerEvent event) {
    final now = DateTime.now();
    final dtSeconds = _lastTick == null
        ? 0.0
        : (now.difference(_lastTick!).inMilliseconds / 1000).clamp(0.0, 0.08);
    _lastTick = now;

    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    final linearAcc = math.max(0.0, magnitude - 9.81);

    var newSpeed = _speedMps + (linearAcc * dtSeconds);
    newSpeed *= 0.96;
    newSpeed = newSpeed.clamp(0.0, 8.0);

    final newDistance = _distanceM + (newSpeed * dtSeconds);

    if (mounted) {
      setState(() {
        _hasData = true;
        _speedMps = newSpeed;
        _distanceM = newDistance;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final runnerOffset = (_speedMps / 8.0) * 220.0;
    final runnerBounce = 8 + (math.sin(_distanceM * 5) * 5).abs();

    return Scaffold(
      appBar: AppBar(title: const Text('Accelerometer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFE7F7F3),
            child: SizedBox(
              height: 190,
              child: Stack(
                children: [
                  Positioned(
                    top: 14,
                    left: 16,
                    right: 16,
                    child: Text(
                      'Ilustrasi lari (kecepatan ikut data accelerometer)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 46,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade200,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    left: 24 + runnerOffset,
                    bottom: 54 + runnerBounce,
                    child: Icon(
                      Icons.directions_run_rounded,
                      size: 66,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _dataPanel(
            context,
            title: 'Data Realtime',
            children: [
              if (!_hasData)
                const Text('Mendeteksi sensor...')
              else ...[
                _singleValueTile(
                  'Kecepatan Estimasi',
                  '${_speedMps.toStringAsFixed(2)} m/s',
                ),
                _singleValueTile(
                  'Jarak Estimasi',
                  '${_distanceM.toStringAsFixed(2)} meter',
                ),
                const SizedBox(height: 6),
                const Text(
                  'Nilai X/Y/Z disembunyikan supaya fokus ke hasil gerak yang mudah dipahami.',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class GyroscopePage extends StatefulWidget {
  const GyroscopePage({super.key});

  @override
  State<GyroscopePage> createState() => _GyroscopePageState();
}

class _GyroscopePageState extends State<GyroscopePage> {
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  double? _headingDegrees;
  String? _errorMessage;
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  DateTime? _lastGyroTick;

  @override
  void initState() {
    super.initState();
    _compassSubscription = FlutterCompass.events?.listen(
      (event) {
        final value = event.heading;
        if (value == null) return;
        if (mounted) {
          setState(() {
            _headingDegrees = _normalizeHeading(value);
            _errorMessage = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Sensor compass tidak tersedia di perangkat ini.';
          });
        }
      },
    );

    _gyroSubscription = gyroscopeEventStream().listen((event) {
      final now = DateTime.now();
      final dtSeconds = _lastGyroTick == null
          ? 0.0
          : (now.difference(_lastGyroTick!).inMilliseconds / 1000).clamp(
              0.0,
              0.05,
            );
      _lastGyroTick = now;

      final integratedX = (_tiltX + (event.x * dtSeconds)).clamp(-0.5, 0.5);
      final integratedY = (_tiltY - (event.y * dtSeconds)).clamp(-0.5, 0.5);
      final dampedX = integratedX * 0.995;
      final dampedY = integratedY * 0.995;

      if (mounted) {
        setState(() {
          _tiltX = dampedX.abs() < 0.002 ? 0.0 : dampedX;
          _tiltY = dampedY.abs() < 0.002 ? 0.0 : dampedY;
        });
      }
    });
  }

  double _normalizeHeading(double heading) {
    final normalized = heading % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _gyroSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heading = _headingDegrees;
    final headingRadians = heading == null ? 0.0 : heading * math.pi / 180;
    final direction = heading == null ? '-' : _directionFromHeading(heading);
    final tiltAmount = ((_tiltX.abs() + _tiltY.abs()) / 1.0).clamp(0.0, 1.0);
    final dialShadowOffset = Offset(_tiltY * 22, 12 - (_tiltX * 8));
    final glareAlignment = Alignment(
      (_tiltY * 1.8).clamp(-1.0, 1.0),
      (_tiltX * 1.8).clamp(-1.0, 1.0),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Compass')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFE9EEFF),
            child: SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 14,
                    child: Text(
                      'Compass bergerak sesuai arah HP',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Container(
                    width: 210,
                    height: 210,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0022)
                        ..rotateX(_tiltX)
                        ..rotateY(_tiltY),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Colors.blue.shade100],
                          ),
                          border: Border.all(
                            color: Colors.blue.shade300,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200.withValues(alpha: 0.5),
                              blurRadius: 22 + (tiltAmount * 8),
                              spreadRadius: 2 + (tiltAmount * 2),
                              offset: dialShadowOffset,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  center: glareAlignment,
                                  radius: 1.0,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.55),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            const Positioned(top: 14, child: Text('N')),
                            const Positioned(right: 18, child: Text('E')),
                            const Positioned(bottom: 14, child: Text('S')),
                            const Positioned(left: 18, child: Text('W')),
                            Transform.rotate(
                              angle: headingRadians,
                              child: Icon(
                                Icons.navigation_rounded,
                                size: 86,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _dataPanel(
            context,
            title: 'Data Realtime',
            children: [
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red))
              else if (heading == null)
                const Text('Mendeteksi sensor...')
              else ...[
                _singleValueTile(
                  'Heading',
                  '${heading.toStringAsFixed(0)} derajat',
                ),
                _singleValueTile(
                  'Arah',
                  direction,
                ),
                _singleValueTile(
                  'Gyroscope Tilt',
                  'X ${(_tiltX * 57.3).toStringAsFixed(1)}°, Y ${(_tiltY * 57.3).toStringAsFixed(1)}°',
                ),
                const Text(
                  'Arah dari compass, dengan efek 3D dari gyroscope.',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

String _directionFromHeading(double heading) {
  const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
  final index = ((heading + 22.5) / 45).floor();
  return directions[index];
}

class LightPage extends StatefulWidget {
  const LightPage({super.key});

  @override
  State<LightPage> createState() => _LightPageState();
}

class _LightPageState extends State<LightPage> {
  final AmbientLight _ambientLight = AmbientLight();
  StreamSubscription<double>? _subscription;

  double? _lux;
  String? _statusMessage;
  double _minLux = 4.0;
  double _maxLux = 46.0;

  @override
  void initState() {
    super.initState();
    _subscription = _ambientLight.ambientLightStream.listen(
      (value) {
        if (mounted) {
          setState(() {
            _lux = value;
            _statusMessage = null;
            if (value < _minLux) {
              _minLux = value;
            }
            if (value > _maxLux) {
              _maxLux = value;
            }
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _statusMessage =
                'Sensor cahaya tidak tersedia atau belum didukung di HP ini.';
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lux = _lux ?? 0.0;
    final adaptiveRange = math.max(8.0, _maxLux - _minLux);
    final normalized = ((lux - _minLux) / adaptiveRange).clamp(0.0, 1.0);
    final visualNormalized = (0.28 + (normalized * 0.72)).clamp(0.0, 1.0);
    final backgroundColor = Color.lerp(
      const Color(0xFF2A2E36),
      const Color(0xFFFFF9E8),
      visualNormalized,
    )!;
    final foregroundColor = Color.lerp(
      Colors.white,
      Colors.black87,
      visualNormalized,
    )!;

    return Scaffold(
      appBar: AppBar(title: const Text('Light Sensor')),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: backgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: foregroundColor.withValues(alpha: 0.18),
                ),
              ),
              child: SizedBox(
                height: 210,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      normalized > 0.45
                          ? Icons.wb_sunny_rounded
                          : Icons.nightlight_round,
                      size: 88,
                      color: foregroundColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      normalized > 0.45
                          ? 'Cahaya terang, tampilan ikut cerah'
                          : 'Cahaya redup, tampilan ikut gelap',
                      style: TextStyle(color: foregroundColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: foregroundColor.withValues(alpha: 0.18),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Realtime',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: foregroundColor),
                    ),
                    const SizedBox(height: 10),
                    if (_statusMessage != null)
                      Text(
                        _statusMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      )
                    else if (_lux == null)
                      Text(
                        'Mendeteksi sensor...',
                        style: TextStyle(color: foregroundColor),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Intensitas cahaya: ${_lux!.toStringAsFixed(2)} lux',
                            style: TextStyle(color: foregroundColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kalibrasi adaptif: min ${_minLux.toStringAsFixed(1)} - max ${_maxLux.toStringAsFixed(1)} lux',
                            style: TextStyle(
                              color: foregroundColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
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

Widget _dataPanel(
  BuildContext context, {
  required String title,
  required List<Widget> children,
}) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    ),
  );
}

Widget _singleValueTile(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text('$label: $value'),
  );
}
