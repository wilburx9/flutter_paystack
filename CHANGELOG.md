## 1.0.7
* Fixed an issue where only one bank showed-up in the banks dropdown
* Fixed build issues caused by androidx material library
* Fixed build issues caused by using the wrong android `compileSdkVersion`

## 1.0.6
* Completed migration for Android v2 embedding.
* Fixed colour issues in dark mode
* Upgrades Kotlin and AGP versions.
* Fixed build issues for Flutter 3

## 1.0.5+1
* Updated dependencies
* Updated ReadMe

## 1.0.5 (Breaking change)
* Supported sound null-safety
* Resolved build failure due to unresolved VERSION_NAME and VERSION_CODE
* Fixed issue with dark mode (courtesy of nuelsoft)
* Switched static initialization for instance initialization of the plugin
* Upgraded all native and cross-platform dependencies


## 1.0.4+1
* Downgraded minimum Flutter version to 1.20.1

## 1.0.4
* Implemented support for V2 Android embedding
* Removed instances of deprecated Flutter APIs
* Updated dependencies
* Fixed issues #47 and #48
* Deprecated callbacks in the `chargeCard` function.


## 1.0.3+1
* Fixed issue with wrong plugin class in pubspec.yaml (#45)
* Added spaces to initial string for card number field


## 1.0.3
* Fixed issue with using disposed context(#26)
* Removed hardcoded currency text in the checkout prompt (#30)
* Fixed issue where plugin crashes app in headless service (#31)
* Converted charge metadata to json format (thanks to Itope84)
* Fixed issue with validating past months
* Added option to hide email and/or amount in checkout prompt
* Made the example main.dart more usable
* Wrote unit tests and widget tests

## 1.0.2+1

* Corrected typo in "Secured by" text

## 1.0.2

* Made plugin theme customizable
* Switched deprecated UIWebView for WKWebView for iOS
* Added a customizable company logo
* Displayed "Secured by Paystack" at bottom of payment prompt

## 1.0.1+1

* Bumped dependencies versions


## 1.0.1

* Migrated to AndroidX
* Bumped up dependencies to the latest versions
* Improved month input formatter


## 1.0.0

* Reintroduced and improved bank payment
* Minor bug fixes

## 0.10.0 (Breaking change)

* Security Improvement: Removed usage of the secret key in checkout
* Removed support for bank payment (requires secret key)
* Transaction initialization and verification is no longer being handled by the checkout function (requires secret key)
* Handled Gateway timeout error
* Returning last for digits instead full card number after payment

## 0.9.3

* Fixed failure of web OTP on iOS devices
* Automatically closes soft keyboard when text-field entries are submitted
* Changed date picker on iOS to CupertinoDatePicker

## 0.9.2

* Bank account payment: fixed issue where the reference value passed to checkout is different from what is returned after transaction.
* Increased width of checkout dialog.
* Added flag to enable fullscreen checkout dialog.
* Felt like doing some reorganising so I refactored some .dart files.

## 0.9.1+2

* Fixed build failure because of difference in type of passed and expected value of encrypt function.

## 0.9.1+1

* Updated to the latest gradle and kotlin dependencies.

## 0.9.1

* Bumped version of dependencies.

## 0.9.0

* Added checkout form and supported bank account payment.

## 0.5.2

* Support for Flutter v0.5.1.

## 0.5.1

* Exposed Paystack Exception
* Properly formatted .dart files
* Removed deprecated APIs

## 0.5.0

* Initial beta release.
