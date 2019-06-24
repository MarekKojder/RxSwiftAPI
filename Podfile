platform :ios, '9.0'

# Cocoapods for multiple targets
def dependencies
    pod 'RxSwift', '~> 5.0'
    pod 'RxCocoa', '~> 5.0'
end

# Targets
target 'Example' do
    workspace 'RxSwiftAPI'
    project 'Example/Example.xcodeproj'

    use_frameworks!
    dependencies
end

target 'RxSwiftAPI iOS' do
    dependencies
end

target 'RxSwiftAPI tvOS' do
    dependencies
end

target 'RxSwiftAPI macOS' do
    dependencies
end

target 'RxSwiftAPI watchOS' do
    dependencies
end