import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AICalculateService {
  late final GenerativeModel _model;

  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
  final String _modelName = dotenv.env['GEMINI_MODEL'] ?? "gemini-2.5-flash";

  AICalculateService() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'คุณคือระบบวิเคราะห์โภชนาการอัตโนมัติ (Automated Nutrition Analysis System)\n'
        'หน้าที่: วิเคราะห์ภาพอาหารหรือฉลากโภชนาการ และส่งกลับข้อมูลเป็น JSON เท่านั้น\n\n'
        'เงื่อนไขการส่งข้อมูล JSON:\n'
        '{\n'
        '  "food_name": "ชื่ออาหาร",\n'
        '  "calories": 0,\n'
        '  "protein": 0,\n'
        '  "fat": 0,\n'
        '  "carbs": 0,\n'
        '  "sugar": 0,\n'
        '  "description": "ข้อมูลเชิงโภชนาการสรุป",\n'
        '  "health_tips": "ข้อควรระวังหรือคำแนะนำทางโภชนาการ"\n'
        '}\n\n'
        'กฎเหล็ก: \n'
        '1. ใช้ภาษาไทยที่เป็นทางการและกระชับ\n'
        '2. ห้ามมีข้อความอื่นนอกเหนือจากโครงสร้าง JSON\n'
        '3. หากเป็นฉลากผลิตภัณฑ์ ให้ยึดข้อมูลตามตัวเลขที่ปรากฏบนฉลากเป็นหลัก',
      ),
    );
  }

  Future<Map<String, dynamic>> analyzeFoodImage(
    String imagePath,
    String mode,
  ) async {
    try {
      if (_apiKey.isEmpty) throw Exception("Missing API Key");

      final imageBytes = await File(imagePath).readAsBytes();

      final promptText = mode == 'ai'
          ? 'Analyze food item and provide nutrition data in JSON.'
          : 'Extract nutrition label data into JSON format.';

      final content = [
        Content.multi([
          TextPart(promptText),
          DataPart('image/jpeg', imageBytes),
        ]),
      ];

      final response = await _model.generateContent(
        content,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final responseText = response.text ?? "";
      if (responseText.isEmpty) throw Exception("No response from system");

      return jsonDecode(_cleanJsonString(responseText));
    } catch (e) {
      return {
        "error": "ระบบไม่สามารถวิเคราะห์ข้อมูลได้: $e",
        "food_name": "Error",
        "calories": 0,
      };
    }
  }

  String _cleanJsonString(String text) {
    if (text.contains('```json')) {
      return text.replaceAll('```json', '').replaceAll('```', '').trim();
    }
    return text.trim();
  }
}
