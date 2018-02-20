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
