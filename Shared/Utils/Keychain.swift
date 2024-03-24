import Foundation
import OSLog

public actor Keychain {
    private static let log = Logger("Keychain")
    private static let service = "GoogleSheetsWidget" // Bundle.main.bundleIdentifier! // app vs widget bundle idenfiers are different
    private static let group = "group.GoogleSheetsWidget" // FIXME: MUST be synced with actual app group manually

    public static func get(_ key: String) -> String? {
        var result: CFTypeRef?
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecAttrAccessGroup: group,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            let message = String(SecCopyErrorMessageString(status, nil) ?? "unknown" as CFString)
            log.warning("can not retrieve '\(key)' from keychain because: '\(message)'")
            return nil
        }
        
        return value
    }

    public static func set(_ key: String, _ value: String?) {
        guard let value = value else {
            log.warning("removing '\(key)' from keychain because: nil value were passed")
            delete(key)
            return
        }
        guard let data = value.data(using: .utf8) else {
            log.warning("can not set new value to '\(key)' because: empty value given")
            return
        }

        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup: group,
            kSecValueData as String: data
        ] as CFDictionary
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query, nil)
        
        if status == errSecSuccess {
            // log.info("new value for \(key) is set")
        } else {
            let message = String(SecCopyErrorMessageString(status, nil) ?? "unknown" as CFString)
            log.warning("can not set new value for '\(key)' because: '\(message)'")
        }
    }

    public static func delete(_ key: String) {
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecAttrAccessGroup: group
        ] as CFDictionary)
        
        if status == errSecSuccess {
            // log.info("removed '\(key)' from keychain")
        } else {
            let message = String(SecCopyErrorMessageString(status, nil) ?? "unknown" as CFString)
            log.warning("can not remove '\(key)' because: '\(message)'")
        }
    }
}
