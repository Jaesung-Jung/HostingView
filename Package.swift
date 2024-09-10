// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HostingView",
  platforms: [
    .iOS(.v16),
    .macCatalyst(.v16),
    .tvOS(.v16),
    .visionOS(.v1)
  ],
  products: [
    .library(name: "HostingView", targets: ["HostingView"])
  ],
  targets: [
    .target(name: "HostingView")
  ]
)
