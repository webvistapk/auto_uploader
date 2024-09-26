import 'package:flutter/material.dart';

void showSuccessSnackbar(String message,BuildContext context){
    final snackbar=SnackBar(
      content: Text(message,
        style: TextStyle(
            color: Colors.white),),
      backgroundColor: Colors.black54,
      duration: Duration(seconds: 8),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);

}

void showErrorSnackbar(String message,BuildContext context){

    final snackbar=SnackBar(
      content: Text(message,style: TextStyle(
        color: Colors.white,
      ),),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 8),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);

}