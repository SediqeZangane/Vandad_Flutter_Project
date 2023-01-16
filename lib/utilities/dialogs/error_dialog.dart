import 'package:flutter/material.dart';
import 'package:vandad_flutter_project/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
    BuildContext context,
    String text,
    ) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occurred',
    content: text,
    optionsBuilder: () => {
     'ok': null,
    },
  );
}