import 'package:flutter/material.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/screens/login_register/login_screen.dart';
import 'package:frontend/screens/profile/components/menu.dart';
import 'package:frontend/screens/profile/components/profile_pic.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class ProfileHeaderPlaceholder extends StatelessWidget {
  const ProfileHeaderPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: const ProfileHeader(
        profileImageUrl: "",
        username: "",
        email: "",
      ),
    );
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? appVersion;

  // Metode untuk logout pengguna menggunakan AuthProvider
  Future<void> _logout() async {
    try {
      // Gunakan AuthProvider untuk melakukan logout
      await Provider.of<AuthProvider>(context, listen: false).logout();
      Fluttertoast.showToast(
        msg: "Logout berhasil",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Arahkan pengguna ke halaman LoginScreen setelah logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      debugPrint("Error during logout: $e");
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = packageInfo.version;
      });
    } catch (e) {
      debugPrint("Error getting app version: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String userName =
        Provider.of<UserProvider>(context).username ?? "Not Available";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 70, bottom: 0),
              child: FutureBuilder<String>(
                future:
                    Future.delayed(const Duration(seconds: 1), () => userName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: const ProfileHeaderPlaceholder(),
                    );
                  } else if (snapshot.hasError) {
                    return const Text(
                      'Error loading data',
                      style: TextStyle(color: Colors.red),
                    );
                  } else {
                    return ProfileHeader(
                      profileImageUrl: '',
                      username: snapshot.data ?? 'Not Available',
                      email: "Not Available",
                    );
                  }
                },
              ),
            ),

            //menu
            Menu(
              appVersion: appVersion ?? 'Loading...',
              onLogout: _logout,
            )
          ],
        ),
      ),
    );
  }
}
