import 'package:google_generative_ai/google_generative_ai.dart';

/// AI Model Router with intelligent fallback logic
/// Implements priority-based model selection with rate limit handling
class AIModelRouter {
  final String apiKey;
  
  // Priority 1: The BEAST. Unlimited usage.
  final String primaryModel = "gemini-2.5-flash-live";
  
  // Priority 2: High RPD (14.4K daily), good for general tasks if Primary is busy/down
  final List<String> fallbackPool = [
    "gemma-3-27b",
    "gemma-3-12b",
  ];
  
  // Priority 3: The "Limited Edition" (Only 20/day). Use ONLY for emergency or very specific logic.
  final String emergencyModel = "gemini-2.5-flash";

  AIModelRouter({required this.apiKey});

  /// Tries to generate content using the best available model in sequence.
  /// Never lets you hit a rate limit wall without fighting back!
  Future<GenerateContentResponse?> generateContent(
    List<Content> content, {
    void Function(String)? onModelSwitch,
  }) async {
    // --- STEP 1: Try the Unlimited King (Flash Live) ---
    onModelSwitch?.call('👉 Trying Primary Model: $primaryModel (Unlimited!)');
    final primaryResult = await _callModel(primaryModel, content, onModelSwitch);
    if (primaryResult != null) {
      return primaryResult;
    }

    // --- STEP 2: Fallback to Gemma (High Volume Workers) ---
    // If the main one fails, don't cry. Use the soldiers.
    onModelSwitch?.call('⚠️ Primary busy/error. Switching to Gemma Squad...');
    for (final model in fallbackPool) {
      onModelSwitch?.call('👉 Trying Backup: $model');
      final result = await _callModel(model, content, onModelSwitch);
      if (result != null) {
        return result;
      }
    }

    // --- STEP 3: Last Resort (The 20 RPD guys) ---
    // Sirf tab use karna jab duniya khatam ho rahi ho.
    onModelSwitch?.call('🚨 All systems critical! Using Emergency Reserve (Flash Standard)...');
    final emergencyResult = await _callModel(emergencyModel, content, onModelSwitch);
    if (emergencyResult != null) {
      return emergencyResult;
    }

    onModelSwitch?.call('❌ All models exhausted. Please try again later.');
    return null;
  }

  /// Calls a specific model with retry logic for rate limits
  Future<GenerateContentResponse?> _callModel(
    String modelName,
    List<Content> content,
    void Function(String)? onModelSwitch,
  ) async {
    const maxRetries = 3;
    const backoffFactor = 2; // Seconds

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
        );
        
        final response = await model.generateContent(content);
        
        // Success!
        onModelSwitch?.call('✅ Success using $modelName');
        return response;
        
      } catch (e) {
        final errorStr = e.toString();
        
        // Check if it's a rate limit error (429 or Resource Exhausted)
        if (errorStr.contains('429') || 
            errorStr.contains('Resource Exhausted') ||
            errorStr.contains('RESOURCE_EXHAUSTED') ||
            errorStr.contains('quota')) {
          
          if (attempt < maxRetries - 1) {
            final waitTime = backoffFactor * (attempt + 1);
            onModelSwitch?.call(
              '   ⏳ Rate limit hit on $modelName. Waiting ${waitTime}s... (Attempt ${attempt + 1}/$maxRetries)'
            );
            await Future.delayed(Duration(seconds: waitTime));
          } else {
            onModelSwitch?.call('   ❌ Rate limit exhausted on $modelName after $maxRetries retries');
            return null;
          }
        } else {
          // For non-rate-limit errors, don't retry
          onModelSwitch?.call('   ❌ Other error on $modelName: $e');
          return null;
        }
      }
    }

    return null; // Failed after all retries
  }
}
