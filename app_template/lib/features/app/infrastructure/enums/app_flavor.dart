enum AppFlavor {
  DEV(FLAVOR_NAME_DEV),
  EXP(FLAVOR_NAME_EXP),
  STAGE(FLAVOR_NAME_STAGE),
  PROD(FLAVOR_NAME_PROD);

  final String name;

  const AppFlavor(this.name);

  static const String FLAVOR_NAME_DEV = 'dev';
  static const String FLAVOR_NAME_EXP = 'exp';
  static const String FLAVOR_NAME_STAGE = 'stage';
  static const String FLAVOR_NAME_PROD = 'prod';
}
