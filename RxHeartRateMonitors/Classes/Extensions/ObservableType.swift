//
//  ObservableType.swift
//  Nimble
//
//  Created by Leandro Perez on 18/01/2018.
//

import Foundation
import RxSwift

extension ObservableType {
    public func catchErrorAndRetry(handler: @escaping (Error) throws -> Void) -> RxSwift.Observable<Self.E> {
        return self.catchError { error in
            try handler(error)
            return Observable.error(error)
            }
            .retry()
    }
}

public protocol OptionalProtocol {
    associatedtype WrappedType
    func unwrap() -> WrappedType
    func isNil() -> Bool
}

extension Optional: OptionalProtocol {
    public typealias WrappedType = Wrapped
    public func  unwrap() -> Wrapped {
        return self!
    }

    public func  isNil() -> Bool {
        return self == nil
    }
}

public extension ObservableType  where E : OptionalProtocol {
    func  noNils() -> Observable<Self.E.WrappedType> {
        return self.filter {!$0.isNil()}.map {$0.unwrap()}
    }
}

public extension PrimitiveSequence where TraitType == SingleTrait, E : OptionalProtocol {
    func  noNils() ->  PrimitiveSequence<SingleTrait, E.WrappedType> {
        return self.asObservable().noNils().asSingle()
    }
}
