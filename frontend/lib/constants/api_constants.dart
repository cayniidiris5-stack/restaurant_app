import 'package:flutter/foundation.dart';

// Base URL — automatically adjusts for Web, Emulator, or physical device
final String baseUrl = kIsWeb 
    ? 'http://localhost:5000' 
    : 'http://192.168.100.100:5000'; // Computer's Local Wi-Fi IP address

