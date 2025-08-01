import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/target/target_content.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';
import 'package:tutorial_coach_mark/src/util.dart';
import 'package:tutorial_coach_mark/src/widgets/animated_focus_light.dart';

/// Ana tutorial coach mark widget'ı
/// Content cycling özelliği ile overlay'e tıklandığında farklı içerikler gösterebilir
/// Döngü tamamlandığında otomatik kapanma özelliği mevcuttur
/// Belirli süre sonra otomatik kapanma özelliği mevcuttur
class TutorialCoachMarkWidget extends StatefulWidget {
  const TutorialCoachMarkWidget({
    Key? key,
    required this.targets,
    this.finish,
    this.paddingFocus = 10,
    this.clickTarget,
    this.onClickTargetWithTapPosition,
    this.clickOverlay,
    this.onCycleComplete,
    this.alignSkip = Alignment.bottomRight,
    this.textSkip = "SKIP",
    this.onClickSkip,
    this.skipWidget,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.textStyleSkip = const TextStyle(color: Colors.white),
    this.hideSkip = false,
    this.useSafeArea = true,
    this.focusAnimationDuration,
    this.unFocusAnimationDuration,
    this.pulseAnimationDuration,
    this.pulseVariation,
    this.pulseEnable = true,
    this.rootOverlay = false,
    this.showSkipInLastTarget = false,
    this.imageFilter,
    this.backgroundSemanticLabel,
    this.initialFocus = 0,
    this.enableTapAnimations = false,
    this.autoClose = false,
    this.autoCloseTimer = const Duration(seconds: 3),
  })  : assert(targets.length > 0),
        super(key: key);

  final List<TargetFocus> targets;
  final FutureOr Function(TargetFocus)? clickTarget;
  final FutureOr Function(TargetFocus, TapDownDetails)?
      onClickTargetWithTapPosition;
  final FutureOr Function(TargetFocus)? clickOverlay;

  /// Content cycling döngüsü tamamlandığında çağrılır
  final FutureOr Function(TargetFocus)? onCycleComplete;

  final void Function()? finish;
  final Color colorShadow;
  final double opacityShadow;
  final double paddingFocus;
  final void Function()? onClickSkip;
  final AlignmentGeometry alignSkip;
  final String textSkip;
  final TextStyle textStyleSkip;
  final bool hideSkip;
  final bool useSafeArea;
  final Duration? focusAnimationDuration;
  final Duration? unFocusAnimationDuration;
  final Duration? pulseAnimationDuration;
  final Tween<double>? pulseVariation;
  final bool pulseEnable;
  final Widget? skipWidget;
  final bool rootOverlay;
  final bool showSkipInLastTarget;
  final ImageFilter? imageFilter;
  final int initialFocus;
  final String? backgroundSemanticLabel;

  /// Global tıklama animasyonları kontrolü
  final bool enableTapAnimations;

  /// Global auto close kontrolü
  final bool autoClose;

  /// Global auto close timer süresi
  final Duration autoCloseTimer;

  @override
  TutorialCoachMarkWidgetState createState() => TutorialCoachMarkWidgetState();
}

