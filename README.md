# SAMI sample app SAMIHMonitor V2

This sample iOS app demonstrates how to use SAMI as a data exchange platform to retrieve weight and calorie data from different sources.

Introduction
-------------

The blog post [Developing With SAMI: Let's Bring Your Data Together](https://blog.samsungsami.io/mobile/development/2015/03/03/developing-with-sami-part-3.html) at http://blog.samsungsami.io/ describes what the app does and how it is implemented. Specifically, The app illustrates how to discover a user's devices, add a user's devices, send data to SAMI for storage and future exchange, and to retrieve data from different data sources through SAMI.

Demo
-------------

Take a look at Section [Demo: Record and view your calories](https://blog.samsungsami.io/mobile/development/2015/03/03/developing-with-sami-part-3.html#demo-record-and-view-your-calories) of the blog post. You can watch a video there.

Prerequisites
-------------

 * Xcode 6.1 or above
 * Cocoapods http://guides.cocoapods.org/using/getting-started.html
 * SAMI Objective-C/iOS SDK http://github.com/samsungsamiio/sami-ios

Setup and Installation
----------------------

1. Create an Application in devportal.samsungsami.io:
  * The Redirect URI is set to 'ios-app://redirect'.
  * Choose "Client credentials, auth code, implicit" for OAuth 2.0 flow.
  * Under "PERMISSIONS", check "Read" for "Profile". 
  * Click the "Add Device Type" button. Choose "SAMI Example Calorie Tracker" as the device type. Check "Read" and "Write" permissions for this device type.
2. Install CocoaPods. See [this page](http://guides.cocoapods.org/using/getting-started.html) for instructions. From a terminal window, locate the SAMIClient directory, and run `pod install`. This installs all the prerequisites like AFNetworking and SocketRocket.
3. Download [SAMI iOS SDK](https://github.com/samsungsamiio/sami-ios)
4. Double-click `SAMIHMonitor.xcworkspace` in the Finder window to open it in Xcode. Now import the SAMI SDK. Drag the `client` folder of the downloaded SAMI iOS SDK from the Finder window into the `SAMIHMonitor` group in Xcode.
5. Use the client ID (obtained when registering the app in the Developer Portal) to replace `YOUR CLIENT APP ID` in `SamiConstants.m`.

Now build in Xcode and run SAMIHMonitor in iOS Simulator.

More about SAMI
---------------

If you are not familiar with SAMI we have extensive documentation at http://developer.samsungsami.io

The full SAMI API specification with examples can be found at http://developer.samsungsami.io/sami/api-spec.html

We blog about advanced sample applications at http://blog.samsungsami.io/

To create and manage your services and devices on SAMI visit developer portal at http://devportal.samsungsami.io

License and Copyright
---------------------

Licensed under the Apache License. See LICENSE.

Copyright (c) 2015 Samsung Electronics Co., Ltd.
