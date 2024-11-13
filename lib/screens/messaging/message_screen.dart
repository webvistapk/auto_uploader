import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/app_text_styles.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Account name',
                  style: AppTextStyles.poppinsMedium(),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                  size: 18,
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 40,
                  width: size.width * .8,
                  child: Center(
                    child: TextField(
                      style: AppTextStyles.poppinsRegular(),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 10),
                          filled: true,
                          fillColor: const Color(0xfff1f1f1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Search",
                          hintStyle: AppTextStyles.poppinsRegular(
                              color: const Color(0xffb2b2b2)),
                          prefixIcon: const Icon(
                            CupertinoIcons.search,
                          ),
                          prefixIconColor: const Color(0xffb2b2b2)),
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/edit-button.png',
                  height: 30,
                  width: 30,
                  color: const Color(0xffb2b2b2),
                  fit: BoxFit.contain,
                )
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
