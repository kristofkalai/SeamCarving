# SeamCarving
Carve the most important parts of the image! 🏙️

## Setup

Add the following to `Package.swift`:

```swift
.package(url: "https://github.com/stateman92/SeamCarving", exact: .init(0, 0, 1))
```

[Or add the package in Xcode.](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

## Usage

```swift
import SeamCarving

@State private var image = /* ... */

var body: some View {
    Image(uiImage: image)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect(), perform: { _ in
            image = image.carved
        })
}
```

For details see the Example app.

## Example

<p style="text-align:center;"><img src="https://github.com/stateman92/SeamCarving/blob/main/Resources/screenrecording.gif?raw=true" width="50%" alt="Example"></p>
