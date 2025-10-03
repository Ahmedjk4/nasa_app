import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:nasa_app/generated/l10n.dart';
import 'package:nasa_app/utils/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final GlobalKey _certificateKey = GlobalKey();

  // Certificate data (will be loaded from Firestore)
  String studentName = "";
  String courseName = "AstroQuest";
  String instructorName = "Space Zone";
  late DateTime completionDate;

  bool isLoading = true;
  bool hasCertificate = false;

  @override
  void initState() {
    super.initState();
    _fetchCertificate();
  }

  Future<void> _fetchCertificate() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
          hasCertificate = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('certificates')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          studentName = data['studentName'] ?? user.displayName ?? "Student";
          completionDate = data['date'] != null
              ? (data['date'] as Timestamp).toDate()
              : DateTime.parse("1980-01-01");
          hasCertificate = true;
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          hasCertificate = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching certificate: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasCertificate = false;
      });
    }
  }

  Future<void> _saveCertificate() async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted && !await Permission.photos.request().isGranted) {
        await Permission.storage.request();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }

      RenderRepaintBoundary boundary =
          _certificateKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) throw Exception("Failed to generate image");

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 100,
        name: "certificate_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (!mounted) return;

      if (result['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Certificate saved to gallery"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Failed to save to gallery");
      }
    } catch (e) {
      debugPrint("Error saving certificate: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving certificate: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double certificateWidth = 350;
    const double certificateHeight = 250;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: Text(
          S.of(context).courseCert,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.secondaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : hasCertificate
            ? SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Certificate
                        RepaintBoundary(
                          key: _certificateKey,
                          child: Container(
                            width: certificateWidth,
                            height: certificateHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.indigo.shade400,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.indigo.shade200,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Title
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.school,
                                        size: 25,
                                        color: Colors.indigo.shade600,
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        "Certificate of Completion",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF283593),
                                          letterSpacing: 1,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),

                                  // Name and course
                                  Column(
                                    children: [
                                      const Text(
                                        "This is to certify that",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        studentName,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo.shade700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "has successfully completed the course",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        courseName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),

                                  // Footer
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            instructorName,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            height: 1,
                                            width: 70,
                                            color: Colors.black54,
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            "Instructor",
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            completionDate
                                                .toLocal()
                                                .toString()
                                                .split(' ')[0],
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            height: 1,
                                            width: 70,
                                            color: Colors.black54,
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            "Date",
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Download button
                        ElevatedButton.icon(
                          onPressed: _saveCertificate,
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: Text(
                            S.of(context).saveCert,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  S.of(context).noCert,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
      ),
    );
  }
}
