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
