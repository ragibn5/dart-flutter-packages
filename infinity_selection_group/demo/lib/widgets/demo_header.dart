import 'package:flutter/material.dart';

import 'package:example/widgets/demo_option.dart';

class LayoutInfo {
  final IconData icon;
  final String title;
  final String description;

  const LayoutInfo({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class DemoHeader extends StatelessWidget {
  final List<DemoOption> selected;
  final int maxSelectionCount;
  final LayoutInfo? layoutInfo;

  const DemoHeader({
    super.key,
    this.selected = const [],
    this.maxSelectionCount = 0,
    this.layoutInfo,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primaryContainer, cs.tertiaryContainer],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.checklist_rounded,
                  color: cs.onPrimary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selection Group',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: Row(
                        key: ValueKey(layoutInfo?.title),
                        children: [
                          if (layoutInfo != null) ...[
                            Icon(
                              layoutInfo!.icon,
                              size: 14,
                              color: cs.onPrimaryContainer.withValues(
                                alpha: 0.75,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              layoutInfo == null
                                  ? ''
                                  : '${layoutInfo!.title} — '
                                      '${layoutInfo!.description}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: cs.onPrimaryContainer.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SelectionRow(
            selected: selected,
            maxSelectionCount: maxSelectionCount,
          ),
        ],
      ),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  final List<DemoOption> selected;
  final int maxSelectionCount;

  const _SelectionRow({
    required this.selected,
    required this.maxSelectionCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final titles = selected.map((option) => option.title).join(', ');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.onPrimaryContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                '${selected.length}',
                style: TextStyle(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Currently selected'
                  '${maxSelectionCount > 0 ? ' — $maxSelectionCount max' : ''}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                        letterSpacing: 0.3,
                      ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Text(
                    selected.isEmpty ? 'None selected' : titles,
                    key: ValueKey(titles),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.checklist_rounded, color: cs.primary, size: 22),
        ],
      ),
    );
  }
}
