//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import CommonCrypto
import Foundation

/// Implements HMAC-SHA-256.
public struct HmacContext {
    private var context = CCHmacContext()
    private var isFinal = false

    public init(key: Data) throws {
        key.withUnsafeBytes {
            CCHmacInit(&context, CCHmacAlgorithm(kCCHmacAlgSHA256), $0.baseAddress, $0.count)
        }
    }

    /// - parameter length: If non-nil, only that many bytes of the input will be read. If nil, the entire input is read.
    public mutating func update(_ data: Data, length: Int? = nil) throws {
        try data.withUnsafeBytes { try update(bytes: $0, length: length) }
    }

    /// - parameter length: If non-nil, only that many bytes of the input will be read. If nil, the entire input is read.
    public mutating func update(bytes: UnsafeRawBufferPointer, length: Int? = nil) throws {
        guard !isFinal else {
            throw OWSAssertionError("Unexpectedly attempted to update a finalized hmac context")
        }

        CCHmacUpdate(&context, bytes.baseAddress, length ?? bytes.count)
    }

    public mutating func finalize() throws -> Data {
        guard !isFinal else {
            throw OWSAssertionError("Unexpectedly to finalize a finalized hmac context")
        }

        isFinal = true

        var mac = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        mac.withUnsafeMutableBytes {
            CCHmacFinal(&context, $0.baseAddress)
        }
        return mac
    }
}