import Foundation
import Combine
import WalletConnectKMS
import WalletConnectPairing

class PushMessageSubscriber {
    private let networkingInteractor: NetworkInteracting
    private let kms: KeyManagementServiceProtocol
    private let logger: ConsoleLogging
    private var publishers = [AnyCancellable]()
    var onPushMessage: ((_ message: PushMessage) -> Void)?

    init(networkingInteractor: NetworkInteracting,
         kms: KeyManagementServiceProtocol,
         logger: ConsoleLogging) {
        self.networkingInteractor = networkingInteractor
        self.kms = kms
        self.logger = logger
        subscribeForPushMessages()
    }

    private func subscribeForPushMessages() {
        let protocolMethod = PushMessageProtocolMethod()
        networkingInteractor.requestSubscription(on: protocolMethod)
            .sink { [unowned self] (payload: RequestSubscriptionPayload<PushMessage>) in
                logger.debug("Received Push Message")
                onPushMessage?(payload.request)

            }.store(in: &publishers)

    }
}
