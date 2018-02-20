//
//  UITableViewCell+Rx.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 12/13/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//taken from https://github.com/ReactiveX/RxSwift/issues/821
private var prepareForReuseBag: Int8 = 0

extension Reactive where Base: UITableViewCell {
    public var prepareForReuse: Observable<Void> {
        return Observable.of(sentMessage(#selector(UITableViewCell.prepareForReuse)).map { _ in () }, deallocated).merge()
    }
    
    public var disposeBag: DisposeBag {
        MainScheduler.ensureExecutingOnScheduler()
        
        if let bag = objc_getAssociatedObject(base, &prepareForReuseBag) as? DisposeBag {
            return bag
        }
        
        let bag = DisposeBag()
        objc_setAssociatedObject(base, &prepareForReuseBag, bag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        
        _ = sentMessage(#selector(UITableViewCell.prepareForReuse))
            .subscribe(onNext: { [weak base] _ in
                let newBag = DisposeBag()
                objc_setAssociatedObject(base as Any, &prepareForReuseBag, newBag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            })
        
        return bag
    }
}

extension Reactive where Base: UITableViewHeaderFooterView {
    public var prepareForReuse: Observable<Void> {
        return Observable.of(sentMessage(#selector(UITableViewHeaderFooterView.prepareForReuse)).map { _ in () }, deallocated).merge()
    }
    
    public var disposeBag: DisposeBag {
        MainScheduler.ensureExecutingOnScheduler()
        
        if let bag = objc_getAssociatedObject(base, &prepareForReuseBag) as? DisposeBag {
            return bag
        }
        
        let bag = DisposeBag()
        objc_setAssociatedObject(base, &prepareForReuseBag, bag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        
        _ = sentMessage(#selector(UITableViewHeaderFooterView.prepareForReuse))
            .subscribe(onNext: { [weak base] _ in
                let newBag = DisposeBag()
                objc_setAssociatedObject(base as Any, &prepareForReuseBag, newBag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            })
        
        return bag
    }
}
