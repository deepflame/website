---
title: Don't be blind when KIF fails on Travis
author: Andreas Böhrnsen
date: 2014-02-05 18:16 UTC
tags: ios, testing, travisci, aws
published: true
---

Do you test your iOS app? You should! The best way to test is to simulate and automate user interaction - like a real human would use the app. You can test real use cases and your full stack. KIF is great for that on iOS. It integrates nicely into XCode and it can even take screenshots when it fails.
But how to get the screenshots out when we use Travis? Here is how.

READMORE

## Introduction

This article focuses on using KIF for iOS Acceptance Testing. However the way how to get the screenshots out can also be applied to other frameworks like Selenium web testing.

Let me assume that you have a basic understanding of 

- continuous integration with [Travis CI][1]
- automated testing with [KIF 2.0][2]
- dependency management with [CocoaPods][4] (optional)
- file hosting with [Amazon S3][9]

There are a lot of wonderful resources on the net if you need to get a quickstart.

## Using KIF

Setting up KIF is nicely described in [the docs][2] on the KIF website. To keep things organized let's use [CocoPods][4] for dependency management.

### Initial Setup

The most important thing to mention is that we have to use the `:head` version.
The current version 2.0.0 is about 6 months old and does not support taking screenshots yet.  

We change the version in the `Podfile` as follows:

```ruby
# Testing
target 'Acceptance Tests', :exclusive => true do
  pod 'KIF', :head # <- change version
end
```

To set up automated testing in Travis we have to initialize a `.travis.yml` file with the following contents:

```yml
language: objective-c
rvm:
  - 1.9.3
```

Note that I use Ruby 1.9.3. During my tests CocoaPods was always segfaulting on Ruby 2.0. This may be fixed now and not necessary anymore.

Having this in place would already install your Cocoapods dependencies and run all tests.

### Taking Screenshots

As mentioned before KIF only supports taking screenshots in `:head` or version greater than 2.0.0 (not released yet).

To enable taking screenshots we need to set the environment variable `KIF_SCREENSHOTS` that tells KIF where to output the images.  We just use a directory called "Screenshots" and create it before running the test scripts.

Let's test this locally before adding it to the Travis config.

#### Testing locally

``` shell
$ mkdir Screenshots
$ export KIF_SCREENSHOTS="`pwd`/Screenshots"
```

Then create a sample test class like this

*SampleTestCase.h*

```
#import <KIF/KIF.h>

@interface SampleTests : KIFTestCase
@end
```

*SampleTestCase.m*

```
#import "SampleTests.h"

@implementation SampleTests

- (void)testTakingScreenshotsOnFailure
{
    [tester tapViewWithAccessibilityLabel:@"this cannot be found"];
}

@end
```

and run the tests from the command line. Travis uses [xctool][3]. So it would be best to use this as well.
It can be installed with Homebrew on the Mac.

``` shell
$ brew install xctool
```

You may also want to read the [previous blog post][8] as it gives a short intro to xctool as well.  
In my case the test command looked like this:

``` shell
$ xctool -workspace iOpenSongs.xcworkspace -scheme Beta -sdk iphonesimulator test
```

If you get a screenshot of the start screen it worked!

#### Configuring Travis

In the `.travis.yml` file it looks like this:

```yml
language: objective-c
rvm:
  - 1.9.3
env:
  global:
    - KIF_SCREENSHOTS="${TRAVIS_BUILD_DIR}/Screenshots"
before_script:
  - mkdir -p $KIF_SCREENSHOTS
script:
  - xctool -workspace iOpenSongs.xcworkspace -scheme Beta -sdk iphonesimulator test
```

## Extracting the Screenshots from Travis

On Travis it would now take screenshots whenever a test fails. This is great! But how do we access the screenshots that have been taken?

We could

- send them via mail
- upload them to Dropbox
- upload them to S3
- ...

For me the easiest seemed to "upload them to S3".

### Uploading the screenshots to S3

For uploading to S3 from the command line we can use [s3cmd][5]. Again, let's test it before adding it to the Travis config.

#### Testing locally

s3cmd can be found and installed with Homebrew on a Mac

