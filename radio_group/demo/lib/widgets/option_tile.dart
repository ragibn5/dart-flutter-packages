import 'package:flutter/material.dart';

import 'package:example/widgets/demo_option.dart';

enum OptionTileStyle { list, grid, wrap }

class OptionTile extends StatelessWidget {
  final DemoOption model;
  final bool selected;
  final OptionTileStyle style;

  const OptionTile({
    super.key,
    required this.model,
    required this.selected,
    this.style = OptionTileStyle.list,
  });

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      OptionTileStyle.list => _buildListTile(context),
      OptionTileStyle.grid => _buildGridTile(context),
      OptionTileStyle.wrap => _buildChip(context),
    };
  }

  Widget _buildListTile(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nonSelectable = !model.shouldBeSelected;

    return _Shell(
      selected: selected,
      nonSelectable: nonSelectable,
      child: Row(
        children: [
          _IconBadge(
            model: model,
            selected: selected,
            nonSelectable: nonSelectable,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: nonSelectable ? cs.onSurfaceVariant : cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  model.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: nonSelectable ? cs.outline : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _RadioIndicator(selected: selected, nonSelectable: nonSelectable, size: 20),
        ],
      ),
    );
  }

  Widget _buildGridTile(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nonSelectable = !model.shouldBeSelected;

    return _Shell(
      selected: selected,
      nonSelectable: nonSelectable,
      borderRadius: 14,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(
                model: model,
                selected: selected,
                nonSelectable: nonSelectable,
                size: 30,
              ),
              const Spacer(),
              _RadioIndicator(selected: selected, nonSelectable: nonSelectable, size: 15),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            model.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: nonSelectable ? cs.onSurfaceVariant : cs.onSurface,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            model.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.2,
              color: nonSelectable ? cs.outline : cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nonSelectable = !model.shouldBeSelected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: nonSelectable
            ? cs.surfaceContainerHighest
            : selected
                ? cs.primary
                : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: nonSelectable
              ? cs.outlineVariant
              : selected
                  ? cs.primary
                  : cs.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            model.icon,
            size: 15,
            color: nonSelectable
                ? cs.outline
                : selected
                    ? cs.onPrimary
                    : model.color,
          ),
          const SizedBox(width: 6),
          Text(
            model.title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: nonSelectable
                  ? cs.onSurfaceVariant
                  : selected
                      ? cs.onPrimary
                      : cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _Shell extends StatelessWidget {
  final bool selected;
  final bool nonSelectable;
  final double borderRadius;
  final EdgeInsets padding;
  final Widget child;

  const _Shell({
    required this.selected,
    required this.nonSelectable,
    required this.child,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        color: nonSelectable
            ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
            : selected
                ? cs.primaryContainer.withValues(alpha: 0.4)
                : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: nonSelectable
              ? cs.outlineVariant
              : selected
                  ? cs.primary
                  : cs.outlineVariant,
        ),
      ),
      child: child,
    );
  }
}

class _IconBadge extends StatelessWidget {
  final DemoOption model;
  final bool selected;
  final bool nonSelectable;
  final double size;

  const _IconBadge({
    required this.model,
    required this.selected,
    required this.nonSelectable,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: nonSelectable
            ? cs.surfaceContainerHighest
            : selected
                ? model.color
                : model.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        model.icon,
        size: size * 0.5,
        color: nonSelectable ? cs.outline : selected ? Colors.white : model.color,
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  final bool selected;
  final bool nonSelectable;
  final double size;

  const _RadioIndicator({
    required this.selected,
    required this.nonSelectable,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected && !nonSelectable ? cs.primary : Colors.transparent,
        border: Border.all(
          color: nonSelectable
              ? cs.outlineVariant
              : selected
                  ? cs.primary
                  : cs.outline,
          width: 2,
        ),
      ),
      child: selected && !nonSelectable
          ? Icon(Icons.check_rounded, size: size * 0.62, color: cs.onPrimary)
          : null,
    );
  }
}
