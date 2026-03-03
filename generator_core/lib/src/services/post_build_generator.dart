abstract interface class PostBuildGenerator<ConfigType, InputDataType> {
  Future<void> generate(
    ConfigType config,
    InputDataType inputData,
  );
}
