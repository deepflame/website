---
title: Testing multiple iOS platforms on Travis
date: 2014-02-02
tags: ["ios", "testing", "travisci"]
---

Ever wanted to test automatically on multiple iOS platforms and devices on Travis CI at the same time?
Here is how to do it.

READMORE

## Intro to xctool

Travis uses the xctool internally for building and testing the apps. Traditionally it will be executed like this: `xctool build test`.
[The documentation][1] suggests that you could set the `xcode_sdk` but this is not enough if you want to test on different devices as well.

The best way is to write your own custom script config to run xctool.

In your `.travis.yml` file add for example:

```yml
script:
  - xctool test -test-sdk iphonesimulator7.0 -simulator ipad
```

As you already guessed that will test the build with iOS7 on the iPad simulator.

Additional xctool options can be written into an external file called `.xctool-args`. Then your script line will not be so cluttered and you can use these as default options when running xctool from the command line during development. I found this really practical and saved me some typing.

Here is an example. It is just a JSON array with the parameters:

```json
[
  "-workspace", "iOpenSongs.xcworkspace",
  "-scheme", "Beta",
  "-configuration", "Debug",
  "-sdk", "iphonesimulator",
  "-arch", "i386"
]
```

To get to know more about xctool you may consult [the documentation][2].

## Which SDKs does Travis provide?

To find that out you can look into your test log. You will find a line that says

```shell
$ xcodebuild -version -sdk
```

When you expand the text you will find a list with available SDKs.
Look for lines like

```
iPhoneSimulator5.0.sdk - Simulator - iOS 5.0 (iphonesimulator5.0)
```

The correct strings are found in round brackets.
The current list is:

- macosx10.8
- macosx10.9
- iphoneos6.1
- iphoneos7.0
- iphonesimulator5.0
- iphonesimulator5.1
- iphonesimulator6.0
- iphonesimulator6.1
- iphonesimulator7.0

This makes it possible to test on the "iphonesimulator" from iOS 5.0 to 7.0. The "iphoneos*" SDKs can be used if you want to build your apps for production. This is not meant for testing and you cannot test directly on the device.
As you can see there are also SDKs for OSX if this is useful for you.

## Testing on multiple SDKs

To run and test iOS apps now on multiple devices we use Travis' Matrix feature. The objective-c options Travis provides do not help here as well. So we set environment variables that we then use as parameter values for xctool.

To configure a matrix for 4 different settings write:

```yml
language: objective-c
env:
  matrix:
    - TEST_SDK=iphonesimulator5.1 SIMULATOR=ipad
    - TEST_SDK=iphonesimulator6.1 SIMULATOR=ipad
    - TEST_SDK=iphonesimulator7.0 SIMULATOR=iphone
    - TEST_SDK=iphonesimulator7.0 SIMULATOR=ipad
script:
  - xctool test -test-sdk $TEST_SDK -simulator $SIMULATOR
```

That gave me the following output:

![Build Matrix][3]

This is very useful feedback! As you can see the first platform failed (iOS 5.1 on iPad).
Thanks to Travis it makes testing on multiple platforms really easy.

Let me know how it goes.


  [1]: http://docs.travis-ci.com/user/languages/objective-c/
  [2]: https://github.com/facebook/xctool
  [3]: 2014-02-02-testing-multiple-ios-platforms-on-travis/build_matrix.jpg