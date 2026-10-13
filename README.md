# Articles App

An iPhone and iPad app that loads articles from a mock API, shows them as cards, and opens one article on a detail screen.

The project is a UIKit app written in the MVC pattern. Screens are built with a storyboard and a XIB. One screen, the offline empty state, is SwiftUI and is shown through `UIHostingController`.

On iPhone the detail screen slides over the list. On iPad the list stays on the left and the article opens on the right.

## Requirements

| Item | Version |
|---|---|
| Xcode | 26.2 (project last upgraded with Xcode 26.2) |
| Swift | 5.0 |
| iOS deployment target | 18.0 |
| CocoaPods | 1.17.0 |
| App version | 1.0 (build 1) |

Open the project in Xcode 26 or later. The app runs on iOS 18.0 and later, including iOS 26.

## What the app supports

| Item | Value |
|---|---|
| Bundle identifier | `com.ArticlesApp` |
| Scheme | `ArticlesApp` |
| Devices | iPhone and iPad (`TARGETED_DEVICE_FAMILY` 1, 2) |
| Platforms | iPhone and iPad simulator and device. Mac Catalyst is off. |
| iPhone orientation | Portrait only |
| iPad orientation | Portrait, upside down, landscape left, landscape right |
| Appearance | Light mode only, so the colors stay the same as the design |
| Architecture | MVC |
| UI | UIKit storyboard and XIB, plus one SwiftUI view |
| Minimum iOS | 18.0 |
| iOS 26 | Back and heart buttons use Liquid Glass. On iOS 18–25 they are solid circles. |

## Run the app

1. Install CocoaPods 1.17 if it is not installed: `sudo gem install cocoapods -v 1.17.0`
2. Open Terminal in this folder.
3. Run `pod install`.
4. Open `ArticlesApp.xcworkspace`. Do not open `ArticlesApp.xcodeproj`. The pods are only linked from the workspace.
5. Select the **ArticlesApp** scheme.
6. Pick an iPhone or iPad simulator, or a device running iOS 18 or later, and press Run.

The `Podfile` sets every pod target to iOS 18.0. Xcode 26 refuses pods whose deployment target is older than the SDK allows, so `pod install` must be run from this `Podfile`. Do not delete the `post_install` block.

## Articles API

```
https://mocki.io/v1/9f09ed09-d8ca-48c7-9957-dec39e745321
```

The response is NewsAPI-shaped: `status`, `totalResults`, and `articles`. Some articles leave out the title, author, description, image, or link. The app still shows the rest of the list.

## What you can do in the app

- Scroll the article cards.
- Pull down to refresh.
- Tap a card or **Read More** to open that article.
- On iPad, the article opens in the right-hand column. The list stays on the left. Until you tap one, the right side says **Select an article**.
- On iPhone, the article opens on top of the list. The back button returns to the list.
- Tap the search icon. The search field replaces the title inside the white header. Search matches the title, body, and author. **Cancel** puts the title and icons back and clears the filter.
- The grid icon scrolls the list to the top.
- **Read full article** opens the link in Safari inside the app. If the link is missing or invalid, the button explains that.
- The heart only changes on that screen. It is not saved.
- Turn the network off. If articles were loaded before, the saved list stays on screen with a short offline note. If nothing was saved yet, you see **You're offline** and **Retry**. When the network comes back, the list reloads.

## How a launch works

1. `AppDelegate` configures `XCGLogger` and registers the services in a Swinject container.
2. `SceneDelegate` asks Swinject for `ArticleManager` and gives it to `HomeViewController`. The home screen does not create the network, cache, or reachability objects itself.
3. `SceneDelegate` puts the home screen in a split view.
   - Left column: the article list inside a navigation controller. The navigation bar is hidden.
   - Right column: **Select an article**, until you tap one.
4. `HomeViewController` calls `articleManager.fetchArticles`.
5. `ArticleManager` checks the network.
   - Online: `ArticleAPIProvider` downloads the JSON with Alamofire, then `ArticleCacheManager` saves the list with the Cache pod.
   - Offline, or the request fails: the manager returns the saved list. If there is no saved list, it returns an offline error and the home screen shows the offline view.
6. `XCGLogger` writes the request, the response, and any error to the Xcode console.

## How a tap works

1. `ArticleCell` calls `onReadMore`, or the table calls `didSelectRow`.
2. `HomeViewController` calls `router.showArticle`.
3. `SceneDelegate` forwards that to `ArticleSplitViewController`.
4. On a wide iPad, the split view puts `DetailViewController` in the right column.
5. On iPhone, it pushes `DetailViewController` onto the list's navigation stack.

Screens never construct Alamofire, Kingfisher, Cache, Reachability, or the logger. They call `ArticleManager`. The manager calls the network through `ArticleProviderProtocol`.

