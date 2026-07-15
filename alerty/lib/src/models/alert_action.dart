sealed class AlertAction<T> {
  final String title;

  AlertAction({required this.title});
}

class CloseAction<T> extends AlertAction<T> {
  final T? closingValue;

  CloseAction({required super.title, this.closingValue});
}

class PromptAction<T> extends AlertAction<T> {
  final T Function() onTap;

  PromptAction({required super.title, required this.onTap});
}
