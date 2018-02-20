//
//  FlatMap+Weak.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/1/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import RxSwift
//taken in part from https://medium.com/@otbivnoe/improvements-of-flatmap-function-in-rxswift-5d70add0fc88


extension ObservableType {
    
    fileprivate func weakify<A: AnyObject, B, O: ObservableType>(_ obj: A, method: ((A) -> (B) throws -> O)?) -> ((B) -> Observable<O.E>) {
        return { [weak obj] (value) -> Observable<O.E> in
            
            guard let obj = obj, let method = method else { return .empty() }
            
            let maybeResult = try? method(obj)(value).asObservable()
            return maybeResult ?? .empty()
        }
    }

    func flatMapLatest<A: AnyObject, O: ObservableType>(weak obj: A, _ on: @escaping (A) -> (Self.E) throws -> O) -> Observable<O.E> {
        return self.flatMapLatest(weakify(obj, method: on))
    }
    
    func flatMap<A: AnyObject, O: ObservableType>(weak obj: A, _ selector: @escaping (A) -> (Self.E) throws -> O) -> Observable<O.E> {
        return self.flatMap(weakify(obj, method: selector))
    }
    
    
    public func flatMap<A: AnyObject, O: ObservableType>(weak obj: A, selector: @escaping (A, Self.E) throws -> O) -> Observable<O.E> {
        return flatMap { [weak obj] value -> Observable<O.E> in
            try obj.map { try selector($0, value).asObservable() } ?? .empty()
        }
    }
    
    public func flatMapFirst<A: AnyObject, O: ObservableType>(weak obj: A, selector: @escaping (A, Self.E) throws -> O) -> Observable<O.E> {
        return flatMapFirst { [weak obj] value -> Observable<O.E> in
            try obj.map { try selector($0, value).asObservable() } ?? .empty()
        }
    }
   
    public func flatMapLatest<A: AnyObject, O: ObservableType>(weak obj: A, selector: @escaping (A, Self.E) throws -> O) -> Observable<O.E> {
        return flatMapLatest { [weak obj] value -> Observable<O.E> in
            try obj.map { try selector($0, value).asObservable() } ?? .empty()
        }
    }
   
}

struct FlatMapError : Error{}

extension PrimitiveSequenceType where TraitType == SingleTrait {
   
    public func flatMap<A:AnyObject, R>(weak obj:A, _ selector: @escaping (A, ElementType) throws -> Single<R>)
        -> Single<R> {
            return self.flatMap{ [weak obj] value -> Single<R> in
                guard let o = obj else{return .error(FlatMapError())}

                do {
                    let r = try selector(o, value)
                    return r
                }
                catch let e {
                    return .error(e)
                }
            }
    }
}

