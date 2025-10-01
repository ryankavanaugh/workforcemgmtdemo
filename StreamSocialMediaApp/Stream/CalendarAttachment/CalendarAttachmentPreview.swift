//
//  CalendarAttachmentPreview.swift
//  SportsTeamSample
//
//  Created by Stefan Blos on 06.09.22.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct CalendarAttachmentPreview: View {
    
    var calendar: CalendarAttachmentPayload
    var calendarAttachment: CustomAttachment
    var onCustomAttachmentTap: (CustomAttachment) -> Void
    var calendarAttachmentMode: CalendarAttachmentMode = .suggested
    var messageId: MessageId?
    @ObservedObject var attachmentsViewModel: AttachmentsViewModel
    
    var body: some View {
        CalendarAttachmentView(
            calendarAttachmentState: calendarAttachmentMode,
            suggestedDays: calendar.suggestedDays,
            messageId: messageId,
            attachmentsViewModel: attachmentsViewModel
        )
    }
}

//struct CalendarAttachmentPreview_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarAttachmentPreview(calendar: .preview, calendarAttachment: .calendarPreview) { _ in }
//    }
//}
