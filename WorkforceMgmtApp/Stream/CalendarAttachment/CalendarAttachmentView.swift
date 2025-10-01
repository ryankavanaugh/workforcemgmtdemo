//
//  CalendarAttachmentView.swift
//  SportsTeamSample
//
//  Created by Stefan Blos on 06.09.22.
//

import SwiftUI
import StreamChat

enum CalendarAttachmentMode {
    case preview, suggested, picked
}

struct CalendarAttachmentView: View {
    
    var calendarAttachmentState: CalendarAttachmentMode
    var suggestedDays: [Date]?
    var selectedDate: Date?
    var messageId: MessageId?
    @ObservedObject var attachmentsViewModel: AttachmentsViewModel
    
    var body: some View {
        switch calendarAttachmentState {
        case .preview:
            PreviewCalendarView(suggestedDays: suggestedDays ?? [])
        case .suggested:
            SuggestedCalendarView(
                suggestedDays: suggestedDays ?? [],
                messageId: messageId,
                attachmentsViewModel: attachmentsViewModel
            )
        case .picked:
            PickedCalendarView(selectedDate: selectedDate ?? Date())
        }
    }
}

//struct CalendarAttachmentView_Previews: PreviewProvider {
//    static var previews: some View {
//        List {
//            CalendarAttachmentView(calendarAttachmentState: .preview)
//            
//            CalendarAttachmentView(calendarAttachmentState: .suggested)
//            
//            CalendarAttachmentView(calendarAttachmentState: .picked)
//        }
//    }
//}
