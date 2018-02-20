[![Build Status](https://travis-ci.org/RxSwiftCommunity/RxSwiftExt.svg?branch=master)](https://travis-ci.org/RxSwiftCommunity/RxSwiftExt) ![pod](https://img.shields.io/cocoapods/v/RxSwiftExt.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

RxSwiftExt
===========

If you're using [RxSwift](https://github.com/ReactiveX/RxSwift), you may have encountered situations where the built-in operators do not bring the exact functionality you want. The RxSwift core is being intentionally kept as compact as possible to avoid bloat. This repository's purpose is to provide additional convenience operators.

Installation
===========

This branch of RxSwiftExt targets Swift 4.x and RxSwift 4.0.0 or later.

* If you're looking for the Swift 3 version of RxSwiftExt, please use version `2.5.1` of the framework.
* If your project is running on Swift 2.x, please use version `1.2` of the framework.


#### CocoaPods

Using Swift 4:

```
pod "RxSwiftExt"
```

Using Swift 3:

```
pod "RxSwiftExt", '2.5.1'
```

If you use Swift 2.x:

```
pod "RxSwiftExt", '1.2'
```

#### Carthage

Add this to your `Cartfile`

```
github "RxSwiftCommunity/RxSwiftExt"
```


Operators
===========

RxSwiftExt is all about adding operators to [RxSwift](https://github.com/ReactiveX/RxSwift)! Currently available operators:

* [unwrap](#unwrap)
* [ignore](#ignore)
* [ignoreWhen](#ignorewhen)
* [Observable.once](#once)
* [distinct](#distinct)
* [map](#map)
* [not](#not)
* [and](#and)
* [Observable.cascade](#cascade)
* [pairwise, nwise](#pairwise-nwise)
* [retry](#retry)
* [repeatWithBehavior](#repeatwithbehavior)
* [catchErrorJustComplete](#catcherrorjustcomplete)
* [pausable](#pausable)
* [pausableBuffered](#pausablebuffered)
* [apply](#apply)
* [filterMap](#filtermap)
* [Observable.fromAsync](#fromasync)

Two additional operators are available for `materialize()`'d sequences:

* [errors](#errors-elements)
* [elements](#errors-elements)

Read below for details about each operator.

Operator details
===========

#### unwrap

Unwrap optionals and filter out nil values.

```swift
  Observable.of(1,2,nil,Int?(4))
    .unwrap()
    .subscribe { print($0) }
```

```
next(1)
next(2)
next(4)
```

#### ignore

Ignore specific elements.

```swift
  Observable.from(["One","Two","Three"])
    .ignore("Two")
    .subscribe { print($0) }
```

```
next(One)
next(Three)
completed  
```

#### ignoreWhen

Ignore elements according to closure.

```swift
  Observable<Int>
    .of(1,2,3,4,5,6)
    .ignoreWhen { $0 > 2 && $0 < 6 }
    .subscribe { print($0) }
```
```
next(1)
next(2)
next(6)
completed
```

#### once

Send a next element exactly once to the first subscriber that takes it. Further subscribers get an empty sequence.

```swift
  let obs = Observable.once("Hello world")
  print("First")
  obs.subscribe { print($0) }
  print("Second")
  obs.subscribe { print($0) }
```
```
First
next(Hello world)
completed
Second
completed
```

#### distinct

Pass elements through only if they were never seen before in the sequence.

```swift
    Observable.of("a","b","a","c","b","a","d")
    .distinct()
    .subscribe { print($0) }
```
```
next(a)
next(b)
next(c)
next(d)
completed
```

#### map

Replace every element with the provided value.

```swift
Observable.of(1,2,3)
    .map(to: "Nope.")
    .subscribe { print($0) }
```
```
next(Nope.)
next(Nope.)
next(Nope.)
completed
```

#### not

Negate booleans.

```swift
Observable.just(false)
    .not()
    .subscribe { print($0) }
```

```
next(true)
completed
```

#### and

Verifies that every value emitted is `true`

```swift
Observable.of(true, true)
	.and()
	.subscribe { print($0) }
	
Observable.of(true, false)
	.and()
	.subscribe { print($0) }
	
Observable<Bool>.empty()
	.and()
	.subscribe { print($0) }
```

Returns a `Maybe<Bool>`:

```
success(true)
success(false)
completed
```

#### cascade

Sequentially cascade through a list of observables, dropping previous subscriptions as soon as an observable further down the list starts emitting elements.

```swift
let a = PublishSubject<String>()
let b = PublishSubject<String>()
let c = PublishSubject<String>()
Observable.cascade([a,b,c])
    .subscribe { print($0) }
a.onNext("a:1")
a.onNext("a:2")
b.onNext("b:1")
a.onNext("a:3")
c.onNext("c:1")
a.onNext("a:4")
b.onNext("b:4")
c.onNext("c:2")
```

```
next(a:1)
next(a:2)
next(b:1)
next(c:1)
next(c:2)
```

#### pairwise, nwise

Groups elements emitted by an Observable into arrays, where each array consists of the last N consecutive items; similar to a sliding window.

```swift
Observable.from([1, 2, 3, 4, 5, 6])
    .pairwise()
    .subscribe { print($0) }
```

```
next((1, 2))
next((2, 3))
next((3, 4))
next((4, 5))
next((5, 6))
completed
```

#### retry

Repeats the source observable sequence using given behavior in case of an error or until it successfully terminated. 
There are four behaviors with various predicate and delay options: `immediate`, `delayed`, `exponentialDelayed` and 
`customTimerDelayed`.

```swift
// in case of an error initial delay will be 1 second,
// every next delay will be doubled
// delay formula is: initial * pow(1 + multiplier, Double(currentAttempt - 1)), so multiplier 1.0 means, delay will doubled
_ = sampleObservable.retry(.exponentialDelayed(maxCount: 3, initial: 1.0, multiplier: 1.0), scheduler: delayScheduler)
    .subscribe(onNext: { event in
        print("Receive event: \(event)")
    }, onError: { error in
        print("Receive error: \(error)")
    })
```

```
Receive event: First
Receive event: Second
Receive event: First
Receive event: Second
Receive event: First
Receive event: Second
Receive error: fatalError
```

#### repeatWithBehavior

Repeats the source observable sequence using given behavior when it completes. This operator takes the same parameters as the [retry](#retry) operator.
There are four behaviors with various predicate and delay options: `immediate`, `delayed`, `exponentialDelayed` and `customTimerDelayed`.

```swift
// when the sequence completes initial delay will be 1 second,
// every next delay will be doubled
// delay formula is: initial * pow(1 + multiplier, Double(currentAttempt - 1)), so multiplier 1.0 means, delay will doubled
_ = completingObservable.repeatWithBehavior(.exponentialDelayed(maxCount: 3, initial: 1.0, multiplier: 1.2), scheduler: delayScheduler)
    .subscribe(onNext: { event in
        print("Receive event: \(event)")
})
```

```
Receive event: First
Receive event: Second
Receive event: First
Receive event: Second
Receive event: First
Receive event: Second
```

#### catchErrorJustComplete

Completes a sequence when an error occurs, dismissing the error condition

```swift
let _ = sampleObservable
    .do(onError: { print("Source observable emitted error \($0), ignoring it") })
    .catchErrorJustComplete()
    .subscribe {
        print ("\($0)")
}
```

```
next(First)
next(Second)
Source observable emitted error fatalError, ignoring it
completed
```

#### pausable

Pauses the elements of the source observable sequence unless the latest element from the second observable sequence is `true`.

```swift
let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)

let trueAtThreeSeconds = Observable<Int>.timer(3, scheduler: MainScheduler.instance).map { _ in true }
let falseAtFiveSeconds = Observable<Int>.timer(5, scheduler: MainScheduler.instance).map { _ in false }
let pauser = Observable.of(trueAtThreeSeconds, falseAtFiveSeconds).merge()

let pausedObservable = observable.pausable(pauser)

let _ = pausedObservable
    .subscribe { print($0) }
```

```
next(2)
next(3)
```

More examples are available in the project's Playground.

#### pausableBuffered

Pauses the elements of the source observable sequence unless the latest element from the second observable sequence is `true`. Elements emitted by the source observable are buffered (with a configurable limit) and "flushed" (re-emitted) when the observable resumes.

Examples are available in the project's Playground.

#### apply

Apply provides a unified mechanism for applying transformations on Observable
sequences, without having to extend ObservableType or repeating your
transformations. For additional rationale for this see
[discussion on github](https://github.com/RxSwiftCommunity/RxSwiftExt/issues/73)

```swift
// An ordinary function that applies some operators to its argument, and returns the resulting Observable
func requestPolicy(_ request: Observable<Void>) -> Observable<Response> {
    return request.retry(maxAttempts)
        .do(onNext: sideEffect)
        .map { Response.success }
        .catchError { error in Observable.just(parseRequestError(error: error)) }

// We can apply the function in the apply operator, which preserves the chaining style of invoking Rx operators
let resilientRequest = request.apply(requestPolicy)
```

#### filterMap

A common pattern in Rx is to filter out some values, then map the remaining ones to something else. `filterMap` allows you to do this in one step:

```swift
// keep only odd numbers and double them
Observable.of(1,2,3,4,5,6)
	.filterMap { number in
		(number % 2 == 0) ? .ignore : .map(number * 2)
	}
```

The sequence above keeps even numbers 2, 4, 6 and produces the sequence 4, 8, 12.

#### errors, elements

These operators only apply to observable serquences that have been materialized with the `materialize()` operator (from RxSwift core). `errors` returns a sequence of filtered error events, ommitting elements. `elements` returns a sequence of filtered element events, ommitting errors.

```swift
let imageResult = _chooseImageButtonPressed.asObservable()
    .flatMap { imageReceiver.image.materialize() }
    .share()

let image = imageResult
    .elements()
    .asDriver(onErrorDriveWith: .never())

let errorMessage = imageResult
    .errors()
    .map(mapErrorMessages)
    .unwrap()
    .asDriver(onErrorDriveWith: .never())
```

#### fromAsync

Turns simple asynchronous completion handlers into observable sequences. Suitable for use with existing asynchronous services which call a completion handler with only one parameter. Emits the result produced by the completion handler then completes.

```swift
func someAsynchronousService(arg1: String, arg2: Int, completionHandler:(String) -> Void) {
    // a service that asynchronously calls
	// the given completionHandler
}

let observableService = Observable
    .fromAsync(someAsynchronousService)

observableService("Foo", 0)
    .subscribe(onNext: { (result) in
        print(result)
    })
    .disposed(by: disposeBag)
```

## License

This library belongs to _RxSwiftCommunity_.

RxSwiftExt is available under the MIT license. See the LICENSE file for more info.
