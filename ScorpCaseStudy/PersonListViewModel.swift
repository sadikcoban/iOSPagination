//
//  PersonListViewModel.swift
//  ScorpCaseStudy
//
//  Created by Sadık Çoban on 27.02.2023.
//

import Foundation

final class PersonListViewModel {
    var personList = [Person]()
    private var currentNext: String?
    private(set) var isLoading = false
    private var consecutiveErrorCount = 0
    
    // used to prevent aggresive retries if there has been 3 consecutive errors during connection with api.
    var canLoadData: Bool {
        consecutiveErrorCount < 3
    }

    func loadData(paginate: Bool = false, _ completion: @escaping () -> () = {}) {
        if isLoading { return }
        isLoading = true
        if !paginate {
            currentNext = nil
        }
        DataSource.fetch(next: currentNext) {[weak self] response, error in
            defer {
                self?.isLoading = false
                completion()
            }

            if error != nil {
                self?.consecutiveErrorCount += 1
                return
            }
            guard let response, !response.people.isEmpty else {
                self?.consecutiveErrorCount = 0
                return
            }
            self?.consecutiveErrorCount = 0
            self?.currentNext = response.next
            if !paginate {
                self?.personList.removeAll()
            }
            self?.personList.append(contentsOf: response.people)
        }
    }
    
    
    
}