class TutorialCoachMarkWidgetState extends State<TutorialCoachMarkWidget>
    implements TutorialCoachMarkController {
  final GlobalKey<AnimatedFocusLightState> _focusLightKey = GlobalKey();
  bool showContent = false;
  TargetFocus? currentTarget;

  /// Content cycling için mevcut content index
  int _currentContentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          AnimatedFocusLight(
            key: _focusLightKey,
            initialFocus: widget.initialFocus,
            targets: widget.targets,
            finish: widget.finish,
            paddingFocus: widget.paddingFocus,
            colorShadow: widget.colorShadow,
            opacityShadow: widget.opacityShadow,
            focusAnimationDuration: widget.focusAnimationDuration,
            unFocusAnimationDuration: widget.unFocusAnimationDuration,
            pulseAnimationDuration: widget.pulseAnimationDuration,
            pulseVariation: widget.pulseVariation,
            pulseEnable: widget.pulseEnable,
            rootOverlay: widget.rootOverlay,
            imageFilter: widget.imageFilter,
            backgroundSemanticLabel: widget.backgroundSemanticLabel,
            enableTapAnimations: widget.enableTapAnimations,
            autoClose: widget.autoClose,
            autoCloseTimer: widget.autoCloseTimer,
            clickTarget: (target) {
              return widget.clickTarget?.call(target);
            },
            clickTargetWithTapPosition: (target, tapDetails) {
              return widget.onClickTargetWithTapPosition
                  ?.call(target, tapDetails);
            },
            clickOverlay: (target) {
              return widget.clickOverlay?.call(target);
            },
            onContentChanged: (target, contentIndex) {
              // Content cycling sırasında content index'i güncelle
              setState(() {
                _currentContentIndex = contentIndex;
              });
            },
            onCycleComplete: (target) {
              // Cycle complete callback'ini client'a ilet
              return widget.onCycleComplete?.call(target);
            },
            focus: (target) {
              setState(() {
                currentTarget = target;
                showContent = true;
              });
            },
            removeFocus: () {
              setState(() {
                showContent = false;
                _currentContentIndex = 0; // Content index'i sıfırla
              });
            },
          ),
          AnimatedOpacity(
            opacity: showContent ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: _buildContents(),
          ),
          _buildSkip()
        ],
      ),
    );
  }

  /// Content cycling'e göre doğru içeriği döndürür
  List<TargetContent>? _getCurrentContents() {
    if (currentTarget == null) return null;

    // Content cycling aktif değilse normal içeriği döndür
    if (!currentTarget!.enableContentCycling) {
      return currentTarget!.contents;
    }

    // Content cycling aktifse index'e göre içerik döndür
    if (_currentContentIndex == 0) {
      return currentTarget!.contents;
    } else if (currentTarget!.alternativeContents != null &&
        _currentContentIndex <= currentTarget!.alternativeContents!.length) {
      return currentTarget!.alternativeContents![_currentContentIndex - 1];
    }

    // Fallback olarak normal içeriği döndür
    return currentTarget!.contents;
  }

  Widget _buildContents() {
    if (currentTarget == null) {
      return const SizedBox.shrink();
    }

    // Content cycling'e göre doğru içeriği al
    final currentContents = _getCurrentContents();
    if (currentContents == null || currentContents.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> children = <Widget>[];

    TargetPosition? target;
    try {
      target = getTargetCurrent(
        currentTarget!,
        rootOverlay: widget.rootOverlay,
      );
    } on NotFoundTargetException catch (e) {
      skip();

      ///error tutorial exit
      debugPrint("  error>>>>> e ${e.toString()}");
      //debugPrintStack(stackTrace: s);
    }

    if (target == null) {
      return const SizedBox.shrink();
    }

    if (target.offset.dx.isNaN || target.offset.dy.isNaN) {
      return const SizedBox.shrink();
    }

    var positioned = Offset(
      target.offset.dx + target.size.width / 2,
      target.offset.dy + target.size.height / 2,
    );

    double haloWidth;
    double haloHeight;

    if (currentTarget!.shape == ShapeLightFocus.Circle) {
      haloWidth = target.size.width > target.size.height
          ? target.size.width
          : target.size.height;
      haloHeight = haloWidth;
    } else {
      haloWidth = target.size.width;
      haloHeight = target.size.height;
    }

    haloWidth = haloWidth * 0.6 + widget.paddingFocus;
    haloHeight = haloHeight * 0.6 + widget.paddingFocus;

    double width = 0.0;
    double? top;
    double? bottom;
    double? left;
    double? right;

    final ancestorBox = context.findRenderObject() as RenderBox;

    // Mevcut content'leri kullan (cycling'e göre değişebilir)
    children = currentContents.map<Widget>((i) {
      switch (i.align) {
        case ContentAlign.bottom:
          {
            width = ancestorBox.size.width;
            left = 0;
            top = positioned.dy + haloHeight;
            bottom = null;
          }
          break;
        case ContentAlign.top:
          {
            width = ancestorBox.size.width;
            left = 0;
            top = null;
            bottom = haloHeight + (ancestorBox.size.height - positioned.dy);
          }
          break;
        case ContentAlign.left:
          {
            width = positioned.dx - haloWidth;
            left = 0;
            top = positioned.dy - target!.size.height / 2 - haloHeight;
            bottom = null;
          }
          break;
        case ContentAlign.right:
          {
            left = positioned.dx + haloWidth;
            top = positioned.dy - target!.size.height / 2 - haloHeight;
            bottom = null;
            width = ancestorBox.size.width - left!;
          }
          break;
        case ContentAlign.custom:
          {
            left = i.customPosition!.left;
            right = i.customPosition!.right;
            top = i.customPosition!.top;
            bottom = i.customPosition!.bottom;
            width = ancestorBox.size.width;
          }
          break;
      }

      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: SizedBox(
          width: width,
          child: Padding(
            padding: i.padding,
            child: i.builder?.call(context, this) ??
                (i.child ?? const SizedBox.shrink()),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: children,
    );
  }

  Widget _buildSkip() {
    bool isLastTarget = false;

    if (widget.hideSkip) {
      return const SizedBox.shrink();
    }

    if (currentTarget != null) {
      final targetIndex = widget.targets.indexOf(currentTarget!);
      isLastTarget = targetIndex == widget.targets.length - 1;
    }

    if (isLastTarget && !widget.showSkipInLastTarget) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: currentTarget?.alignSkip ?? widget.alignSkip,
      child: SafeArea(
        bottom: widget.useSafeArea ? true : false,
        top: widget.useSafeArea ? true : false,
        left: widget.useSafeArea ? true : false,
        right: widget.useSafeArea ? true : false,
        child: AnimatedOpacity(
          opacity: showContent ? 1 : 0,
          duration: Durations.medium2,
          child: widget.skipWidget ??
              InkWell(
                onTap: skip,
                child: IgnorePointer(
                  child: widget.skipWidget ??
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          widget.textSkip,
                          style: widget.textStyleSkip,
                        ),
                      ),
                ),
              ),
        ),
      ),
    );
  }

  @override
  void skip() => widget.onClickSkip?.call();

  @override
  void next() => _focusLightKey.currentState?.next();

  @override
  void previous() => _focusLightKey.currentState?.previous();

  void goTo(int index) => _focusLightKey.currentState?.goTo(index);

  /// Mevcut content index'ini döndürür (content cycling için)
  int get currentContentIndex => _currentContentIndex;

  /// Döngünün tamamlanıp tamamlanmadığını döndürür
  bool get hasCycleCompleted =>
      _focusLightKey.currentState?.hasCycleCompleted ?? false;
}
