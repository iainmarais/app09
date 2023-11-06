// ignore_for_file: file_names
import "package:flutter/material.dart";

class CaptureCardScreen extends StatefulWidget 
{
  const CaptureCardScreen({super.key});

  @override
  State<CaptureCardScreen> createState() => _CaptureCardScreenState();
}

class _CaptureCardScreenState extends State<CaptureCardScreen> 
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Capture Card"),
      ),
      body: const Center(
        
      )
    );
  }
}