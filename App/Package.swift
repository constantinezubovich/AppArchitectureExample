// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var package = Package(
    name: "App",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)]
)

struct ExternalDependency {
    var product: Target.Dependency
    var package: Package.Dependency
}

struct Module {
    var name: String
    var moduleDependencies: [Module] = []
    var externalDependencies: [ExternalDependency] = []
    var resources: [Resource]?
    var adittionalSwiftSettings: [SwiftSetting]?
    var plugins: [Target.PluginUsage]?
    var isTestTarget = false
    
    var swiftSettings: [SwiftSetting] {
        defaultSwiftSettings + (adittionalSwiftSettings ?? [])
    }
    
    let defaultSwiftSettings: [SwiftSetting] = [
        .unsafeFlags([
            "-Xfrontend", "-warn-concurrency",
            "-Xfrontend", "-enable-actor-data-race-checks"
        ])
    ]
    
    static func testModule(
        for module: Module,
        additionalModuleDependencies: [Module] = [],
        externalDependencies: [ExternalDependency] = [],
        exclude: [String] = []
    ) -> Module {
        Module(
            name: "\(module.name)Tests",
            moduleDependencies: [module] + additionalModuleDependencies,
            externalDependencies: externalDependencies,
            adittionalSwiftSettings: module.adittionalSwiftSettings,
            isTestTarget: true
        )
    }
}


// MARK: - External Dependencies
extension ExternalDependency {
    static let composableArchitecture = ExternalDependency(
        product: .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        package: .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.2.0")
    )
    
    static let dependencies = ExternalDependency(
        product: .product(name: "Dependencies", package: "swift-dependencies"),
        package: .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0")
    )
    
    static let asyncAlgorithms = ExternalDependency(
        product: .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
        package: .package(url: "https://github.com/apple/swift-async-algorithms", exact: "1.0.0-alpha")
    )
    
    static let identifiedCollections = ExternalDependency(
        product: .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
        package: .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0")
    )
}


// MARK: - Modules
extension Module {
    
    static let appFeature = Module(
        name: "AppFeature",
        moduleDependencies: [
            routing,
            models,
            navigationCore,
            homeFeature
        ]
    )
    
    static let appFeatureLive = Module(
        name: "AppFeatureLive",
        moduleDependencies: [appFeature, cameraClientLive, discoveredCamerasClientLive]
    )
    
    
    static let routing = Module(
        name: "Routing",
        moduleDependencies: [navigationCore, homeFeature, cameraFeature],
        externalDependencies: [.composableArchitecture]
    )
    
    // MARK: - Core
    static let navigationCore = Module(
        name: "NavigationCore",
        externalDependencies: [.composableArchitecture]
    )

    static let models = Module(name: "Models")

    
    // MARK: - Clients
    static let cameraClient = Module(
        name: "CameraClient",
        moduleDependencies: [models],
        externalDependencies: [.dependencies, .identifiedCollections]
    )
    static let cameraClientLive = Module(
        name: "CameraClientLive",
        moduleDependencies: [cameraClient]
    )
    
    static let discoveredCamerasClient = Module(
        name: "DiscoveredCamerasClient",
        moduleDependencies: [.models],
        externalDependencies: [.dependencies, .identifiedCollections]
    )
    static let discoveredCamerasClientLive = Module(
        name: "DiscoveredCamerasClientLive",
        moduleDependencies: [discoveredCamerasClient]
    )
    
    
    // MARK: - Features
    static let homeFeature = Module(
        name: "HomeFeature",
        moduleDependencies: [navigationCore, models, cameraClient, discoveredCamerasClient],
        externalDependencies: [.composableArchitecture, .asyncAlgorithms]
    )
    
    static let cameraFeature = Module(
        name: "CameraFeature",
        moduleDependencies: [navigationCore, models, cameraClient],
        externalDependencies: [.composableArchitecture]
    )
    
    
    static let appModules: [Module] = [
        appFeature,
        appFeatureLive,
        navigationCore,
        cameraClient,
        cameraClientLive,
        discoveredCamerasClient,
        discoveredCamerasClientLive,
        models,
        routing,
        homeFeature, .testModule(for: homeFeature),
        cameraFeature,
    ]
}

// MARK: - Package configuration

Module.appModules
    .flatMap(\.externalDependencies)
    .map(\.package)
    .uniqueElements(by: \.kind)
    .forEach { dependency in
        package.dependencies.append(dependency)
    }

Module.appModules.forEach { module in
    if !module.isTestTarget {
        package.products.append(.library(name: module.name, targets: [module.name]))
    }

    let moduleDependencies = module.moduleDependencies.map(\.name).map(Target.Dependency.init(stringLiteral:))
    let externalDependencies = module.externalDependencies.map(\.product)

    let dependencies = moduleDependencies  + externalDependencies

    if module.isTestTarget {
        package.targets.append(
            .testTarget(
                name: module.name,
                dependencies: dependencies,
                swiftSettings: module.swiftSettings
            )
        )
    } else {
        package.targets.append(
            .target(
                name: module.name,
                dependencies: dependencies,
                resources: module.resources,
                swiftSettings: module.swiftSettings,
                plugins: module.plugins
            )
        )
    }
}

// MARK: - Extensions

/// We use ``Array.uniqueElements(by:)`` and ``Package.Dependency.Kind`` conforming to ``Equatable``
/// to filter only **unique** packages when we add external dependencies into package.
extension Array {
    func uniqueElements<T: Equatable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var uniqueElements: [Element] = []
        for value in self {
            let isThereElementAlready = uniqueElements.contains { element in
                element[keyPath: keyPath] == value[keyPath: keyPath]
            }
            guard isThereElementAlready == false else { continue }
            uniqueElements.append(value)
        }
        return uniqueElements
    }
}

extension Package.Dependency.Kind: Equatable {
    public static func == (
        lhs: PackageDescription.Package.Dependency.Kind,
        rhs: PackageDescription.Package.Dependency.Kind
    ) -> Bool {
        switch lhs {
        case .fileSystem(name: _, path: let lhsPath):
            switch rhs {
            case .fileSystem(name:_, let rhsPath):
                return lhsPath == rhsPath
            case .registry, .sourceControl:
                return false
            @unknown default:
                return false
            }
        case .registry(id: let lhsID, requirement: _):
            switch rhs {
            case .registry(id: let rhsID, requirement: _):
                return lhsID == rhsID
            case .fileSystem, .sourceControl:
                return false
            @unknown default:
                return false
            }
        case .sourceControl(name: _, location: let lhsLocation, requirement: _):
            switch rhs {
            case .sourceControl(name: _, location: let rhsLocation, requirement: _):
                return lhsLocation == rhsLocation
            case .fileSystem, .registry:
                return false
            @unknown default:
                return false
            }
        @unknown default:
            return false
        }
    }
}
