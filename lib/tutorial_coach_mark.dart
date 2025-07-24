library tutorial_coach_mark;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/util.dart';
import 'package:tutorial_coach_mark/src/widgets/tutorial_coach_mark_widget.dart';

export 'package:tutorial_coach_mark/src/target/target_content.dart';
export 'package:tutorial_coach_mark/src/target/target_focus.dart';
export 'package:tutorial_coach_mark/src/target/target_position.dart';
export 'package:tutorial_coach_mark/src/util.dart';

/// A controller class that manages tutorial coach marks in your Flutter application.
///
/// This class provides functionality to display and control interactive tutorials
/// that guide users through your app's features. It creates an overlay with
/// highlighted areas and explanatory content.
///
/// Example usage:
/// ```dart
/// TutorialCoachMark(
///   targets: targets, // List<TargetFocus>
///   colorShadow: Colors.red,
///   onSkip: () {
///     return true; // returning true closes the tutorial
///   },
/// )..show(context: context);
/// ```
///
/// Content Cycling Example:
/// ```dart
/// final targets = [
///   TargetFocus(
///     identify: "menu",
///     keyTarget: menuKey,
///     enableContentCycling: true, // Overlay tıklandığında içerik değişir
///     enableOverlayTab: true,     // Overlay'e tıklamayı aktifleştir
///     enableTargetTabAsOverlay: true, // Target'a tıklama da overlay gibi davranır
///     autoCloseAfterCycle: true,  // Döngü bitince otomatik kapanır
///     autoClose: true,            // 3 saniye sonra otomatik kapanır
///     autoCloseTimer: Duration(seconds: 3),
///     contents: [
///       TargetContent(
///         align: ContentAlign.bottom,
///         child: Text("İlk içerik - Tıklayın"),
///       ),
///     ],
///     alternativeContents: [
///       [
///         TargetContent(
///           align: ContentAlign.bottom,
///           child: Text("İkinci içerik - Tekrar tıklayın"),
///         ),
///       ],
///       [
///         TargetContent(
///           align: ContentAlign.bottom,
///           child: Text("Son içerik - Bitecek"),
///         ),
///       ],
///     ],
///     onCycleComplete: () {
///       print("Döngü tamamlandı!");
///       return true; // true: kapat, false: devam et
///     },
///   ),
/// ];
/// ```
///
/// Key features:
/// - Multiple target focusing
/// - Content cycling (overlay/target tıklanınca içerik değişir)
/// - Target tap as overlay (target'a tıklama overlay gibi davranır)
/// - Auto close after cycle completion (döngü bitince otomatik kapanma)
/// - Auto close timer (belirli süre sonra otomatik kapanma)
/// - Customizable tap animations (tıklama animasyonları kontrolü)
/// - Customizable animations and styling
/// - Skip button functionality
/// - Support for safe area
/// - Pulse animation effects
/// - Custom overlay filters
///
/// The tutorial can be controlled programmatically using methods like:
/// - [show] - Displays the tutorial
/// - [next] - Moves to next target
/// - [previous] - Returns to previous target
/// - [skip] - Skips the tutorial
/// - [finish] - Ends the tutorial

class TutorialCoachMark {
  final List<TargetFocus> targets;
  final FutureOr<void> Function(TargetFocus)? onClickTarget;
  final FutureOr<void> Function(TargetFocus, TapDownDetails)?
      onClickTargetWithTapPosition;
  final FutureOr<void> Function(TargetFocus)? onClickOverlay;

  /// Content cycling döngüsü tamamlandığında çağrılır
  final FutureOr<void> Function(TargetFocus)? onCycleComplete;

  final Function()? onFinish;
  final double paddingFocus;

  // if onSkip return false, the overlay will not be dismissed and call `next`
  final bool Function()? onSkip;
  final AlignmentGeometry alignSkip;
  final String textSkip;
  final TextStyle textStyleSkip;
  final bool hideSkip;
  final bool useSafeArea;
  final Color colorShadow;
  final double opacityShadow;
  final Duration focusAnimationDuration;
  final Duration unFocusAnimationDuration;
  final Duration pulseAnimationDuration;
  final bool pulseEnable;
  final Widget? skipWidget;
  final bool showSkipInLastTarget;
  final ImageFilter? imageFilter;
  final String? backgroundSemanticLabel;
  final int initialFocus;

  /// Global tıklama animasyonları kontrolü
  /// false olduğunda tüm target'lar için tıklama animasyonları kapalı olur
  /// Individual target'lar kendi enableTapAnimations ile override edebilir
  final bool enableTapAnimations;

  /// Global auto close kontrolü
  /// true olduğunda tüm target'lar için auto close aktif olur
  /// Individual target'lar kendi autoClose ile override edebilir
  final bool autoClose;

  /// Global auto close timer süresi
  /// autoClose true olduğunda bu süre kadar bekleyip target'ları otomatik kapatır
  /// Individual target'lar kendi autoCloseTimer ile override edebilir
  final Duration autoCloseTimer;

  final GlobalKey<TutorialCoachMarkWidgetState> _widgetKey = GlobalKey();
  final bool disableBackButton;

  OverlayEntry? _overlayEntry;
  ModalRoute?
      _blockBackRoute; // Referencia a la ruta que bloquea el botón "Atrás"
  BuildContext? _contextTutorial; // Almacena el contexto para usarlo después

