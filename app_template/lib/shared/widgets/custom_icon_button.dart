import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Widget icon;
  final void Function() onTap;

  final EdgeInsets iconPadding;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconPadding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Padding(padding: iconPadding, child: icon),
    );
  }
}
