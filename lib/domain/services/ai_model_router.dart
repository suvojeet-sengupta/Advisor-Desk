import 'package:google_generative_ai/google_generative_ai.dart';

/// AI Model Router with intelligent fallback logic
/// Implements priority-based model selection with rate limit handling
class AIModelRouter {
  final String apiKey;
  
  // Priority 1: Primary model with unlimited usage
  final String primaryModel = "gemini-2.5-flash-live";
  
  // Priority 2: Fallback models with high daily quota (14.4K RPD)
  final List<String> fallbackPool = [
    "gemma-3-27b",
    "gemma-3-12b",
  ];
  
  // Priority 3: Emergency model with limited daily quota (20 RPD)
  final String emergencyModel = "gemini-2.5-flash";

  // Cached model instances to avoid recreating on every request
  late final Map<String, GenerativeModel> _modelCache;

  AIModelRouter({required this.apiKey}) {
    // Pre-create all model instances
    _modelCache = {
      primaryModel: GenerativeModel(model: primaryModel, apiKey: apiKey),
      emergencyModel: GenerativeModel(model: emergencyModel, apiKey: apiKey),
    };
    
    // Add fallback models to cache
    for (final model in fallbackPool) {
      _modelCache[model] = GenerativeModel(model: model, apiKey: apiKey);
    }
  }

  /// Tries to generate content using the best available model in sequence.
  /// Implements automatic fallback logic to handle rate limits gracefully.
  Future<GenerateContentResponse?> generateContent(
    List<Content> content, {
    void Function(String)? onModelSwitch,
  }) async {
    // STEP 1: Try primary model with unlimited usage
    onModelSwitch?.call('👉 Trying Primary Model: $primaryModel (Unlimited)');
    final primaryResult = await _callModel(primaryModel, content, onModelSwitch);
    if (primaryResult != null) {
      return primaryResult;
    }

    // STEP 2: Fallback to high-volume secondary models
    onModelSwitch?.call('⚠️ Primary busy/error. Switching to fallback models...');
    for (final model in fallbackPool) {
      onModelSwitch?.call('👉 Trying Backup: $model');
      final result = await _callModel(model, content, onModelSwitch);
      if (result != null) {
        return result;
      }
    }

    // STEP 3: Last resort - use emergency model with limited quota
    onModelSwitch?.call('🚨 All systems critical! Using Emergency Reserve...');
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

    final model = _modelCache[modelName];
    if (model == null) {
      onModelSwitch?.call('   ❌ Model $modelName not found in cache');
      return null;
    }

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await model.generateContent(content);
        
        // Success!
        onModelSwitch?.call('✅ Success using $modelName');
        return response;
        
      } catch (e) {
        // Check if it's a rate limit error
        // Common patterns: 429, RESOURCE_EXHAUSTED, quota-related errors
        final isRateLimitError = _isRateLimitError(e);
        
        if (isRateLimitError) {
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

  /// Checks if an exception is a rate limit error
  /// Looks for common rate limit indicators in the error
  bool _isRateLimitError(Object error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('429') || 
           errorStr.contains('resource exhausted') ||
           errorStr.contains('resource_exhausted') ||
           errorStr.contains('quota') ||
           errorStr.contains('rate limit');
  }
}
