Google Maps test

A test app for google maps API.

**Progress:** https://trello.com/b/uFvtt83Z/google-maps-test-app

## Instructions to run:
1. Install [Cocoapods](https://cocoapods.org)
2. Install [Cocoapods keys plugin](https://github.com/orta/cocoapods-keys)
3. [Get Google maps SDK API key](https://developers.google.com/maps/documentation/ios-sdk/start)
4. Download the project, run `pod install`, you'll be asked for a key, the **google maps key**.
5. Open Xcode & run

**Note:** strings are automatically generated using `swiftgen`, to regenerate strings from localizables go to `generate` folder and run `swiftgen`

## Screenshots
[Video](https://github.com/illescasDaniel/GMapsTest/blob/master/media/GMapsTest.mp4)

<p float="left">
  <img src="media/Screenshot 1.png" width="200">
  <img src="media/Screenshot 2.png" width="200">
  <img src="media/Screenshot 3.png" width="200">
  <img src="media/Screenshot 4.png" width="200">
</p>

### Extra
- Architecture: based on Clean Architecture with MVVM (https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)
- JSON to initial response model: https://app.quicktype.io