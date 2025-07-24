import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/clipper/circle_clipper.dart';
import 'package:tutorial_coach_mark/src/clipper/rect_clipper.dart';
import 'package:tutorial_coach_mark/src/paint/light_paint.dart';
import 'package:tutorial_coach_mark/src/paint/light_paint_rect.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';
import 'package:tutorial_coach_mark/src/util.dart';

/// AnimatedFocusLight widget'ı - tutorial target'larının animasyonlu gösterimini sağlar
/// Content cycling özelliği ile overlay'e tıklandığında farklı içerikler gösterilebilir
/// Döngü tamamlandığında otomatik kapanma özelliği mevcuttur
/// Belirli süre sonra otomatik kapanma özelliği mevcuttur
class AnimatedFocusLight extends StatefulWidget {
  const AnimatedFocusLight({
    Key? key,
    required this.targets,
    this.focus,
    this.finish,
    this.removeFocus,
    this.clickTarget,
    this.clickTargetWithTapPosition,
    this.clickOverlay,
    this.onContentChanged,
    this.onCycleComplete,
    this.paddingFocus = 10,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.focusAnimationDuration,
    this.unFocusAnimationDuration,
    this.pulseAnimationDuration,
    this.pulseVariation,
    this.imageFilter,
    this.pulseEnable = true,
    this.rootOverlay = false,
    this.initialFocus = 0,
    this.backgroundSemanticLabel,
    this.enableTapAnimations = false,
    this.autoClose = false,
    this.autoCloseTimer = const Duration(seconds: 3),
  })  : assert(targets.length > 0),
        super(key: key);

  final List<TargetFocus> targets;
  final Function(TargetFocus)? focus;
  final FutureOr Function(TargetFocus)? clickTarget;
  final FutureOr Function(TargetFocus, TapDownDetails)?
      clickTargetWithTapPosition;
  final FutureOr Function(TargetFocus)? clickOverlay;

  /// Content cycling sırasında içerik değiştiğinde çağrılır
  final Function(TargetFocus, int contentIndex)? onContentChanged;

  /// Content cycling döngüsü tamamlandığında çağrılır
  final Function(TargetFocus)? onCycleComplete;

  final Function? removeFocus;
  final Function()? finish;
  final double paddingFocus;
  final Color colorShadow;
  final double opacityShadow;
  final Duration? focusAnimationDuration;
  final Duration? unFocusAnimationDuration;
  final Duration? pulseAnimationDuration;
  final Tween<double>? pulseVariation;
  final bool pulseEnable;
  final bool rootOverlay;
  final ImageFilter? imageFilter;
  final int initialFocus;
  final String? backgroundSemanticLabel;

  /// Global tıklama animasyonları kontrolü
  /// false olduğunda tüm tap animasyonları kapalı olur
  final bool enableTapAnimations;

  /// Global auto close kontrolü
  /// true olduğunda tüm target'lar için auto close aktif olur
  final bool autoClose;

  /// Global auto close timer süresi
  /// autoClose true olduğunda bu süre kadar bekleyip target'ları otomatik kapatır
  final Duration autoCloseTimer;

  @override
  // ignore: no_logic_in_create_state
  AnimatedFocusLightState createState() => pulseEnable
      ? AnimatedPulseFocusLightState()
      : AnimatedStaticFocusLightState();
}

