# remove any old builds
if [ -d "build" ]
then
    rm -r build
fi


# make the frameworks for each architecture
xcodebuild archive -scheme w3w-swift-components-ocr-Package -sdk iphoneos -archivePath build/W3WSwiftComponentsOcrIosDevice SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme w3w-swift-components-ocr-Package -sdk iphonesimulator -archivePath build/W3WSwiftComponentsOcrIosSimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# package the frameworks into an XCFramework
xcodebuild -create-xcframework \
 -framework build/W3WSwiftComponentsOcrIosDevice.xcarchive/Products/Library/Frameworks/W3WSwiftComponentsOcr.framework \
 -framework build/W3WSwiftComponentsOcrIosSimulator.xcarchive/Products/Library/Frameworks/W3WSwiftComponentsOcr.framework \
 -output build/W3WSwiftComponentsOcr.xcframework

