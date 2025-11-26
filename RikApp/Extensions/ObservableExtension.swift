//
//  ObservableExtension.swift
//  RikApp
//
//  Created by AI on 26.11.2025.
//

import Foundation
import RxSwift
import BusinessLogicFramework

/// Создает Observable из async функции
func observableFromAsync<T>(_ asyncFunction: @escaping () async -> T?) -> Observable<T> {
    return Observable<T>.create { observer in
        let task = Task {
            do {
                let result = await asyncFunction()
                if let value = result {
                    observer.onNext(value)
                    observer.onCompleted()
                } else {
                    observer.onError(NSError(domain: "ObservableExtension", code: 1, userInfo: [NSLocalizedDescriptionKey: "Async function returned nil"]))
                }
            }
        }
        return Disposables.create { task.cancel() }
    }
}

extension DataService {
    /// Загружает все данные через RxSwift Observable
    func loadAllDataObservable() -> Observable<DataResult> {
        return observableFromAsync {
            await self.loadAllData()
        }
    }
    
    /// Принудительное обновление всех данных через RxSwift Observable
    func refreshAllDataObservable() -> Observable<DataResult> {
        return observableFromAsync {
            await self.refreshAllData()
        }
    }
}
