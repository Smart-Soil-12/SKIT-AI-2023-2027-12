import 'package:flutter/material.dart';
import '../localization/language_provider.dart';
import '../services/hardware_bridge_service.dart';
import '../services/ml_engine_service.dart';
import '../../data/services/backend_api_client.dart';
import '../../data/repositories/soil_telemetry_repository.dart';
import '../../ui/dashboard/view_models/dashboard_view_model.dart';
import '../../ui/scan/view_models/scan_view_model.dart';
import '../../ui/yield/view_models/yield_view_model.dart';
import '../../ui/ai_chat/view_models/ai_chat_view_model.dart';

/// Top-level state container providing pure Flutter reactivity & cross-team service injection.
class SmartSoilAppState extends StatefulWidget {
  final Widget child;

  const SmartSoilAppState({super.key, required this.child});

  @override
  State<SmartSoilAppState> createState() => _SmartSoilAppStateState();
}

class _SmartSoilAppStateState extends State<SmartSoilAppState> {
  late final LanguageProvider language;
  late final BackendApiClient backendClient;
  late final SoilTelemetryRepository telemetryRepo;
  late final HardwareBridgeService hardwareBridge;
  late final MLEngineService mlEngine;

  late final DashboardViewModel dashboard;
  late final ScanViewModel scan;
  late final YieldViewModel yieldVm;
  late final AiChatViewModel chat;

  @override
  void initState() {
    super.initState();
    language = LanguageProvider()..addListener(_onStateChanged);
    backendClient = BackendApiClient();
    telemetryRepo = SoilTelemetryRepository(apiClient: backendClient);
    hardwareBridge = HardwareBridgeService();
    mlEngine = MLEngineService();

    dashboard = DashboardViewModel()..addListener(_onStateChanged);
    scan = ScanViewModel()..addListener(_onStateChanged);
    yieldVm = YieldViewModel()..addListener(_onStateChanged);
    chat = AiChatViewModel()..addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    language.removeListener(_onStateChanged);
    dashboard.removeListener(_onStateChanged);
    scan.removeListener(_onStateChanged);
    yieldVm.removeListener(_onStateChanged);
    chat.removeListener(_onStateChanged);

    language.dispose();
    dashboard.dispose();
    scan.dispose();
    yieldVm.dispose();
    chat.dispose();
    telemetryRepo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartSoilScope(
      language: language,
      backendClient: backendClient,
      telemetryRepo: telemetryRepo,
      hardwareBridge: hardwareBridge,
      mlEngine: mlEngine,
      dashboard: dashboard,
      scan: scan,
      yieldVm: yieldVm,
      chat: chat,
      child: widget.child,
    );
  }
}

/// InheritedWidget making all Smart Soil services accessible cleanly across the entire widget tree.
class SmartSoilScope extends InheritedWidget {
  final LanguageProvider language;
  final BackendApiClient backendClient;
  final SoilTelemetryRepository telemetryRepo;
  final HardwareBridgeService hardwareBridge;
  final MLEngineService mlEngine;

  final DashboardViewModel dashboard;
  final ScanViewModel scan;
  final YieldViewModel yieldVm;
  final AiChatViewModel chat;

  const SmartSoilScope({
    super.key,
    required this.language,
    required this.backendClient,
    required this.telemetryRepo,
    required this.hardwareBridge,
    required this.mlEngine,
    required this.dashboard,
    required this.scan,
    required this.yieldVm,
    required this.chat,
    required super.child,
  });

  static SmartSoilScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SmartSoilScope>();
    assert(scope != null, 'No SmartSoilScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(SmartSoilScope oldWidget) => true;
}
