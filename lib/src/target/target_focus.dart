import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/src/target/target_content.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';
import 'package:tutorial_coach_mark/src/util.dart';

/// Tek bir tutorial target'ının tanımlandığı sınıf
/// Overlay'e tıklandığında farklı içerikler arasında geçiş yapabilir
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
    this.enableContentCycling = false,
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

  /// true olduğunda overlay'e tıklama target'ı kapatmak yerine içeriği değiştirir
  final bool enableContentCycling;

  final Color? color;
  final AlignmentGeometry? alignSkip;
  final double? paddingFocus;
  final Duration? focusAnimationDuration;
  final Duration? unFocusAnimationDuration;
  final Tween<double>? pulseVariation;

  @override
  String toString() {
    return 'TargetFocus{identify: $identify, keyTarget: $keyTarget, targetPosition: $targetPosition, contents: $contents, alternativeContents: $alternativeContents, enableContentCycling: $enableContentCycling, shape: $shape}';
  }
}
