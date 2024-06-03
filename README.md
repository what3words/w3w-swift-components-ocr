[![CircleCI](https://dl.circleci.com/status-badge/img/gh/what3words/w3w-swift-components-ocr/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/what3words/w3w-swift-components-ocr/tree/main)
# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;w3w-swift-components-ocr

Overview
--------

A Swift component library for what3words OCR.  These components can work with either what3words' OCR SDK, or with iOS' [Vision Framework](https://developer.apple.com/documentation/vision).

<img src="Documentation/screenshot.jpeg" style="float: right; padding: 16px;">

#### what3words OCR XCFramework

If you want to use what3words' OCR XCFramework `W3WOcrSdk.xcframework`, please contact [what3words](https://what3words.com/contact-us/) to get it.  Otherwise this component works fine on it's own and employs iOS's Vision Framework for the OCR.

#### Swift Package Manager

Use [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) and add the URL below:

```
https://github.com/what3words/w3w-swift-components-ocr.git
```

Import the libraries wherever you use the components:

```swift
import W3WSwiftComponentsOcr
import W3WSwiftCore
```

#### Info.plist

You must set the camera permission in your app's `Info.plist`:

<img src="Documentation/plist.png" style="filter: drop-shadow(1px 1px 2px gray)">

Using The Component
-------------------

The component constructor needs an OCR object.  

#### Using the API with iOS' Vision Framework:

Our `W3WOcrNative` class that uses iOS' Vision Framework requires our API (or SDK) to be passed into the constructor.

```Swift
  let api = What3WordsV3(apiKey: "YourApiKey")
  let ocr = W3WOcrNative(api)
  let ocrViewController = W3WOcrViewController(ocr: ocr)
```

#### Using the SDK with what3words' OCR SDK:

The what3words OCR SDK requires only a path to the OCR data files, and optionally a language parameter (ISO 2 letter language code).

```Swift
  let ocr = W3WOcr(dataPath: "/path/to/ocr/datafiles", language: "en")
  let ocrViewController = W3WOcrViewController(ocr: ocr)
```

Typical Usage
-------------

Here's a typical use example set in a UIViewController's IBOutlet function that is connected to a UIButton (presuming the initialisation code above was used somewhere in the class):

```Swift
@IBAction func scanButtonPressed(_ sender: Any) {

    // show the component
    present(ocrViewController, animated: true)
    
    // start the component
    ocrViewController.start()
    
    // when the user taps on a suggestion, stop and dismiss the component
    ocrViewController.onSuggestionSelected = { suggestion in
      print(suggestion)
      
      ocrViewController.stop()
      ocrViewController.dismiss(animated: true)
    }
    
    ocrViewController.onError = { error in
      print(error)
    }

}
```

Example Code
------------

An example called `OcrComponent` can be found [here](https://github.com/what3words/w3w-swift-samples) in the our samples repository.

