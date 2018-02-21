# RxHeartRateMonitors

[![CI Status](http://img.shields.io/travis/Leandro Perez/RxHeartRateMonitors.svg?style=flat)](https://travis-ci.org/Leandro Perez/RxHeartRateMonitors)
[![Version](https://img.shields.io/cocoapods/v/RxHeartRateMonitors.svg?style=flat)](http://cocoapods.org/pods/RxHeartRateMonitors)
[![License](https://img.shields.io/cocoapods/l/RxHeartRateMonitors.svg?style=flat)](http://cocoapods.org/pods/RxHeartRateMonitors)
[![Platform](https://img.shields.io/cocoapods/p/RxHeartRateMonitors.svg?style=flat)](http://cocoapods.org/pods/RxHeartRateMonitors)

RxHeartRateMonitors is a lightweight layer on top of [RxBluetoothKit](https://github.com/Polidea/RxBluetoothKit) and [Core Bluetooth](https://developer.apple.com/documentation/corebluetooth) to interact with BTLE Heart Rate Monitors.


It leverages the power of RxBluetoothKit and Corebluetooth to allow you to communicate with monitors in a seamless way.

* Connect to BTLE heart rate monitors avoiding the complexities of CoreBluetooth.

* No need to parse raw data.

* No need to care about services and characteristics.

* Extensible. If you want to connect to other types of devices, like speedometers, you can create your own central.



## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.




**Important:**

- Specify a bundle identifier, Team and provisioning profiles to run.

- You will need an actual device to connect to HR monitors.

## Requirements
Swift 4.0

## Installation

RxHeartRateMonitors is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RxHeartRateMonitors'
```
## Usage

### Import
```swift
import RxHeartRateMonitors
```


### Create a central

```swift
let central = HeartRateMonitorCentral()
```

### Display bluetooth state

```swift
central.state
    .map{"Bluetooth is \($0.isOn ? "ON" : "OFF")"}
    .asDriver(onErrorDriveWith: .never())
    .drive(self.stateLabel.rx.text)
    .disposed(by: disposeBag)
```


### Display monitors in a UITableView

```swift
private func bindMonitors(){
    self.central.monitors
        .bind(to: self.table.rx.items) { (table, row, heartRateMonitor) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = heartRateMonitor.name
            return cell
        }
    .disposed(by: disposeBag)
}
```


### Connect to a monitor
```swift
self.heartRateMonitor
    .connect()
    .subscribe()
    .disposed(by: disposeBag)
```


### Disconnect from a monitor
```swift
self.heartRateMonitor
    .disconnect()
    .subscribe()
    .disposed(by: disposeBag)
```

### Display heart rate
```swift

self.heartRateMonitor
    .heartRate
    .map{$0.description}
    .asDriver(onErrorJustReturn: "N/A")
    .drive(self.heartRateLabel.rx.text)
    .disposed(by: disposeBag)
```

### Display a monitor's state
```swift

self.heartRateMonitor
    .monitoredState
    .asDriver(onErrorJustReturn: .disconnected)
    .map{$0.description}
    .drive(self.stateLabel.rx.text)
    .disposed(by: disposeBag)

```


### Auto-Connect to a previously connected monitor
```swift

let monitor : Observable<HeartRateMonitor> = central.whenOnlineConnectToFirstAvailablePeripheral()
```

## Author

Leandro Perez, leandromperez@gmail.com

## License

RxHeartRateMonitors is available under the MIT license. See the LICENSE file for more info.