## Project structure

```
ArticlesApp/
├── ArticlesApp.xcworkspace          open this
├── ArticlesApp.xcodeproj
├── Podfile                          direct pods and the iOS 18 post_install
├── Podfile.lock                     exact pod versions
├── README.md
├── Pods/                            created by pod install, not edited by hand
└── ArticlesApp/
    ├── AppDelegate.swift            Swinject registration and logger setup
    ├── SceneDelegate.swift          window, light mode, split view
    ├── Info.plist                   scene manifest
    ├── Models/
    │   ├── Entities/
    │   │   ├── Article.swift        one article, plus safe display text
    │   │   └── ArticleResponse.swift   API envelope; skips one bad article
    │   └── ProviderProtocols/
    │       └── ArticleProviderProtocol.swift
    ├── Provider/
    │   ├── Client/
    │   │   ├── NetworkConfiguration.swift   the mock URL
    │   │   ├── NetworkError.swift
    │   │   ├── NetworkReachability.swift    ReachabilitySwift wrapper
    │   │   └── AppLogger.swift               XCGLogger wrapper
    │   └── Core/
    │       └── ArticleAPIProvider.swift      Alamofire request
    ├── Managers/
    │   ├── Client/
    │   │   ├── AppConstants.swift            colors, sizes, Liquid Glass fallback
    │   │   └── ArticleCacheManager.swift     Cache pod storage
    │   └── Core/
    │       └── ArticleManager.swift          the only type the screens call
    ├── ViewControllers/
    │   ├── Client/
    │   │   ├── ArticleRouter.swift
    │   │   ├── ArticleSplitViewController.swift   iPhone push, iPad columns
    │   │   └── StatusBarNavigationController.swift
    │   ├── Core/
    │   │   ├── HomeViewController.swift
    │   │   ├── DetailViewController.swift
    │   │   └── EmptyDetailViewController.swift    iPad placeholder
    │   └── Cells/
    │       └── ArticleCell.swift
    ├── Views/
    │   ├── Storyboards/Base.lproj/Main.storyboard
    │   ├── XIBs/ArticleCell.xib
    │   ├── OfflineEmptyStateView.swift       the SwiftUI offline screen
    │   └── ArticleImageLoading.swift         Kingfisher helper
    └── Assets.xcassets                       app icon, calendar, arrow
```

New Swift files placed under `ArticlesApp/` are picked up by the Xcode synchronized folder. You do not add them to the project file by hand.

## Pods

These are the versions locked in `Podfile.lock`.

| Pod | Version | Used for |
|---|---|---|
| Alamofire | 5.11.2 | Downloads the article JSON and checks the HTTP status |
| Cache | 6.0.0 | Saves the last successful list on disk for offline use |
| Kingfisher | 8.10.0 | Loads article images and shows a photo icon if an image fails |
| ReachabilitySwift | 5.2.4 | Notices when the device goes offline or comes back online |
| Swinject | 2.9.1 | Creates the manager, cache, provider, and reachability in one place |
| XCGLogger | 7.1.5 | Logs requests, responses, and errors to the Xcode console |

XCGLogger also pulls in **ObjcExceptionBridging 7.1.5**. The app does not call that pod itself.

`AppLogger` wraps XCGLogger so the rest of the app does not import it. `SceneDelegate` is the one file that imports Swinject, because it is the file that resolves `ArticleManager`.

## Data that can be missing

| Missing field | What the screen shows |
|---|---|
| Title | Untitled Article |
| Author | Unknown Author |
| Description and content | Article content is not available. |
| Date | Date unavailable |
| Image | A photo icon |
| Link | **Read full article** is disabled and explains that there is no link |

`ArticleResponse` decodes each article on its own. One broken article does not throw away the rest of the list. Image and article links accept both `http` and `https`.

## Design notes

- The home header and the page behind the cards are white (`#FFFFFF`).
- The article cards and the detail header use `#233D46`. The Read More button uses `#195A94`.
- A missing article image shows the `placeholder` asset. The date uses the `calendar` asset and the Read More button uses the `arrow` asset.
- Card dates use the form `24 Oct,2021`. The detail screen shows a short relative time, such as `10h ago`.
- Text uses Dynamic Type, so it grows with the system text size.
- On iOS 26 the back and heart buttons use Liquid Glass. On iOS 18 they are solid circles. The blue **Read More** button stays filled on every version.
- The app is locked to light mode so the colors stay the same as the design.

## Assumptions

- The grid icon has no second layout in the design, so it scrolls to the top.
- The heart is not stored.
- Optional pods such as Loaf were not added. The six pods above already cover networking, images, cache, reachability, logging, and dependency injection.
