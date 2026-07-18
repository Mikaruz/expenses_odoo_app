import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String errorMessage;
  final VoidCallback clearError;

  const ErrorMessage({
    super.key,
    required this.errorMessage,
    required this.clearError,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage.isNotEmpty;

    final textStyle = TextStyle(
      color: Colors.red.shade700,
      fontSize: 13,
      height: 1.4,
    );

    return SizedBox(
      height: 50,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: hasError ? 1.0 : 0.0,
        child: hasError
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final isOverflowing = _isTextOverflowing(
                    text: errorMessage,
                    style: textStyle,
                    maxWidth: constraints.maxWidth - 80,
                    maxLines: 2,
                  );

                  final textWidget = Text(
                    errorMessage,
                    style: textStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  );

                  return Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: isOverflowing
                            ? GestureDetector(
                                onTap: () => _showErrorDetails(context),
                                child: textWidget,
                              )
                            : textWidget,
                      ),
                      GestureDetector(
                        onTap: clearError,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.close,
                            color: Colors.red.shade400,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            : const SizedBox(),
      ),
    );
  }

  void _showErrorDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    'Detalle del error',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: SelectableText(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  bool _isTextOverflowing({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return textPainter.didExceedMaxLines;
  }
}