  TutorialCoachMark({
    required this.targets,
    this.colorShadow = Colors.black,
    this.onClickTarget,
    this.onClickTargetWithTapPosition,
    this.onClickOverlay,
    this.onCycleComplete,
    this.onFinish,
    this.paddingFocus = 10,
    this.onSkip,
    this.alignSkip = Alignment.bottomRight,
    this.textSkip = "SKIP",
    this.textStyleSkip = const TextStyle(color: Colors.white),
    this.hideSkip = false,
    this.useSafeArea = true,
    this.opacityShadow = 0.8,
    this.focusAnimationDuration = const Duration(milliseconds: 600),
    this.unFocusAnimationDuration = const Duration(milliseconds: 600),
    this.pulseAnimationDuration = const Duration(milliseconds: 500),
    this.pulseEnable = true,
    this.skipWidget,
    this.showSkipInLastTarget = true,
    this.imageFilter,
    this.initialFocus = 0,
    this.backgroundSemanticLabel,
    this.enableTapAnimations = false,
    this.autoClose = false,
    this.autoCloseTimer = const Duration(seconds: 3),
    this.disableBackButton = true,
  }) : assert(opacityShadow >= 0 && opacityShadow <= 1);

  OverlayEntry _buildOverlay({bool rootOverlay = false}) {
    return OverlayEntry(
      builder: (context) {
        return TutorialCoachMarkWidget(
          key: _widgetKey,
          targets: targets,
          clickTarget: onClickTarget,
          onClickTargetWithTapPosition: onClickTargetWithTapPosition,
          clickOverlay: onClickOverlay,
          onCycleComplete: onCycleComplete,
          paddingFocus: paddingFocus,
          onClickSkip: skip,
          alignSkip: alignSkip,
          skipWidget: skipWidget,
          textSkip: textSkip,
          textStyleSkip: textStyleSkip,
          hideSkip: hideSkip,
          useSafeArea: useSafeArea,
          colorShadow: colorShadow,
          opacityShadow: opacityShadow,
          focusAnimationDuration: focusAnimationDuration,
          unFocusAnimationDuration: unFocusAnimationDuration,
          pulseAnimationDuration: pulseAnimationDuration,
          pulseEnable: pulseEnable,
          finish: finish,
          rootOverlay: rootOverlay,
          showSkipInLastTarget: showSkipInLastTarget,
          imageFilter: imageFilter,
          initialFocus: initialFocus,
          backgroundSemanticLabel: backgroundSemanticLabel,
          enableTapAnimations: enableTapAnimations,
          autoClose: autoClose,
          autoCloseTimer: autoCloseTimer,
        );
      },
    );
  }

  void show({required BuildContext context, bool rootOverlay = false}) {
    OverlayState? overlay = Overlay.of(context, rootOverlay: rootOverlay);
    overlay.let((it) {
      showWithOverlayState(overlay: it, rootOverlay: rootOverlay);
    });
  }

  void showWithNavigatorStateKey({
    required GlobalKey<NavigatorState> navigatorKey,
    bool rootOverlay = false,
  }) {
    navigatorKey.currentState?.overlay?.let((it) {
      showWithOverlayState(
        overlay: it,
        rootOverlay: rootOverlay,
      );
    });
  }

  void showWithOverlayState({
    required OverlayState overlay,
    bool rootOverlay = false,
  }) {
    _contextTutorial = overlay.context; // Guarda el contexto del overlay
    postFrame(() {
      _createAndShow(overlay, rootOverlay: rootOverlay);
      if (disableBackButton) {
        // Bloquea el botón "Atrás" mientras el tutorial está activo
        _blockBackRoute = PageRouteBuilder(
          opaque: false,
          barrierDismissible: false,
          pageBuilder: (context, _, __) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (value, result) async =>
                  false, // Bloquea el retroceso
              child: const SizedBox(), // No muestra nada
            );
          },
        );
        Navigator.of(_contextTutorial!).push(_blockBackRoute!);
      }
    });
  }

  void _createAndShow(
    OverlayState overlay, {
    bool rootOverlay = false,
  }) {
    if (_overlayEntry == null) {
      _overlayEntry = _buildOverlay(rootOverlay: rootOverlay);
      overlay.insert(_overlayEntry!);
    }
  }

  void finish() {
    onFinish?.call();
    _removeOverlay();
  }

  void skip() {
    bool removeOverlay = onSkip?.call() ?? true;
    if (removeOverlay) {
      _removeOverlay();
    } else {
      next();
    }
  }

  bool get isShowing => _overlayEntry != null;

  GlobalKey<TutorialCoachMarkWidgetState> get widgetKey => _widgetKey;

  void next() => _widgetKey.currentState?.next();

  void previous() => _widgetKey.currentState?.previous();

  void goTo(int index) => _widgetKey.currentState?.goTo(index);

  /// Mevcut content index'ini döndürür (content cycling için)
  int? get currentContentIndex => _widgetKey.currentState?.currentContentIndex;

  /// Döngünün tamamlanıp tamamlanmadığını döndürür
  bool get hasCycleCompleted =>
      _widgetKey.currentState?.hasCycleCompleted ?? false;

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    closeHiddenView();
  }

  void removeOverlayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    closeHiddenView();
  }

  void closeHiddenView() {
    // Verifica si hay un contexto válido antes de intentar remover la ruta
    if (_contextTutorial != null &&
        _contextTutorial!.mounted &&
        _blockBackRoute != null) {
      Navigator.of(_contextTutorial!).removeRoute(_blockBackRoute!);
      _blockBackRoute = null;
    }
    _contextTutorial = null;
  }
}
