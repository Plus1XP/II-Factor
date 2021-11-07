//
//  BiometricService.swift
//  Authenticator
//
//  Created by Plus1XP on 04/06/2021.
//  Copyright © 2021 Bing Jeung. All rights reserved.
//

import SwiftUI
import LocalAuthentication

class BiometricService : ObservableObject{
    private let context = LAContext()
    private let policy: LAPolicy
    private let localizedReason: String
    
    private var error: NSError?
    
    init(policy: LAPolicy = .deviceOwnerAuthentication,
         localizedReason: String = "Verify your Identity",
         localizedFallbackTitle: String = "Enter Device Passcode",
         localizedCancelTitle: String = "Cancel") {
        self.policy = policy
        self.localizedReason = localizedReason
        context.localizedFallbackTitle = localizedFallbackTitle
        context.localizedCancelTitle = localizedCancelTitle
    }
    
    enum BiometricType {
        case none
        case touchID
        case faceID
        case unknown
    }
    
    enum BiometricError: LocalizedError {
        case authenticationFailed
        case userCancel
        case userFallback
        case biometryNotAvailable
        case biometryNotEnrolled
        case biometryLockout
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .authenticationFailed: return "There was a problem verifying your identity."
            case .userCancel: return "You pressed cancel."
            case .userFallback: return "You pressed password."
            case .biometryNotAvailable: return "Face ID/Touch ID is not available."
            case .biometryNotEnrolled: return "Face ID/Touch ID is not set up."
            case .biometryLockout: return "Face ID/Touch ID is locked."
            case .unknown: return "Face ID/Touch ID may not be configured"
            }
        }
    }
    
    private func biometricType(for type: LABiometryType) -> BiometricType {
        switch type {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return .unknown
        }
    }
    
    private func biometricError(from nsError: NSError) -> BiometricError {
        let error: BiometricError
        
        switch nsError {
        case LAError.authenticationFailed:
            error = .authenticationFailed
        case LAError.userCancel:
            error = .userCancel
        case LAError.userFallback:
            error = .userFallback
        case LAError.biometryNotAvailable:
            error = .biometryNotAvailable
        case LAError.biometryNotEnrolled:
            error = .biometryNotEnrolled
        case LAError.biometryLockout:
            error = .biometryLockout
        default:
            error = .unknown
        }
        
        return error
    }
    
    func setBiometricIcon() -> Image {
        context.canEvaluatePolicy(policy, error: &error)
        let type = context.biometryType
        switch type {
        case .touchID:
            return Image(systemName: "touchid")
        case .faceID:
            return Image(systemName: "faceid")
        default:
            return Image(systemName: "lock")
        }
    }
    
    func ValidateBiometrics() -> Void {
        canEvaluate { (canEvaluate, _, canEvaluateError) in
            guard canEvaluate else {
                // Face ID/Touch ID may not be available or configured
                debugPrint("authentication not available")
                return
            }
            evaluate { (success, error) in
                guard success else {
                    // Face ID/Touch ID may not be configured
                    debugPrint("authentication not successful")
                    return
                }
                // You are successfully verified
                debugPrint("authentication successful")
            }
        }
    }
    
    func canEvaluate(completion: (Bool, BiometricType, BiometricError?) -> Void) {
        // Asks Context if it can evaluate a Policy
        // Passes an Error pointer to get error code in case of failure
        guard context.canEvaluatePolicy(policy, error: &error) else {
            // Extracts the LABiometryType from Context
            // Maps it to our BiometryType
            let type = biometricType(for: context.biometryType)
            
            // Unwraps Error
            // If not available, sends false for Success & nil in BiometricError
            guard let error = error else {
                return completion(false, type, nil)
            }
            
            // Maps error to our BiometricError
            return completion(false, type, biometricError(from: error))
        }
        
        // Context can evaluate the Policy
        completion(true, biometricType(for: context.biometryType), nil)
    }
    
    func evaluate(completion: @escaping (Bool, BiometricError?) -> Void) {
        // Asks Context to evaluate a Policy with a LocalizedReason
        context.evaluatePolicy(policy, localizedReason: localizedReason) { [weak self] success, error in
            // Moves to the main thread because completion triggers UI changes
            DispatchQueue.main.async {
                if success {
                    // Context successfully evaluated the Policy
                    completion(true, nil)
                } else {
                    // Unwraps Error
                    // If not available, sends false for Success & nil for BiometricError
                    guard let error = error else { return completion(false, nil) }
                    
                    // Maps error to our BiometricError
                    completion(false, self?.biometricError(from: error as NSError))
                }
            }
        }
    }
}
