import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:Gnb_Property/features/properties/properties_bloc.dart';
import 'package:Gnb_Property/features/properties/properties_list.dart';
import 'package:Gnb_Property/features/properties/property_detail.dart';
import 'package:Gnb_Property/utils/size_config.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String? initialPropertyId;

Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  initialPropertyId = message.data['property_id'] ?? message.data['propertyId'];
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA6B7vPnEUEBQqyX5i7rq8L-OecuDyqv58",
      projectId: "gnb-property",
      storageBucket: "gnb-property.firebasestorage.app",
      messagingSenderId: "1006197314254",
      appId: "1:1006197314254:android:e18b521502162d8657369f",
    ),
  );

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("fb3cc996-14a0-45b0-84a9-4dc96dfddda2");
  OneSignal.Notifications.requestPermission(true);

  OneSignal.Notifications.addClickListener((event) {
    final data = event.notification.additionalData;
    if (data != null && data.containsKey("property_id")) {
      initialPropertyId = data["property_id"].toString();
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Splash()),
        (route) => false,
      );
    }
  });

  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp({super.key, required this.navigatorKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initFCM();
  }

  void initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Foreground Notification: ${message.data}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final propertyId =
          message.data['property_id'] ?? message.data['propertyId'];
      if (propertyId != null) {
        initialPropertyId = propertyId.toString();
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Splash()),
          (route) => false,
        );
      }
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      final propertyId =
          initialMessage.data['property_id'] ??
          initialMessage.data['propertyId'];
      if (propertyId != null) {
        initialPropertyId = propertyId.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ListPropertyBloc>(create: (_) => ListPropertyBloc()),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Sizer(
            builder: (context, orientation, deviceType) {
              SizeConfig().init(constraints, orientation);
              return MaterialApp(
                navigatorKey: widget.navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'Gnb Property',
                theme: ThemeData(
                  fontFamily: 'AdobeCleanUX',
                  scaffoldBackgroundColor: Colors.white,
                  primarySwatch: Colors.blue,
                ),
                home: const Splash(),
              );
            },
          );
        },
      ),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  double _sliderValue = 0.0;
  bool showIcon = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    startSliderAnimation();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => showIcon = true);
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.read<ListPropertyBloc>().add(FetchProperties());
    });
  }

  void startSliderAnimation() {
    const duration = Duration(seconds: 3);
    const int steps = 28;
    const double endValue = 1.0;
    final increment = endValue / steps;
    final msPerStep = (duration.inMilliseconds / steps).floor();

    int step = 0;
    Timer.periodic(Duration(milliseconds: msPerStep), (timer) {
      if (!mounted) return timer.cancel();
      if (step < steps) {
        setState(() => _sliderValue += increment);
        step++;
      } else {
        setState(() => _sliderValue = endValue);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateBasedOnProperty(List<dynamic> properties) {
    if (initialPropertyId != null) {
      final property = properties.firstWhere(
        (prop) => prop['id'].toString() == initialPropertyId,
        orElse: () => {},
      );
      if (property.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PropertyDetailPage(property: property),
          ),
        );
        return;
      }
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PropertyScreen(properties: properties)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListPropertyBloc, ListPropertyState>(
      listener: (context, state) {
        if (state is ListPropertyLoaded) {
          Future.delayed(const Duration(milliseconds: 300), () {
            _navigateBasedOnProperty(state.properties);
          });
        }
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 200),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 30),
                AnimatedOpacity(
                  opacity: showIcon ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: _animation.value,
                      child: Image.asset('assets/images/start_logo.jpg'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}
