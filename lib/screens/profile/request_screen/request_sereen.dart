import 'package:flutter/material.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double textScale = size.width / 360; // Dynamic text scaling based on a base width of 360
    
    
    return Scaffold(
      body: Column(
       
        children: [
          SizedBox(height: size.height * 0.05),

          
          Text(
            "Follow request",
            style: TextStyle(
              fontSize: 20, color: Colors.black, // Scaled font size
            ),
          ),
          SizedBox(height: size.height * 0.03),
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 25,top: 10),
                  child: ListTile(
                  
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://static.vecteezy.com/system/resources/thumbnails/047/462/757/small/positive-man-on-clean-background-photo.jpg"),
                      radius: size.height*0.04, // Dynamic radius
                      backgroundColor: Colors.black,
                    ),
                    title: Text(
                      "james_red",
                      style: TextStyle(fontSize:size.width <= 740 ? 12 : 18,color: Colors.black,fontWeight: FontWeight.bold ), // Scaled text
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: size.width * 0.02),
                       Container(
                        child: Center(child: Text("Confirm",style: TextStyle(color: Colors.black),)),
                      
                        height: size.height*0.04,
                        width: size.width*   0.20,
                        color: Colors.green,
                  
                       ),
                       SizedBox(width: 10,),
                          Container(
                        child: Center(child: Text("Delete",style: TextStyle(color: Colors.black),)),
                       
                        height: size.height*0.04,
                        width: size.width*0.20,
                        color: Colors.red,
                  
                       )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
