use_frameworks!

# Cocoapods for multiple targets
def sharedPods
    pod 'RxSwift', '~> 5.0'
    pod 'RxCocoa', '~> 5.0'
end

def sharedPodsIOS
  platform :ios, '9.0'
  sharedPods
end

def sharedPodsOSX
  platform :osx, '10.10'
  sharedPods
end

# Targets
target 'Example' do
    workspace 'RxSwiftAPI'
    project 'Example/Example.xcodeproj'

    sharedPodsIOS
end

target 'RxSwiftAPI iOS' do
    sharedPodsIOS
end

target 'RxSwiftAPI tvOS' do
    platform :tvos, '9.0'
    sharedPods
end

target 'RxSwiftAPI macOS' do
    sharedPodsOSX
end

target 'RxSwiftAPI watchOS' do
    platform :watchos, '3.0'
    sharedPods
end

target 'UnitTests iOS' do
    sharedPodsIOS
end

target 'UnitTests OSX' do
    sharedPodsOSX
end

target 'FunctionalTests iOS' do
    sharedPodsIOS
end

target 'FunctionalTests OSX' do
    sharedPodsOSX
end
