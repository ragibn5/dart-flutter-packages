import 'package:flutter/widgets.dart';

sealed class IconPathOrData {}

final class IconFromPath extends IconPathOrData {
  final String iconPath;

  IconFromPath(this.iconPath);
}

final class IconFromIconData extends IconPathOrData {
  final IconData iconData;

  IconFromIconData(this.iconData);
}
