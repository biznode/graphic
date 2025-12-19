import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/dataflow/operator.dart';

import 'event.dart';

/// Types of [Gesture]s.
///
/// A chart can responses to gesture types the same as [GestureDetector], except
/// that pan series, horizontal drag series and vertical drag series are uniformed
/// into scale series.
///
/// Besides, a [hover] type and a [scroll] type is defined for mouse interactions.
///
/// See also:
///
/// - [GestureDetector], which detects gestures.
/// - [Listener], which responses to common pointer events that compose [hover]
/// and [scroll] gestures.
enum GestureType {
  /// Triggered when a mouse pointer has entered this chart.
  ///
  /// This is triggered when the pointer, with or without buttons
  /// pressed, has started to be contained by the region of this chart. More
  /// specifically, this is triggered by the following cases:
  ///
  ///  * This chart has appeared under a pointer.
  ///  * This chart has moved to under a pointer.
  ///  * A new pointer has been added to somewhere within this chart.
  ///  * An existing pointer has moved into this chart.
  ///
  /// This is not always matched by an [mouseExit]. If the [Chart]
  /// is unmounted while being hovered by a pointer, the [mouseExit] of the chart
  /// will not be emitted. For more details, see [mouseEnter].
  ///
  /// A gesture of this type has no details.
  mouseEnter,

  /// Triggered when a mouse pointer has exited this chart when the chart is
  /// still mounted.
  ///
  /// This is triggered when the pointer, with or without buttons
  /// pressed, has stopped being contained by the region of this chart, except
  /// when the exit is caused by the disappearance of this chart. More
  /// specifically, this is triggered by the following cases:
  ///
  ///  * A pointer that is hovering this chart has moved away.
  ///  * A pointer that is hovering this chart has been removed.
  ///  * This chart, which is being hovered by a pointer, has moved away.
  ///
  /// And is __not__ triggered by the following case:
  ///
  ///  * This chart, which is being hovered by a pointer, has disappeared.
  ///
  /// This means that a [mouseExit] might not be matched by a
  /// [mouseEnter].
  ///
  /// A gesture of this type has no details.
  mouseExit,

  /// A tap with a primary button has occurred.
  ///
  /// This triggers when the tap gesture wins. If the tap gesture did not win,
  /// [tapCancel] is emitted instead.
  ///
  /// A gesture of this type has no detail.
  tap,

  /// The pointer that previously triggered [tapDown] will not end up causing
  /// a tap.
  ///
  /// This is emitted after [tapDown], and instead of [tapUp] and [tap], if
  /// the tap gesture did not win.
  ///
  /// A gesture of this type has no detail.
  tapCancel,

  /// A pointer that might cause a tap with a primary button has contacted the
  /// screen at a particular location.
  ///
  /// This is emitted after a short timeout, even if the winning gesture has not
  /// yet been selected. If the tap gesture wins, [tapUp] will be emitted,
  /// otherwise [tapCancel] will be emitted.
  ///
  /// A gesture of this type has details of [TapDownDetails].
  tapDown,

  /// A pointer that will trigger a tap with a primary button has stopped
  /// contacting the screen at a particular location.
  ///
  /// This triggers immediately before [tap] in the case of the tap gesture
  /// winning. If the tap gesture did not win, [tapCancel] is emitted instead.
  ///
  /// A gesture of this type has details of [TapUpDetails].
  tapUp,

  /// The user has tapped the screen with a primary button at the same location
  /// twice in quick succession.
  ///
  /// A gesture of this type has no detail.
  doubleTap,

  /// The pointers in contact with the screen have indicated a new focal point
  /// and/or scale.
  ///
  /// A gesture of this type has details of [ScaleUpdateDetails].
  scaleUpdate,

  /// A pointer has been drag-moved after a long-press with a primary button.
  ///
  /// A gesture of this type has details of [LongPressMoveUpdateDetails].
  longPressMoveUpdate,

  /// Emitted when a pointer that has not triggered an [tapDown] changes position.
  ///
  /// This is only fired for pointers which report their location when not down
  /// (e.g. mouse pointers, but not most touch pointers).
  ///
  /// A gesture of this type has no details.
  hover,

  /// The pointer issued a scroll gesture.
  ///
  /// Scrolling the scroll wheel on a mouse is an example that would emit a scroll
  /// gesture.
  ///
  /// A gesture of this type has details of [Offset], which is [PointerScrollEvent.scrollDelta].
  scroll,
}

/// Information about a gesture.
///
/// A gesture is triggered by pointer events, including touch, stylus, or mouse.
/// Gesture types are refering to [GestureDetector] (See details in [GestureType]).
///
/// This is carried as payload by [GestureEvent].
///
/// See also:
///
/// - [GestureEvent], which event carries gesture as payload.
class Gesture {
  /// Creates a gesture.
  Gesture(
    this.type,
    this.device,
    this.localPosition,
    this.chartSize,
    this.details, {
    this.chartKey,
    this.localMoveStart,
    this.preScaleDetail,
  });

  /// The gesture type.
  final GestureType type;

  /// the kind of device that triggers the pointer event.
  final PointerDeviceKind device;

  /// The local position of the pointer event that triggers this gesture.
  final Offset localPosition;

  /// The current size of the chart.
  ///
  /// It is usefull when calculating movement length ratios.
  final Size chartSize;

  /// Details about this gesture.
  ///
  /// They may be different class types or null according to [type] (See corresponding
  /// relations in [GestureType]).
  final dynamic details;

  /// The key of the emitting chart.
  ///
  /// This is mainly used to know where a gesture originated from when multiple
  /// charts share a gesture stream.
  ///
  /// The key may be null, e.g. if the gesture is manually created.
  final Key? chartKey;

  /// The local position of pointer when a scale or long press starts.
  ///
  /// The update and end events of scale and long presses have this propertiy. It
  /// is usefull when calculating movement spans.
  final Offset? localMoveStart;

  // By hacking the scale start, Scale update always has it.

  /// Details of previous scale update.
  ///
  /// It is usefull to calculate delta position between scale updates, because
  /// [ScaleUpdateDetails.delta] is form the start instead of the previous one.
  ///
  /// Scale update gesture will always has this property, even the first update
  /// (It regards the scale start as the previous update.).
  final ScaleUpdateDetails? preScaleDetail;
}

/// The event emitted when a gesture occurs.
class GestureEvent extends Event {
  /// Creates a gesture event.
  GestureEvent(this.gesture);

  @override
  EventType get type => EventType.gesture;

  /// Informations about the gesture.
  final Gesture gesture;
}

/// The gesture operator.
class GestureOp extends Operator<Gesture?> {
  GestureOp(
    Map<String, dynamic> params,
  ) : super(params);

  @override
  bool get runInit => false;

  @override
  Gesture? evaluate() {
    final event = params['event'] as GestureEvent;
    return event.gesture;
  }
}
