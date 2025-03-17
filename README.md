# MacMetrics

A beautiful, minimalist system monitor for macOS that focuses on CPU and memory usage.

## Features

- Real-time CPU usage monitoring
- Real-time memory usage monitoring with detailed information
- Modern, clean UI with animated gauges
- Minimal resource usage
- Native macOS application

## Requirements

- macOS 11.0 (Big Sur) or later
- Xcode 13.0 or later

## How to Build

1. Open Terminal
2. Navigate to the MacMetrics directory
3. Create an Xcode project:

```bash
xcodebuild -create -project MacMetrics.xcodeproj -target MacMetrics -xcconfig {} -configuration Debug
```

4. Open the project in Xcode:

```bash
open MacMetrics.xcodeproj
```

5. Build and run the project from Xcode

## Usage

Once launched, MacMetrics displays two gauges showing your current CPU and memory usage. The app is designed to be simple and unobtrusive.

To quit the application, simply click the X button in the top-right corner.

## Customization

You can customize the app by modifying the SwiftUI code:

- Change colors in the `MetricGaugeView` color parameters
- Adjust the update interval in `SystemMonitor.swift` (default is 2 seconds)
- Add additional metrics by extending the `SystemMonitor` class

## License

This project is available under the MIT License. 