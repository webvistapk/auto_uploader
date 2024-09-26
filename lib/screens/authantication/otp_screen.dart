import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:pinput/pinput.dart';


class OtpScreen extends StatelessWidget {
const OtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size =MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Column(
         
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20,top: 20),
              child: Icon(Icons.arrow_back_ios,size: 25),
            ),
            SizedBox(height: size.height*0.02,),
          Padding(
            padding: const EdgeInsets.only(top: 15,left: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(" Enter 6-digit code",style: TextStyle(fontSize: 21,fontWeight: FontWeight.bold),),
                   SizedBox(height: size.height*0.05,),
                  Text("Enter 6-digit code that was sent to your phone",style: TextStyle(color: Colors.grey,fontSize: 11),),
                 
                  
              ],
            ),
          ),
           SizedBox(height: size.height*0.05,),
                 Form(
                   child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        child: TextFormField(
                          cursorColor: Colors.grey,
                          autofocus: true,
                          onSaved: (pin1){},
                          onChanged: (value) {
                            if (value.length==1) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: InputDecoration(counterText: ""),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      SizedBox(width: 10,),
                       SizedBox(
                        width: 40,
                        child: TextFormField(
                          cursorColor: Colors.grey,
                          autofocus: true,
                          onSaved: (pin2){},
                          onChanged: (value) {
                            if (value.length==1) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: InputDecoration(counterText: ""),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                       SizedBox(width: 10,),
                       SizedBox(
                        width: 40,
                        child: TextFormField(
                          cursorColor: Colors.grey,
                          autofocus: true,
                          onSaved: (pin3){},
                          onChanged: (value) {
                            if (value.length==1) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: InputDecoration(counterText: ""),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                       SizedBox(width: 10,),
                       SizedBox(
                        width: 40,
                        child: TextFormField(
                          cursorColor: Colors.grey,
                          autofocus: true,
                          onSaved: (pin4){},
                          onChanged: (value) {
                            if (value.length==1) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: InputDecoration(counterText: ""),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                       SizedBox(width: 10,),
                       SizedBox(
                        width: 40,
                        child: TextFormField(
                          cursorColor: Colors.grey,
                          autofocus: true,
                          onSaved: (pin5){},
                          onChanged: (value) {
                            if (value.length==1) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: InputDecoration(counterText: ""),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                       SizedBox(width: 10,),
                       SizedBox(
                        width: 40,
                        child: TextFormField(
                          cursorColor: Colors.grey,
                          autofocus: true,
                          onSaved: (pin6){},
                          onChanged: (value) {
                            if (value.length==1) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: InputDecoration(counterText: ""),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      )
                   
                    ],
                   ),
                 )
          ],
        ),
      ),
    );
  }
}

// Widget textcode(){
//   return Pinput(
//     // obscureText: true,
//     // obscuringWidget: Text("*"),
//     length: 6,
//     onChanged: (value) {
//       setstate()
//     },
//   );
// }
