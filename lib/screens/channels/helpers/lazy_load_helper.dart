import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
///  مساعد التحميل الكسول للقوائم
/// ═══════════════════════════════════════════════════════════════
class LazyLoadHelper {
  final ScrollController scrollController;
  final VoidCallback onLoadMore;
  final double threshold;
  bool _isLoading = false;
  bool _hasMore = true;

  LazyLoadHelper({
    required this.scrollController,
    required this.onLoadMore,
    this.threshold = 0.8,
  }) {
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isLoading || !_hasMore) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    if (currentScroll >= maxScroll * threshold) {
      _isLoading = true;
      onLoadMore();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void setHasMore(bool hasMore) {
    _hasMore = hasMore;
  }

  void dispose() {
    scrollController.removeListener(_onScroll);
  }
}

/// ═══════════════════════════════════════════════════════════════
///  ويدجت قائمة كسولة محسّنة
/// ═══════════════════════════════════════════════════════════════
class OptimizedLazyList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function()? onLoadMore;
  final bool isLoading;
  final bool hasMore;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final EdgeInsets? padding;
  final double? itemExtent;
  final Widget Function(BuildContext, int)? separatorBuilder;

  const OptimizedLazyList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.isLoading = false,
    this.hasMore = true,
    this.loadingWidget,
    this.emptyWidget,
    this.padding,
    this.itemExtent,
    this.separatorBuilder,
  });

  @override
  State<OptimizedLazyList<T>> createState() => _OptimizedLazyListState<T>();
}

class _OptimizedLazyListState<T> extends State<OptimizedLazyList<T>> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onLoadMore == null || widget.isLoading || !widget.hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.8) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    final itemCount = widget.items.length + (widget.isLoading ? 1 : 0);

    // استخدام ListView.builder للأداء الأفضل
    if (widget.separatorBuilder != null) {
      return ListView.separated(
        controller: _scrollController,
        padding: widget.padding,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: itemCount,
        separatorBuilder: widget.separatorBuilder!,
        itemBuilder: (context, index) {
          if (index == widget.items.length) {
            return widget.loadingWidget ?? _defaultLoadingWidget();
          }
          return widget.itemBuilder(context, widget.items[index], index);
        },
      );
    }

    // استخدام itemExtent إذا كان متاحاً للأداء الأفضل
    if (widget.itemExtent != null) {
      return ListView.builder(
        controller: _scrollController,
        padding: widget.padding,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: itemCount,
        itemExtent: widget.itemExtent,
        itemBuilder: (context, index) {
          if (index == widget.items.length) {
            return widget.loadingWidget ?? _defaultLoadingWidget();
          }
          return widget.itemBuilder(context, widget.items[index], index);
        },
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return widget.loadingWidget ?? _defaultLoadingWidget();
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }

  Widget _defaultLoadingWidget() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}