import Foundation
import XCTest
@testable import Chat
import WalletConnectUtils
@testable import WalletConnectKMS
import WalletConnectRelay
import Combine

final class ChatTests: XCTestCase {
    var invitee: Chat!
    var inviter: Chat!
    var registry: KeyValueRegistry!
    private var publishers = [AnyCancellable]()

    override func setUp() {
        registry = KeyValueRegistry()
        invitee = makeClient(prefix: "🦖 Registered")
        inviter = makeClient(prefix: "🍄 Inviter")
    }

    private func waitClientsConnected() async {
        let group = DispatchGroup()
        group.enter()
        invitee.socketConnectionStatusPublisher.sink { status in
            if status == .connected {
                group.leave()
            }
        }.store(in: &publishers)

        group.enter()
        inviter.socketConnectionStatusPublisher.sink { status in
            if status == .connected {
                group.leave()
            }
        }.store(in: &publishers)
        group.wait()
        return
    }

    func makeClient(prefix: String) -> Chat {
        let logger = ConsoleLogger(suffix: prefix, loggingLevel: .debug)
        let relayHost = "relay.walletconnect.com"
        let projectId = "8ba9ee138960775e5231b70cc5ef1c3a"
        let keychain = KeychainStorageMock()
        let relayClient = RelayClient(relayHost: relayHost, projectId: projectId, keychainStorage: keychain, socketFactory: SocketFactory(), logger: logger)
        return Chat(registry: registry, relayClient: relayClient, kms: KeyManagementService(keychain: keychain), logger: logger, keyValueStorage: RuntimeKeyValueStorage())
    }

    func testInvite() async {
        await waitClientsConnected()
        let inviteExpectation = expectation(description: "invitation expectation")
        let account = Account(chainIdentifier: "eip155:1", address: "0x3627523167367216556273151")!
        let pubKey = try! await invitee.register(account: account)
        try! await inviter.invite(publicKey: pubKey, openingMessage: "", account: Account("eip155:1:33e32e32")!)
        invitee.invitePublisher.sink { _ in
            inviteExpectation.fulfill()
        }.store(in: &publishers)
        wait(for: [inviteExpectation], timeout: 4)
    }

//    func testAcceptAndCreateNewThread() async {
//        await waitClientsConnected()
//        let newThreadInviterExpectation = expectation(description: "new thread on inviting client expectation")
//        let newThreadinviteeExpectation = expectation(description: "new thread on invitee client expectation")
//        let account = Account(chainIdentifier: "eip155:1", address: "0x3627523167367216556273151")!
//        let pubKey = try! await invitee.register(account: account)
//        try! await inviter.invite(publicKey: pubKey, openingMessage: "opening message")
//
//        invitee.invitePublisher.sink { [unowned self] inviteEnvelope in
//            Task {try! await invitee.accept(inviteId: inviteEnvelope.pubKey)}
//        }.store(in: &publishers)
//
//        invitee.newThreadPublisher.sink { _ in
//            newThreadinviteeExpectation.fulfill()
//        }.store(in: &publishers)
//
//        inviter.newThreadPublisher.sink { _ in
//            newThreadInviterExpectation.fulfill()
//        }.store(in: &publishers)
//
//        wait(for: [newThreadinviteeExpectation, newThreadInviterExpectation], timeout: 30)
//    }
//
//    func testMessage() async {
//        await waitClientsConnected()
//        let messageExpectation = expectation(description: "message received")
//        messageExpectation.expectedFulfillmentCount = 2
//        let message = "message"
//
//        let account = Account(chainIdentifier: "eip155:1", address: "0x3627523167367216556273151")!
//        let pubKey = try! await invitee.register(account: account)
//        try! await inviter.invite(publicKey: pubKey, openingMessage: "opening message")
//
//        invitee.invitePublisher.sink { [unowned self] inviteEnvelope in
//            Task {try! await invitee.accept(inviteId: inviteEnvelope.pubKey)}
//        }.store(in: &publishers)
//
//        invitee.newThreadPublisher.sink { [unowned self] thread in
//            Task {try! await invitee.message(topic: thread.topic, message: message)}
//        }.store(in: &publishers)
//
//        inviter.newThreadPublisher.sink { [unowned self] thread in
//            Task {try! await inviter.message(topic: thread.topic, message: message)}
//        }.store(in: &publishers)
//
//        inviter.messagePublisher.sink { message in
//            messageExpectation.fulfill()
//        }.store(in: &publishers)
//
//        invitee.messagePublisher.sink { message in
//            messageExpectation.fulfill()
//        }.store(in: &publishers)
//
//        wait(for: [messageExpectation], timeout: 35)
//    }
}
