import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/src/target/target_content.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';
import 'package:tutorial_coach_mark/src/util.dart';

/// Tek bir tutorial target'ının tanımlandığı sınıf
/// Overlay'e tıklandığında farklı içerikler arasında geçiş yapabilir
/// Döngü tamamlandığında otomatik kapanma özelliği mevcuttur
class TargetFocus {
  TargetFocus({
    this.identify,
    this.keyTarget,
    this.targetPosition,
    this.contents,
    this.alternativeContents,
    this.shape,
    this.radius,
    this.borderSide,
    this.color,
    this.enableOverlayTab = false,
    this.enableTargetTab = true,
    this.enableTargetTabAsOverlay = false,
    this.enableContentCycling = false,
    this.autoCloseAfterCycle = false,
    this.onCycleComplete,
    this.alignSkip,
    this.paddingFocus,
    this.focusAnimationDuration,
    this.unFocusAnimationDuration,
    this.pulseVariation,
  }) : assert(keyTarget != null || targetPosition != null);

  final dynamic identify;
  final GlobalKey? keyTarget;
  final TargetPosition? targetPosition;
  final List<TargetContent>? contents;

  /// Overlay'e tıklandığında gösterilecek alternatif içerikler
  /// enableContentCycling true olduğunda kullanılır
  final List<List<TargetContent>>? alternativeContents;

  final ShapeLightFocus? shape;
  final double? radius;
  final BorderSide? borderSide;
  final bool enableOverlayTab;
  final bool enableTargetTab;

  /// true olduğunda target'a tıklama da overlay'e tıklama gibi davranır
  /// enableContentCycling true olduğunda content cycling için kullanılabilir
  final bool enableTargetTabAsOverlay;

  /// true olduğunda overlay'e tıklama target'ı kapatmak yerine içeriği değiştirir
  final bool enableContentCycling;

  /// true olduğunda alternative content döngüsü bitince target otomatik kapanır
  /// enableContentCycling true olduğunda çalışır
  final bool autoCloseAfterCycle;

  /// Alternative content döngüsü bittiğinde çağrılır
  /// return true: target'ı kapat, return false: target'ı açık tut
  /// null ise autoCloseAfterCycle parametresine göre davranır
  final bool Function()? onCycleComplete;

  final Color? color;
  final AlignmentGeometry? alignSkip;
  final double? paddingFocus;
  final Duration? focusAnimationDuration;
  final Duration? unFocusAnimationDuration;
  final Tween<double>? pulseVariation;

  @override
  String toString() {
    return 'TargetFocus{identify: $identify, keyTarget: $keyTarget, targetPosition: $targetPosition, contents: $contents, alternativeContents: $alternativeContents, enableContentCycling: $enableContentCycling, enableTargetTabAsOverlay: $enableTargetTabAsOverlay, autoCloseAfterCycle: $autoCloseAfterCycle, shape: $shape}';
  }
}
