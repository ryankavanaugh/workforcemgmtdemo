//
//  CalendarAttachmentComposerPreview.swift
//  SportsTeamSample
//
//  Created by Stefan Blos on 06.09.22.
//

import SwiftUI
import StreamChatSwiftUI
import StreamChat

struct CalendarAttachmentComposerPreview: View {
    
    @ObservedObject var attachmentsViewModel: AttachmentsViewModel
    var addedCustomAttachments: [CustomAttachment]
    var onCustomAttachmentTap: (CustomAttachment) -> Void
    
    var body: some View {
        VStack {
            ForEach(addedCustomAttachments) { attachment in
                if let payload = attachment.content.payload as? CalendarAttachmentPayload {
                    CalendarAttachmentPreview(
                        calendar: payload,
                        calendarAttachment: attachment,
                        onCustomAttachmentTap: onCustomAttachmentTap,
                        calendarAttachmentMode: .preview,
                        attachmentsViewModel: attachmentsViewModel
                    )
                }
                if let payload = attachment.content.payload as? ShiftAttachmentPayload {
                    HStack {
                        Text("Shift change request")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding()
                }
            }
        }
    }
}

struct CalendarAttachmentComposerPreview_Previews: PreviewProvider {
    static var previews: some View {
        CalendarAttachmentComposerPreview(
            attachmentsViewModel: AttachmentsViewModel(),
            addedCustomAttachments: [.calendarPreview, .calendarPreview]) { _ in }
    }
}

struct CalendarAttachmentPayload: AttachmentPayload, Identifiable {
    
    static let type: AttachmentType = .calendar
    
    var id: String = "\(UUID())"
    
    var suggestedDays: [Date]?
    var selectedDay: Date?
}

extension AttachmentType {
    static let calendar = Self(rawValue: "calendar")
    static let shift = Self(rawValue: "shift")
}

extension CustomAttachment {
    
    static var calendarPreview: CustomAttachment = CustomAttachment(
        id: UUID().uuidString,
        content: AnyAttachmentPayload(payload: CalendarAttachmentPayload.preview)
    )
}

extension CalendarAttachmentPayload {
    static var preview: CalendarAttachmentPayload = CalendarAttachmentPayload(suggestedDays: [Date()], selectedDay: nil)
}

struct ShiftAttachmentPayload: AttachmentPayload, Identifiable {
    
    static let type: AttachmentType = .shift
    
    var id: String = "\(UUID())"
    
    let user: String
    let title: String
    let date: Date
    
    var dateString: String {
        return formatter.string(from: date)
    }        
}

let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()
