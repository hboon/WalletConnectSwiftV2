import Foundation
import WalletConnectNetworking

public class EchoClient {
    private let registerService: EchoRegisterService
    private let decryptionService: DecryptionService

    init(registerService: EchoRegisterService,
         decryptionService: DecryptionService) {
        self.registerService = registerService
        self.decryptionService = decryptionService
    }

    public func register(deviceToken: Data) async throws {
        try await registerService.register(deviceToken: deviceToken)
    }

    public func decryptMessage(topic: String, ciphertext: String) throws -> String {
        try decryptionService.decryptMessage(topic: topic, ciphertext: ciphertext)
    }
}
