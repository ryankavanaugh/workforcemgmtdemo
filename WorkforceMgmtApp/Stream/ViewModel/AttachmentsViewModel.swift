//
//  AttachmentsViewModel.swift
//  StreamSocialMediaApp
//
//  Created by Stefan Blos on 19.05.23.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

class AttachmentsViewModel: ChatChannelListViewModel {
    
    @Injected(\.chatClient) var chatClient
    
    @Published var selectedCustomAttachment: SelectedCustomAttachment = .none
    @Published var confettiTrigger = 0
    
    var onPickerStateChange: ((AttachmentPickerState) -> Void)?
    var closeAttachments: (() -> Void)?
    
    func tryCallingPickerStateChange() {
        if let onPickerStateChange {
            onPickerStateChange(.custom)
        }
    }
    
    func sendCustomAttachmentMessage() {
        guard let selectedChannelId = selectedChannel?.id else {
            print("Selected channel ID couldn't be retrieved")
            return
        }
        let channelId = ChannelId(type: .messaging, id: selectedChannelId)
        
        chatClient.channelController(for: channelId).createNewMessage(text: "", attachments: [AnyAttachmentPayload(payload: InstaAttachmentPayload())])
    }
    
    var channelController: ChatChannelController? {
        guard let selectedChannelId = selectedChannel?.id else {
            print("Selected channel ID couldn't be retrieved")
            return nil
        }
        let channelId = ChannelId(type: .messaging, id: selectedChannelId)
        return chatClient.channelController(for: channelId)
    }
    
    func requestPayment(amount: Int) {
        guard let selectedChannelId = selectedChannel?.id else {
            print("Selected channel ID couldn't be retrieved")
            return
        }
        let channelId = ChannelId(type: .messaging, id: selectedChannelId)
        let payloadAttachment = PaymentAttachmentPayload(amount: amount)
        let extraData: [String: RawJSON] = [
            "paymentState": .string(PaymentState.requested.rawValue)
        ]
        
        chatClient.channelController(for: channelId).createNewMessage(
            text: "",
            attachments: [AnyAttachmentPayload(payload: payloadAttachment)],
            extraData: extraData
        )
        
        withAnimation {
            if let closeAttachments {
                closeAttachments()
            }
        }
    }
    
    func updatePaymentPaid(messageId: MessageId, amount: Int) {
        guard let selectedChannelId = selectedChannel?.id else {
            print("Selected channel ID couldn't be retrieved")
            return
        }
        
        let channelId = ChannelId(type: .messaging, id: selectedChannelId)
        
        let messageController = chatClient.messageController(
            cid: channelId,
            messageId: messageId
        )
        
        let extraData: [String: RawJSON] = [
            "paymentState": .string(PaymentState.done.rawValue),
            "paymentDate": .string(Date().formatted())
        ]
        
        messageController.editMessage(text: "", extraData: extraData)
    }
    
    func messageEditing(messageId: MessageId) {
        guard let selectedChannelId = selectedChannel?.id else {
            print("Selected channel ID couldn't be retrieved")
            return
        }
        
        let channelId = ChannelId(type: .messaging, id: selectedChannelId)
        
        let messageController = chatClient.messageController(cid: channelId, messageId: messageId)
        
        messageController.editMessage(text: "") { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
}
