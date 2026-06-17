import 'dart:async';
import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';

/// Local replacement for PageFlipWidget that defers hit-testing to children
/// so interactive widgets inside pages receive taps immediately.
class MyPageFlipWidget extends StatefulWidget {
  final PageFlipController? controller;
  const MyPageFlipWidget({
    super.key,
    this.duration = const Duration(milliseconds: 450),
    this.cutoffForward = 0.8,
    this.cutoffPrevious = 0.1,
    this.backgroundColor = Colors.white,
    required this.children,
    this.initialIndex = 0,
    this.lastPage,
    this.isRightSwipe = false,
    this.onPageFlipped,
    this.onFlipStart,
    this.controller,
  })  : assert(initialIndex < children.length,
            'initialIndex cannot be greater than children length');

  final Color backgroundColor;
  final List<Widget> children;
  final Duration duration;
  final int initialIndex;
  final Widget? lastPage;
  final double cutoffForward;
  final double cutoffPrevious;
  final bool isRightSwipe;
  final void Function(int pageNumber)? onPageFlipped;
  final void Function()? onFlipStart;

  @override
  MyPageFlipWidgetState createState() => MyPageFlipWidgetState();
}

class MyPageFlipWidgetState extends State<MyPageFlipWidget>
    with TickerProviderStateMixin {
  int pageNumber = 0;
  List<Widget> pages = [];
  final List<AnimationController> _controllers = [];
  bool? _isForward;

  @override
  void didUpdateWidget(MyPageFlipWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize global variables (defined in page_flip.dart)
    imageData = {};
    currentPage = ValueNotifier(-1);
    currentWidget = ValueNotifier(Container());
    currentPageIndex = ValueNotifier(0);
    // Note: cannot assign to PageFlipController._state (private in package).
    // We intentionally do not set it here; the widget is controlled via the
    // returned `MyPageFlipWidgetState` when used with a `GlobalKey`.
    _setUp();
  }

  void _setUp({bool isRefresh = false}) {
    _controllers.clear();
    pages.clear();
    if (widget.lastPage != null) {
      widget.children.add(widget.lastPage!);
    }
    for (var i = 0; i < widget.children.length; i++) {
      final controller = AnimationController(
        value: 1,
        duration: widget.duration,
        vsync: this,
      );
      _controllers.add(controller);
      final child = PageFlipBuilder(
        amount: controller,
        backgroundColor: widget.backgroundColor,
        isRightSwipe: widget.isRightSwipe,
        pageIndex: i,
        key: Key('item$i'),
        child: widget.children[i],
      );
      pages.add(child);
    }
    pages = pages.reversed.toList();
    if (isRefresh) {
      goToPage(pageNumber);
    } else {
      pageNumber = widget.initialIndex;
      lastPageLoad = pages.length < 3 ? 0 : 3;
    }
    if (widget.initialIndex != 0) {
      currentPage = ValueNotifier(widget.initialIndex);
      currentWidget = ValueNotifier(pages[pageNumber]);
      currentPageIndex = ValueNotifier(widget.initialIndex);
    }
  }

  bool get _isLastPage => (pages.length - 1) == pageNumber;
  int lastPageLoad = 0;
  bool get _isFirstPage => pageNumber == 0;

  void _turnPage(DragUpdateDetails details, BoxConstraints dimens) {
    currentPage.value = pageNumber;
    currentWidget.value = Container();
    final ratio = details.delta.dx / dimens.maxWidth;
    if (_isForward == null) {
      if (widget.isRightSwipe
          ? details.delta.dx < 0.0
          : details.delta.dx > 0.0) {
        _isForward = false;
      } else if (widget.isRightSwipe
          ? details.delta.dx > 0.2
          : details.delta.dx < -0.2) {
        _isForward = true;
      } else {
        _isForward = null;
      }
    }
    if (_isForward == true || pageNumber == 0) {
      final pageLength = pages.length;
      final pageSize = widget.lastPage != null ? pageLength : pageLength - 1;
      if (pageNumber != pageSize && !_isLastPage) {
        widget.isRightSwipe
            ? _controllers[pageNumber].value -= ratio
            : _controllers[pageNumber].value += ratio;
      }
    }
  }

  Future _onDragFinish() async {
    if (_isForward != null) {
      if (_isForward == true) {
        if (!_isLastPage &&
            _controllers[pageNumber].value <= (widget.cutoffForward + 0.15)) {
          await nextPage();
        } else {
          if (!_isLastPage) {
            await _controllers[pageNumber].forward();
          }
        }
      } else {
        if (!_isFirstPage &&
            _controllers[pageNumber - 1].value >= widget.cutoffPrevious) {
          await previousPage();
        } else {
          if (_isFirstPage) {
            await _controllers[pageNumber].forward();
          } else {
            await _controllers[pageNumber - 1].reverse();
            if (!_isFirstPage) {
              await previousPage();
            }
          }
        }
      }
    }
    _isForward = null;
    currentPage.value = -1;
  }

  Future nextPage() async {
    if (_isLastPage) return;
    widget.onFlipStart?.call();
    currentPage.value = pageNumber;
    await _controllers[pageNumber].reverse();
    if (mounted) {
      setState(() {
        pageNumber++;
      });
      if (pageNumber < pages.length) {
        currentPageIndex.value = pageNumber;
        currentWidget.value = pages[pageNumber];
      }
      if (_isLastPage) {
        currentPageIndex.value = pageNumber;
        currentWidget.value = pages[pageNumber];
      }
      widget.onPageFlipped?.call(pageNumber);
    }
    currentPage.value = -1;
  }

  Future previousPage() async {
    if (_isFirstPage) return;
    widget.onFlipStart?.call();
    currentPage.value = pageNumber - 1;
    await _controllers[pageNumber - 1].forward();
    if (mounted) {
      setState(() {
        pageNumber--;
      });
      currentPageIndex.value = pageNumber;
      currentWidget.value = pages[pageNumber];
      imageData[pageNumber] = null;
      widget.onPageFlipped?.call(pageNumber);
    }
    currentPage.value = -1;
  }

  Future goToPage(int index) async {
    if (mounted) {
      setState(() {
        pageNumber = index;
      });
    }
    for (var i = 0; i < _controllers.length; i++) {
      if (i == index) {
        _controllers[i].forward();
      } else if (i < index) {
        _controllers[i].reverse();
      } else {
        if (_controllers[i].status == AnimationStatus.reverse) {
          _controllers[i].value = 1;
        }
      }
    }
    currentPageIndex.value = pageNumber;
    currentWidget.value = pages[pageNumber];
    currentPage.value = pageNumber;
    currentPage.value = -1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, dimens) => GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onHorizontalDragCancel: () => _isForward = null,
        onHorizontalDragUpdate: (details) => _turnPage(details, dimens),
        onHorizontalDragEnd: (details) => _onDragFinish(),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (widget.lastPage != null) ...[
              widget.lastPage!,
            ],
            if (pages.isNotEmpty) ...pages else const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class MyPageFlipController {
  MyPageFlipWidgetState? _state;

  void nextPage() {
    _state?.nextPage();
  }

  void previousPage() {
    _state?.previousPage();
  }

  void goToPage(int index) {
    _state?.goToPage(index);
  }
}
