import 'package:in_app_review/in_app_review.dart';

class ReviewService {
  static final InAppReview _inAppReview = InAppReview.instance;

  static Future<void> requestReview() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    }
  }

  static Future<void> openStore() async {
    await _inAppReview.openStoreListing(
      appStoreId: '6759404823', // From your App Store Connect URL
    );
  }
}