abstract class AnimatedFocusLightState extends State<AnimatedFocusLight>
    with TickerProviderStateMixin {
  final borderRadiusDefault = 10.0;
  final defaultFocusAnimationDuration = Durations.long4;
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;

  late TargetFocus _targetFocus;
  Offset _positioned = Offset.zero;
  TargetPosition? _targetPosition;

  double _sizeCircle = 100;
  int _currentFocus = 0;

  /// Content cycling için current content index
  int _currentContentIndex = 0;

  /// Döngünün tamamlanıp tamamlanmadığını takip eder
  bool _hasCycleCompleted = false;

  /// Auto close timer
  Timer? _autoCloseTimer;

  double _progressAnimated = 0;
  int nextIndex = 0;
  bool _isAnimating = true;

  Future<void> _revertAnimation() async {
    _isAnimating = true;
    _controller.duration = unFocusDuration;
  }

  void _listener(AnimationStatus status);

  Duration get focusDuration =>
      _targetFocus.focusAnimationDuration ??
      widget.focusAnimationDuration ??
      defaultFocusAnimationDuration;

  Duration get unFocusDuration =>
      _targetFocus.unFocusAnimationDuration ??
      widget.unFocusAnimationDuration ??
      _targetFocus.focusAnimationDuration ??
      widget.focusAnimationDuration ??
      defaultFocusAnimationDuration;

  @override
  void initState() {
    super.initState();
    _currentFocus = widget.initialFocus;
    _targetFocus = widget.targets[_currentFocus];
    _controller = AnimationController(
      vsync: this,
      duration: focusDuration,
    )..addStatusListener(_listener);

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    );

    Future.delayed(Duration.zero, _runFocus);
  }

  @override
  void dispose() {
    _cancelAutoCloseTimer();
    _controller.dispose();
    super.dispose();
  }

  void next() => _tapHandler();

  void previous() {
    if (_isAnimating) return;
    nextIndex--;
    _revertAnimation();
  }

  void goTo(int index) {
    if (_isAnimating) return;
    nextIndex = index;
    _revertAnimation();
  }

  /// Auto close timer'ını iptal eder
  void _cancelAutoCloseTimer() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
  }

  /// Auto close timer'ını başlatır
  void _startAutoCloseTimer() {
    if (!_shouldAutoClose()) return;

    _cancelAutoCloseTimer(); // Önceki timer'ı iptal et

    final duration = _getAutoCloseTimer();
    _autoCloseTimer = Timer(duration, () {
      if (mounted && !_isAnimating) {
        // Timer doldu, target'ı otomatik kapat
        nextIndex++;
        _revertAnimation();
      }
    });
  }

  /// Auto close aktif olup olmadığını kontrol eder
  /// Target-level setting global setting'i override eder
  bool _shouldAutoClose() {
    return _targetFocus.autoClose || widget.autoClose;
  }

  /// Auto close timer süresini döndürür
  /// Target-level setting global setting'i override eder
  Duration _getAutoCloseTimer() {
    if (_targetFocus.autoClose) {
      return _targetFocus.autoCloseTimer;
    }
    return widget.autoCloseTimer;
  }

  /// Content cycling için alternatif içerikleri döndürür
  /// Döngü tamamlandığında otomatik kapanma mantığını da yönetir
  void _cycleContent() {
    if (!_targetFocus.enableContentCycling ||
        _targetFocus.alternativeContents == null ||
        _targetFocus.alternativeContents!.isEmpty) {
      return;
    }

    // Timer'ı iptal et çünkü kullanıcı tıkladı
    _cancelAutoCloseTimer();

    final totalAlternatives = _targetFocus.alternativeContents!.length;
    final currentIndex = _currentContentIndex;

    // Döngü tamamlanma kontrolü: Son alternatif content'te iken
    if (currentIndex > 0 && currentIndex >= totalAlternatives) {
      _hasCycleCompleted = true;
      _handleCycleComplete();
      return;
    }

    // Normal döngü: bir sonraki content'e geç
    safeSetState(() {
      _currentContentIndex = currentIndex + 1;
    });

    // Eğer şu anda son alternatif content'teyse, bir sonraki tıklamada cycle complete olacak
    // Bu durumu kontrol et ama henüz complete yapma
    if (_currentContentIndex > totalAlternatives) {
      // Bu duruma normalde girmemeli, ama güvenlik için
      _hasCycleCompleted = true;
      _handleCycleComplete();
      return;
    }

    // Parent widget'a content değişikliğini bildir
    widget.onContentChanged?.call(_targetFocus, _currentContentIndex);

    // Focus callback'ini tekrar çağır ki yeni content görüntülensin
    widget.focus?.call(_targetFocus);

    // Yeni content için timer'ı tekrar başlat
    _startAutoCloseTimer();
  }

  /// Döngü tamamlandığında çağrılır ve uygun aksiyonu alır
  void _handleCycleComplete() {
    // Timer'ı iptal et
    _cancelAutoCloseTimer();

    // Önce cycle complete callback'ini çağır
    widget.onCycleComplete?.call(_targetFocus);

    // Target'ın kendi callback'ini kontrol et
    bool shouldClose = _targetFocus.autoCloseAfterCycle;

    if (_targetFocus.onCycleComplete != null) {
      shouldClose = _targetFocus.onCycleComplete!();
    }

    if (shouldClose) {
      // Target'ı kapat ve bir sonrakine geç
      nextIndex++;
      _revertAnimation();
    } else {
      // Döngüyü sıfırla ve devam ettir
      safeSetState(() {
        _currentContentIndex = 0;
        _hasCycleCompleted = false;
      });
      widget.onContentChanged?.call(_targetFocus, _currentContentIndex);
      widget.focus?.call(_targetFocus);

      // Döngü sıfırlandı, timer'ı tekrar başlat
      _startAutoCloseTimer();
    }
  }

  Future _tapHandler({
    bool targetTap = false,
    bool overlayTap = false,
  }) async {
    if (_isAnimating) return;

    // Timer'ı iptal et çünkü kullanıcı tıkladı
    _cancelAutoCloseTimer();

    // Eğer target tap'ı overlay gibi davranması isteniyor ve content cycling aktifse
    if (targetTap &&
        _targetFocus.enableTargetTabAsOverlay &&
        _targetFocus.enableContentCycling) {
      await widget.clickTarget?.call(_targetFocus);
      _cycleContent();
      return;
    }

    // Eğer overlay'e tıklandı ve content cycling aktifse, içeriği değiştir
    if (overlayTap && _targetFocus.enableContentCycling) {
      await widget.clickOverlay?.call(_targetFocus);
      _cycleContent();
      return;
    }

    // Normal davranış: bir sonraki target'a geç
    nextIndex++;
    if (targetTap) {
      await widget.clickTarget?.call(_targetFocus);
    }
    if (overlayTap) {
      await widget.clickOverlay?.call(_targetFocus);
    }
    return _revertAnimation();
  }

  Future _tapHandlerForPosition(TapDownDetails tapDetails) async {
    if (_isAnimating) return;
    await widget.clickTargetWithTapPosition?.call(_targetFocus, tapDetails);
  }

  Future<void> _runFocus() async {
    if (_currentFocus < 0) return;
    _targetFocus = widget.targets[_currentFocus];

    // Yeni target'a geçerken content index'i ve cycle flag'ini sıfırla
    _currentContentIndex = 0;
    _hasCycleCompleted = false;

    _controller.duration = focusDuration;

    TargetPosition? targetPosition;
    try {
      targetPosition = getTargetCurrent(
        _targetFocus,
        rootOverlay: widget.rootOverlay,
      );
    } on NotFoundTargetException catch (e) {
      debugPrint(e.toString());
      // debugPrintStack(stackTrace: s);
    }

    if (targetPosition == null) {
      _finish();
      return;
    }

    safeSetState(() {
      _targetPosition = targetPosition!;

      _positioned = Offset(
        targetPosition.offset.dx + (targetPosition.size.width / 2),
        targetPosition.offset.dy + (targetPosition.size.height / 2),
      );

      if (targetPosition.size.height > targetPosition.size.width) {
        _sizeCircle = targetPosition.size.height * 0.6 + _getPaddingFocus();
      } else {
        _sizeCircle = targetPosition.size.width * 0.6 + _getPaddingFocus();
      }
    });

    await _controller.forward();
    _isAnimating = false;

    // Target gösterildikten sonra auto close timer'ını başlat
    _startAutoCloseTimer();
  }

  void _goToFocus(int index) {
    if (index >= 0 && index < widget.targets.length) {
      _currentFocus = index;
      _runFocus();
    } else {
      _finish();
    }
  }

  void _finish() {
    _cancelAutoCloseTimer();
    safeSetState(() => _currentFocus = 0);
    widget.finish!();
  }

  Widget _getLightPaint(TargetFocus targetFocus) {
    if (widget.imageFilter != null) {
      return ClipPath(
        clipper: _getClipper(targetFocus.shape),
        child: BackdropFilter(
          filter: widget.imageFilter!,
          child: _getSizedPainter(targetFocus),
        ),
      );
    } else {
      return _getSizedPainter(targetFocus);
    }
  }

  SizedBox _getSizedPainter(TargetFocus targetFocus) {
    return SizedBox(
      width: double.maxFinite,
      height: double.maxFinite,
      child: CustomPaint(
        painter: _getPainter(targetFocus),
      ),
    );
  }

  CustomClipper<Path> _getClipper(ShapeLightFocus? shape) {
    return shape == ShapeLightFocus.RRect
        ? RectClipper(
            progress: _progressAnimated,
            offset: _getPaddingFocus(),
            target: _targetPosition ?? TargetPosition(Size.zero, Offset.zero),
            radius: _targetFocus.radius ?? 0,
            borderSide: _targetFocus.borderSide,
          )
        : CircleClipper(
            _progressAnimated,
            _positioned,
            _sizeCircle,
            _targetFocus.borderSide,
          );
  }

  CustomPainter _getPainter(TargetFocus target) {
    if (target.shape == ShapeLightFocus.RRect) {
      return LightPaintRect(
        colorShadow: target.color ?? widget.colorShadow,
        progress: _progressAnimated,
        offset: _getPaddingFocus(),
        target: _targetPosition ?? TargetPosition(Size.zero, Offset.zero),
        radius: target.radius ?? 0,
        borderSide: target.borderSide,
        opacityShadow: widget.opacityShadow,
      );
    } else {
      return LightPaint(
        _progressAnimated,
        _positioned,
        _sizeCircle,
        colorShadow: target.color ?? widget.colorShadow,
        borderSide: target.borderSide,
        opacityShadow: widget.opacityShadow,
      );
    }
  }

  double _getPaddingFocus() {
    return _targetFocus.paddingFocus ?? (widget.paddingFocus);
  }

  BorderRadius _betBorderRadiusTarget() {
    double radius = _targetFocus.shape == ShapeLightFocus.Circle
        ? _targetPosition?.size.width ?? borderRadiusDefault
        : _targetFocus.radius ?? borderRadiusDefault;
    return BorderRadius.circular(radius);
  }

  void _onTargetTap() {
    if (!_targetFocus.enableTargetTab) return;
    _tapHandler(targetTap: true);
  }

  /// Mevcut content index'ini döndürür (content cycling için)
  int get currentContentIndex => _currentContentIndex;

  /// Döngünün tamamlanıp tamamlanmadığını döndürür
  bool get hasCycleCompleted => _hasCycleCompleted;

  /// Tıklama animasyonlarının aktif olup olmadığını kontrol eder
  /// Target-level setting global setting'i override edebilir
  bool _shouldShowTapAnimations() {
    // Target-level setting öncelikli, sonra global setting
    return _targetFocus.enableTapAnimations || widget.enableTapAnimations;
  }

  /// Splash color'u animate olup olmamasına göre döndürür
  Color? _getSplashColor() {
    return _shouldShowTapAnimations() ? null : Colors.transparent;
  }

  /// Highlight color'u animate olup olmamasına göre döndürür
  Color? _getHighlightColor() {
    return _shouldShowTapAnimations() ? null : Colors.transparent;
  }
}