``` shell
$ brew update
$ brew install s3cmd
```

To configure it simply run

``` shell
$ s3cmd --configure
```

This will ask you for your S3 credentials and store them in `~/.s3cfg`.

Now we can list all our buckets to test the credentials.

``` shell
$ s3cmd ls
2013-11-06 02:37  s3://my-full-bucket
```

Seems to work. So we can create a new bucket for the screenshots.  
Be aware that bucket names are unique across __all__ users. Let's use a FQDN-named bucket to work around this.

``` shell
$ s3cmd mb s3://travis.code-wemo.com
```

Now we can try to upload a file

``` shell
$ s3cmd put testfile s3://travis.code-wemo.com
```

If that works we are ready to put it into our Travis config.

#### Configuring Travis

Create a new s3cmd config file `.s3cfg` in your project folder and add the minimal config

```
[default]
access_key = AKRAIFZHFQP5C7I6PLTA
```

Just add your own access\_key for now. We will encrypt the secret\_key for security reasons.  
You may also study the other options and add them as needed. For that check your `~/.s3cmd` file or execute `s3cmd --dump-config`.

To encrypt your secret\_key we can use Travis' "encrypted environment variables" feature. The variables are encrypted/decrypted with public and private RSA keys that Travis generates on a user basis.

For this we need the Travis CLI tool that can be installed with Ruby Gems. Afterwards we need to authenticate to the Travis API.

``` shell
$ gem install travis
$ travis login
```

Now we can encrypt the secret\_key as an AWS\_SECRET environment variable.

``` shell
$ travis encrypt AWS_SECRET=fKJF1yXHjLwQ/9r77Sm9Z3k62oBiEmKc3HrMsVwf --add
```

The `--add` parameter adds the encrypted variable to the `.travis.yml` file automatically.

Travis has an `after_failure` hook that we can use to install s3cmd and to upload the screenshots whenever the tests fail. So we add the following to the Travis config

``` yml
after_failure:
  - brew update
  - brew install s3cmd
  - echo "secret_key = $AWS_SECRET" >> .s3cfg
  - s3cmd put --guess-mime-type --config=.s3cfg $KIF_SCREENSHOTS/* s3://travis.code-wemo.com/$TRAVIS_JOB_NUMBER/
```

Remember to modify the s3 bucket accordingly :)

Here we go. That's it. This will

- update Homebrew
- install s3cmd
- add the secret\_key variable to the s3cmd config
- upload all screenshots to S3

when Travis fails.

To access the screenshots you could use a GUI tool like [Cyberduck][6] or [s3cmd][5] if you prefer the command line.

## Result

Here is a screenshot using Cyberduck. You can see that the filename reflects in which file and line the test failed.

![Cyberduck][7]

For your reference here is the full `.travis.yml`

```yml
language: objective-c
rvm:
  - 1.9.3
env:
  global:
    - KIF_SCREENSHOTS="${TRAVIS_BUILD_DIR}/Screenshots"
    - secure: N0tEZ7I8F...
before_script:
  - mkdir -p $KIF_SCREENSHOTS
script:
  - xctool -workspace iOpenSongs.xcworkspace -scheme Beta -sdk iphonesimulator test
after_failure:
  - brew update
  - brew install s3cmd
  - echo "secret_key = $AWS_SECRET" >> .s3cfg
  - s3cmd put --guess-mime-type --config=.s3cfg $KIF_SCREENSHOTS/* s3://travis.code-wemo.com/$TRAVIS_JOB_NUMBER/
```

You can take the whole procedure even one step further and [test across multiple iOS versions][8]. This is described in my previous blogpost.

Enjoy!

  [1]: http://travis-ci.org
  [2]: https://github.com/kif-framework/KIF
  [3]: https://github.com/facebook/xctool
  [4]: http://cocoapods.org/
  [5]: http://s3tools.org/s3cmd
  [6]: http://cyberduck.io/
  [7]: 2014-02-05-dont-be-blind-when-kif-fails-on-travis/cyberduck.png
  [8]: http://andreas.boehrnsen.de/blog/2014/02/testing-multiple-ios-platforms-on-travis/
  [9]: http://aws.amazon.com/s3/

