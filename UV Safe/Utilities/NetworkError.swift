//
//  NetworkError.swift
//  UV Safe
//
//  Created by Shawn Patel on 5/12/19.
//  Copyright © 2019 Shawn Patel. All rights reserved.
//

import Foundation

enum NetworkError: Error, Equatable {
    case noInternetConnection
    case cannotProvideTravelInfo
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return NSLocalizedString("Unable to connect to the Internet. Check the device's Internet connection.", comment: "")
            
        case .cannotProvideTravelInfo:
            return NSLocalizedString("Cannot provide travel information to the selected location.", comment: "")
        }
    }
}
