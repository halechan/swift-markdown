import PackageDescription

let package = Package(
    name: "Markdown",
    dependencies: [
        .Package(url: "https://github.com/halechan/swift-cmark.git", majorVersion: 0, minor: 26)
    ]
)
