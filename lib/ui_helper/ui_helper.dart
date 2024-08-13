import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inten/const/constants.dart';

Constants myConstants = Constants();

class UiHelper {
  static CustomTextField(
      TextEditingController controller, String text, bool toHide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextFormField(
        style: TextStyle(
          fontFamily: myConstants.RobotoR,
        ),
        controller: controller,
        obscureText: toHide,
        decoration: InputDecoration(
          hintText: text,
          hintStyle: TextStyle(
            fontFamily: myConstants.RobotoR,
          ),
          border: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

/*  static CustomButton(VoidCallback voidCallback, String text) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: CupertinoColors.link.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          voidCallback();
        },
        child: Text(
          text,
          style: TextStyle(
            fontFamily: myConstants.RobotoR,
          ),
        ),
      ),
    );
  }*/
  static CustomButton(VoidCallback voidCallback, String text) {
    return Center(
      child: GestureDetector(
        onTap: voidCallback,
        child: Container(
          alignment: Alignment.center,
          width: 200,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: CupertinoColors.link.withOpacity(0.7),
          ),
          child: Text(
            text,
            style: TextStyle(
                fontFamily: myConstants.RobotoR,
                fontSize: 18,
                color: Colors.white),
          ),
        ),
      ),
    );
  }
}
