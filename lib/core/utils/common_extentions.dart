import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension AppContext on BuildContext {
  Size get size => MediaQuery.sizeOf(this);
  double get width => size.width;
  double get height => size.height;

  Future push(Widget widget) async {
    return Navigator.push(
      this,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  Future pop() async {
    return Navigator.pop(this);
  }
}

extension AlertExtention on State {
  void showAlert(
    String title,
    String message,
    VoidCallback onPressed, {
    String buttonOkTitle = "OK",
    TextAlign mainAxisAlignment = TextAlign.center,
    isForce = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isForce,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message, textAlign: mainAxisAlignment),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              context.pop();
              onPressed();
            },
            child: Text(buttonOkTitle),
          ),
        ],
      ),
    );
  }

  void showAlertTwoButton(
    String title,
    String message,
    VoidCallback onOkPressed,
    VoidCallback onCancelPressed, {
    String buttonOkTitle = "OK",
    String buttonCancelTitle = "OK",
    TextAlign mainAxisAlignment = TextAlign.center,
    isForce = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isForce,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message, textAlign: mainAxisAlignment),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              context.pop();
              onOkPressed();
            },
            child: Text(buttonOkTitle),
          ),
          CupertinoDialogAction(
            isDefaultAction: false,
            onPressed: () {
              context.pop();
              onCancelPressed();
            },
            child: Text(buttonCancelTitle),
          ),
        ],
      ),
    );
  }

  void endEditing() {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
