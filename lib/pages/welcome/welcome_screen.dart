import 'package:flutter/material.dart';
import 'package:oassis_mart/util/global_variables.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeScreen createState() => _WelcomeScreen();
}

class _WelcomeScreen extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Create a slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start position (off-screen bottom)
      end: const Offset(0, 0), // End position (on-screen)
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start the animation when the screen renders
    _animationController.forward();
  }

  @override
  void dispose() {
    // Dispose of the animation controller
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      //key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      drawerEnableOpenDragGesture: false,
      endDrawerEnableOpenDragGesture: true,

      body: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/splash-bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: AppBar(
          //     backgroundColor: Colors.transparent,
          //     elevation: 0,
          //     title: Text(
          //       "Hi, $userName", // Default fallback for null userName
          //       style: const TextStyle(color: Colors.white),
          //     ),
          //     leading: IconButton(
          //       icon: const Icon(Icons.menu, color: Colors.white),
          //       onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          //     ),
          //   ),
          // ),
          // Foreground Content
          Positioned(
            top: 150,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/splash-logo.png',
                    height: 180,
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Choose your preference\n@ Oassis Mart',
                    style: TextStyle(fontSize: 32.0, color: Colors.black, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  // const Text(
                  //   "@ Oassis Mart",
                  //   style: TextStyle(fontSize: 50.0, color: Colors.white, fontWeight: FontWeight.w600),
                  // ),
                  // const SizedBox(height: 8),
                  // const Text(
                  //   'The ultimate destination',
                  //   style: TextStyle(
                  //     fontSize: 22.0,
                  //     color: Colors.white,
                  //     shadows: [
                  //       Shadow(
                  //         offset: Offset(4.0, 4.0),
                  //         blurRadius: 10.0,
                  //         //color: Colors.grey.withOpacity(0.5),
                  //         color: Color.fromRGBO(128, 128, 128, 0.5),
                  //       ),
                  //       Shadow(
                  //         offset: Offset(-4.0, -4.0),
                  //         blurRadius: 10.0,
                  //         color: Color.fromRGBO(128, 128, 128, 0.5),
                  //         //color: Colors.grey.withOpacity(0.2),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Sliding Buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 150),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ButtonWidget(
                      label: 'Buy',
                      icon: Icons.shopping_cart,
                      buttonWidth: buttonWidth,
                      buttonId: "buy",
                    ),
                    const SizedBox(height: 25),
                    ButtonWidget(
                      label: 'Service',
                      icon: Icons.home_repair_service,
                      buttonWidth: buttonWidth,
                      buttonId: "service",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final double buttonWidth;
  final String label;
  final IconData icon;
  final String buttonId;

  const ButtonWidget({super.key, required this.label, required this.icon, required this.buttonWidth, required this.buttonId});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20), right: Radius.circular(20)),
      child: InkWell(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20), right: Radius.circular(20)),
        onTap: () async {
          //Navigator.pop(context);
          //print(buttonId);
          if (buttonId == "buy") {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/buyhome', // Target route
              (Route<dynamic> route) => false, // Remove all previous routes
            );
          } else if (buttonId == "sell") {
            Navigator.pushNamed(context, '/sell');
          } else if (buttonId == "service") {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/services', // Target route
              (Route<dynamic> route) => false, // Remove all previous routes
            );
          }
        },
        child: Ink(
          width: buttonWidth,
          decoration: const BoxDecoration(
            //color: Color(0xFF52A724), // Green color for the button
            color: primaryColor, // Green color for the button
            borderRadius: BorderRadius.horizontal(left: Radius.circular(20), right: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 20), // Spacer to balance the layout
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 50, // Icon color
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.white),
                    //style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
