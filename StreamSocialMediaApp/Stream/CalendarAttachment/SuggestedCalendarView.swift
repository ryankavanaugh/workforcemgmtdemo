//
//  SuggestedCalendarView.swift
//  SportsTeamSample
//
//  Created by Stefan Blos on 07.09.22.
//

import SwiftUI
import StreamChat

struct SuggestedCalendarView: View {
    
    @Environment(\.calendar) var calendar
    
    @State private var selectedDay: Date? = nil
    
    var suggestedDays: [Date]
    var messageId: MessageId?
    @ObservedObject var attachmentsViewModel: AttachmentsViewModel
    
    private var month: DateInterval {
        calendar.dateInterval(of: .month, for: Date())!
    }
    
    private var months: [Date] {
        calendar.generateDates(
            inside: month,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }
    
    var buttonDisabled: Bool {
        selectedDay == nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Suggested Days")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let month = months.first {
                MonthView(month: month) { date in
                    Text("30")
                        .font(.caption)
                        .hidden()
                        .padding(4)
                        .background(
                            date == selectedDay
                            ? Color.red
                            :
                            suggestedDays.contains(date) ? Color.blue : Color.clear, in: Circle())
                        .padding(.vertical, 2)
                        .overlay(
                            Button(action: {
                                if suggestedDays.contains(date) {
                                    selectedDay = date
                                }
                            }, label: {
                                Text(String(self.calendar.component(.day, from: date)))
                                    .font(.caption)
                                    .foregroundColor(suggestedDays.contains(date) ? .white : .primary)
                            })
                        )
                }
            }
            
            HStack {
                Text("Select a day")
                    .font(.caption)
                
                Spacer()
                
                Button {
                    // confirm
                    guard let messageId = messageId else {
                        print("MessageId not found")
                        return
                    }
                    attachmentsViewModel.messageEditing(messageId: messageId)
                } label: {
                    Text("Confirm")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .opacity(buttonDisabled ? 0.5 : 1.0)
                .disabled(buttonDisabled)

            }
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

struct SuggestedCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestedCalendarView(
            suggestedDays: [Date()],
            attachmentsViewModel: AttachmentsViewModel()
        )
    }
}
