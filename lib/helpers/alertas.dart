


part of'helpers.dart';



mostrarLoading(BuildContext context){

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: ( _ ) => CupertinoAlertDialog(
      title: Text('Espere...'),
      content: LinearProgressIndicator(),
    ),
  );

}


mostrarAlerta(BuildContext context, String titulo, String mensaje){

  showDialog(
    context: context,
    builder: ( _ ) => CupertinoAlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        MaterialButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    )
  );

}