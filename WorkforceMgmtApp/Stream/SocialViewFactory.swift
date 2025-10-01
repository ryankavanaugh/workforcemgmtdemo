
import Foundation
import StreamChatSwiftUI
import StreamChat
import SwiftUI

class SocialViewFactory: ViewFactory {
    
    @ObservedObject private var attachmentsViewModel: AttachmentsViewModel
    
    init(attachmentsViewModel: AttachmentsViewModel) {
        self.attachmentsViewModel = attachmentsViewModel
    }
    
    @Injected(\.chatClient) var chatClient: ChatClient
    
    func makeChannelListHeaderViewModifier(title: String) -> SocialChannelModifier {
        SocialChannelModifier(title: "Chick-fil-A: Atlanta", currentUserController: chatClient.currentUserController(), viewFactory: self)
    }
    
    func makeCustomAttachmentViewType(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat,
        scrolledId: Binding<String?>
    ) -> some View {
        // get possible attachments
        let paymentAttachments = message.attachments(payloadType: PaymentAttachmentPayload.self)
        let paymentState = PaymentState(rawValue: message.extraData["paymentState"]?.stringValue ?? "")
        let paymentDate = message.extraData["paymentDate"]?.stringValue
        let calendarAttachments = message.attachments(payloadType: CalendarAttachmentPayload.self)
        let shiftAttachments = message.attachments(payloadType: ShiftAttachmentPayload.self)
        
        return VStack {
            ForEach(paymentAttachments.indices) { [weak self] index in
                if let viewModel = self?.attachmentsViewModel, let paymentState {
                    PaymentAttachmentView(
                        viewModel: viewModel,
                        payload: paymentAttachments[index].payload,
                        paymentState: paymentState,
                        paymentDate: paymentDate,
                        messageId: message.id
                    )
                }
            }
            
            ForEach(0 ..< calendarAttachments.count) { [weak self] i in
                let calendar = calendarAttachments[i]
                if let viewModel = self?.attachmentsViewModel {
                    CalendarAttachmentPreview(
                        calendar: calendar.payload,
                        calendarAttachment: CustomAttachment(
                            id: "\(calendar.id)",
                            content: AnyAttachmentPayload(payload: calendar.payload)
                        ),
                        onCustomAttachmentTap: { _ in },
                        messageId: message.id,
                        attachmentsViewModel: viewModel
                    )
                }
            }
            
            ForEach(0 ..< shiftAttachments.count) { [weak self] i in
                let shift = shiftAttachments[i]
                if let viewModel = self?.attachmentsViewModel {
                    HStack(alignment: .top) {
                        Image(systemName: "calendar")
                        Text("\(self?.chatClient.currentUserId ?? "")'s request for the \(shift.title) shift has been submitted for Manager approval on \(shift.dateString)")
                    }
                    .padding()
                    .background(
                        Color(uiColor: .secondarySystemBackground),
                        in: RoundedRectangle(
                            cornerRadius: 10,
                            style: .continuous
                        )
                    )
                }
            }
        }
    }
    
    func makeLeadingComposerView(state: Binding<PickerTypeState>, channelConfig: ChannelConfig?) -> some View {
        attachmentsViewModel.closeAttachments = {
            state.wrappedValue = .expanded(.none)
        }
        return LeadingComposerView(viewModel: attachmentsViewModel, pickerTypeState: state, channelConfig: channelConfig)
    }
    
    func makeCustomAttachmentView(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void
    ) -> some View {
//        CreateInstaAttachmentView(onCustomAttachmentTap: onCustomAttachmentTap)
        CustomAttachmentView(selectedCustomAttachment: $attachmentsViewModel.selectedCustomAttachment, viewModel: attachmentsViewModel, onCustomAttachmentTap: onCustomAttachmentTap)
    }
    
    func makeAttachmentSourcePickerView(selected: AttachmentPickerState, onPickerStateChange: @escaping (AttachmentPickerState) -> Void) -> some View {
//        MyAttachmentSourcePickerView(
//            selected: selected,
//            selectedCustomAttachment: $attachmentsViewModel.selectedCustomAttachment,
//            onTap: onPickerStateChange
//        )
        attachmentsViewModel.onPickerStateChange = onPickerStateChange
        return EmptyView()
    }
    
    func makeCustomAttachmentPreviewView(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void
    ) -> some View {
        let paymentAttachments = addedCustomAttachments.compactMap { $0.content.payload as? PaymentAttachmentPayload }
        let calendarAttachments = addedCustomAttachments.compactMap { $0.content.payload as? CalendarAttachmentPayload }
        let shiftAttachments = addedCustomAttachments.compactMap { $0.content.payload as? ShiftAttachmentPayload }
        return VStack {
            // Show Payment attachments - if any
            ForEach(paymentAttachments) { paymentAttachment in
                PaymentAttachmentPreview(payload: paymentAttachment)
            }
            ForEach(calendarAttachments) { attachment in
                HStack {
                    Image(systemName: "calendar")
                    VStack {
                        ForEach(attachment.suggestedDays ?? [], id: \.self) { suggestedDay in
                            Text(self.dateFormatter.string(from: suggestedDay))
                                .foregroundColor(.black)
                        }
                    }
//                    if let selectedDay = attachment.selectedDay {
//                        Text(self.dateFormatter.string(from: selectedDay))
//                    }
                    Spacer()
                }
                .padding(.all, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.lightGray), lineWidth: 1)
                )
                .cornerRadius(16)
                .padding(.all, 4)
                .padding(.vertical, 4)
            }
            ForEach(shiftAttachments) { _ in
                HStack {
                    Text("Shift change request")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.all, 4)
                    Spacer()
                }
            }
        }
    }
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
}