class AnimatedStaticFocusLightState extends AnimatedFocusLightState {
  double get left => (_targetPosition?.offset.dx ?? 0) - _getPaddingFocus() * 2;

  double get top => (_targetPosition?.offset.dy ?? 0) - _getPaddingFocus() * 2;

  double get width {
    return (_targetPosition?.size.width ?? 0) + _getPaddingFocus() * 4;
  }

  double get height {
    return (_targetPosition?.size.height ?? 0) + _getPaddingFocus() * 4;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.backgroundSemanticLabel,
      button: true,
      child: InkWell(
        excludeFromSemantics: true,
        splashColor: _getSplashColor(), // Dynamic splash control
        highlightColor: _getHighlightColor(), // Dynamic highlight control
        onTap: _targetFocus.enableOverlayTab
            ? () => _tapHandler(overlayTap: true)
            : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            _progressAnimated = _curvedAnimation.value;
            return Stack(
              children: <Widget>[
                _getLightPaint(_targetFocus),
                Positioned(
                  left: left,
                  top: top,
                  child: InkWell(
                    borderRadius: _betBorderRadiusTarget(),
                    splashColor: _getSplashColor(), // Dynamic splash control
                    highlightColor:
                        _getHighlightColor(), // Dynamic highlight control
                    onTapDown: _tapHandlerForPosition,
                    onTap: _onTargetTap,
                    child: Container(
                      color: Colors.transparent,
                      width: width,
                      height: height,
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Future<void> _revertAnimation() async {
    await super._revertAnimation();
    return _controller.reverse();
  }

  @override
  void _listener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.focus?.call(_targetFocus);
    }
    if (status == AnimationStatus.dismissed) {
      _goToFocus(nextIndex);
    }

    if (status == AnimationStatus.reverse) {
      widget.removeFocus?.call();
    }
  }
}

class AnimatedPulseFocusLightState extends AnimatedFocusLightState {
  final defaultPulseAnimationDuration = const Duration(milliseconds: 500);
  final defaultPulseVariation = Tween(begin: 1.0, end: 0.99);
  late AnimationController _controllerPulse;
  late Animation _tweenPulse;

  bool _finishFocus = false;
  bool _initReverse = false;

  get left => (_targetPosition?.offset.dx ?? 0) - _getPaddingFocus() * 2;

  get top => (_targetPosition?.offset.dy ?? 0) - _getPaddingFocus() * 2;

  get width => (_targetPosition?.size.width ?? 0) + _getPaddingFocus() * 4;

  get height => (_targetPosition?.size.height ?? 0) + _getPaddingFocus() * 4;

  @override
  void initState() {
    super.initState();
    _controllerPulse = AnimationController(
      vsync: this,
      duration: widget.pulseAnimationDuration ?? defaultPulseAnimationDuration,
    );

    _tweenPulse = _createTweenAnimation(
      _targetFocus.pulseVariation ??
          widget.pulseVariation ??
          defaultPulseVariation,
    );

    _controllerPulse.addStatusListener(_listenerPulse);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.backgroundSemanticLabel,
      button: true,
      child: InkWell(
        excludeFromSemantics: true,
        splashColor: _getSplashColor(), // Dynamic splash control
        highlightColor: _getHighlightColor(), // Dynamic highlight control
        onTap: _targetFocus.enableOverlayTab
            ? () => _tapHandler(overlayTap: true)
            : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            _progressAnimated = _curvedAnimation.value;
            return AnimatedBuilder(
              animation: _controllerPulse,
              builder: (_, child) {
                if (_finishFocus) {
                  _progressAnimated = _tweenPulse.value;
                }
                return Stack(
                  children: <Widget>[
                    _getLightPaint(_targetFocus),
                    Positioned(
                      left: left,
                      top: top,
                      child: InkWell(
                        borderRadius: _betBorderRadiusTarget(),
                        splashColor:
                            _getSplashColor(), // Dynamic splash control
                        highlightColor:
                            _getHighlightColor(), // Dynamic highlight control
                        onTap: _onTargetTap,
                        onTapDown: _tapHandlerForPosition,
                        child: Container(
                          color: Colors.transparent,
                          width: width,
                          height: height,
                        ),
                      ),
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Future<void> _runFocus() {
    _tweenPulse = _createTweenAnimation(
      _targetFocus.pulseVariation ??
          widget.pulseVariation ??
          defaultPulseVariation,
    );
    _finishFocus = false;
    return super._runFocus();
  }

  @override
  Future<void> _revertAnimation() async {
    await super._revertAnimation();
    _initReverse = true;
    return _controllerPulse.reverse(from: _controllerPulse.value);
  }

  @override
  void dispose() {
    _controllerPulse.dispose();
    super.dispose();
  }

  @override
  void _listener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      safeSetState(() => _finishFocus = true);

      widget.focus?.call(_targetFocus);

      _controllerPulse.forward();
    }
    if (status == AnimationStatus.dismissed) {
      _finishFocus = false;
      _initReverse = false;
      _goToFocus(nextIndex);
    }

    if (status == AnimationStatus.reverse) {
      widget.removeFocus?.call();
    }
  }

  void _listenerPulse(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controllerPulse.reverse();
    }

    if (status == AnimationStatus.dismissed) {
      if (_initReverse) {
        safeSetState(() => _finishFocus = false);
        _controller.reverse();
      } else if (_finishFocus) {
        _controllerPulse.forward();
      }
    }
  }

  Animation _createTweenAnimation(Tween<double> tween) {
    return tween.animate(
      CurvedAnimation(parent: _controllerPulse, curve: Curves.ease),
    );
  }
}
