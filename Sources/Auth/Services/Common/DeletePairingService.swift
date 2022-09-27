import Foundation
import WalletConnectNetworking
import JSONRPC
import WalletConnectKMS
import WalletConnectUtils
import WalletConnectPairing

class DeletePairingService {
    enum Errors: Error {
        case pairingNotFound
    }
    private let networkingInteractor: NetworkInteracting
    private let kms: KeyManagementServiceProtocol
    private let pairingStorage: WCPairingStorage
    private let logger: ConsoleLogging

    init(networkingInteractor: NetworkInteracting,
         kms: KeyManagementServiceProtocol,
         pairingStorage: WCPairingStorage,
         logger: ConsoleLogging) {
        self.networkingInteractor = networkingInteractor
        self.kms = kms
        self.pairingStorage = pairingStorage
        self.logger = logger
    }

    func delete(topic: String) async throws {
        guard pairingStorage.hasPairing(forTopic: topic) else { throw Errors.pairingNotFound}
        let protocolMethod = PairingDeleteProtocolMethod()
        let reason = AuthError.userDisconnected
        logger.debug("Will delete pairing for reason: message: \(reason.message) code: \(reason.code)")
        let request = RPCRequest(method: protocolMethod.method, params: reason)
        try await networkingInteractor.request(request, topic: topic, protocolMethod: protocolMethod)
        pairingStorage.delete(topic: topic)
        kms.deleteSymmetricKey(for: topic)
        networkingInteractor.unsubscribe(topic: topic)
    }
}
