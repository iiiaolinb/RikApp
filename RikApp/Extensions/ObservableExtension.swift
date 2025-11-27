//
//  ObservableExtension.swift
//  RikApp
//
//  Created by AI on 26.11.2025.
//

import Foundation
import RxSwift
import BusinessLogicFramework

/// Создает Observable из async функции, которая может выбрасывать ошибки
func observableFromAsync<T>(_ asyncFunction: @escaping () async throws -> T) -> Observable<T> {
    return Observable<T>.create { observer in
        let task = Task {
            do {
                let result = try await asyncFunction()
                observer.onNext(result)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
        }
        return Disposables.create { task.cancel() }
    }
}

extension DataService {
    /// Загружает все данные через RxSwift Observable
    func loadAllDataObservable() -> Observable<DataResult> {
        return observableFromAsync {
            try await self.loadAllData()
        }
    }
    
    /// Принудительное обновление всех данных через RxSwift Observable
    func refreshAllDataObservable() -> Observable<DataResult> {
        return observableFromAsync {
            try await self.refreshAllData()
        }
    }
}
