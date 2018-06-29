import PackageDescription

let package = Package(
    name: "gattserver",
    targets: [
        Target(name: "gattserver")
    ],
    dependencies: [
        .Package(url: "https://github.com/PureSwift/GATT", majorVersion: 1)
    ],
    exclude: ["Xcode", "Carthage"]
)
