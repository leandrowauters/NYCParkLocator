//
//  Extensions.swift
//  NYCParkLocator
//
//  Created by Leandro Wauters on 8/24/21.
//

import UIKit

extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, completion: @escaping(T?, String?) -> Void) {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            let parks =  try decoder.decode(T.self, from: data)
            completion(parks, nil)
        } catch DecodingError.keyNotFound(let key, let context) {
            let error = "Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)"
            completion(nil, error)
        } catch DecodingError.typeMismatch(_, let context) {
            let error = "Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)"
            completion(nil, error)
        } catch DecodingError.valueNotFound(let type, let context) {
            let error = "Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)"
            completion(nil, error)
        } catch DecodingError.dataCorrupted(_) {
            let error = "Failed to decode \(file) from bundle because it appears to be invalid JSON"
            completion(nil, error)
        } catch {
            let error = "Failed to decode \(file) from bundle: \(error.localizedDescription)"
            completion(nil, error)
        }
    }
}

extension UIViewController {
    public func showAlert(title: String?, message: String?, handler: ((UIAlertAction) -> Void)?) {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
      let okAction = UIAlertAction(title: "Ok", style: .default, handler: handler)

        alertController.addAction(okAction)
        alertController.addAction(cancel)
        
      present(alertController, animated: true, completion: nil)
    }
    
    public func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

