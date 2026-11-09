import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static final InAppReview _inAppReview = InAppReview.instance;

  static const _lastPromptKey = 'lastReviewPromptMs';

  /// Check-in counts at which we ask for a rating. The store decides whether
  /// the sheet actually shows (it has its own quota), so asking at a few
  /// moments gives engaged users more than one chance to rate.
  static const promptCheckIns = {2, 5, 12, 30};

  /// Minimum gap between our own prompts.
  static const _minGap = Duration(days: 3);

  static Future<void> requestReview() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_lastPromptKey);
    final now = DateTime.now().millisecondsSinceEpoch;
    if (last != null && now - last < _minGap.inMilliseconds) return;
    if (await _inAppReview.isAvailable()) {
      await prefs.setInt(_lastPromptKey, now);
      await _inAppReview.requestReview();
    }
  }

  /// Call after a completed check-in with the new total count.
  static Future<void> maybePromptAfterCheckIn(int checkInCount) async {
    if (promptCheckIns.contains(checkInCount)) {
      await requestReview();
    }
  }

  static Future<void> openStore() async {
    await _inAppReview.openStoreListing(
      appStoreId: '6759404823', // From your App Store Connect URL
    );
  }
}
