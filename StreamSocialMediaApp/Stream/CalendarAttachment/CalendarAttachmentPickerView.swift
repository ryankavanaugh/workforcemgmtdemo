//
//  CalendarAttachmentPickerView.swift
//  StreamSocialMediaApp
//
//  Created by Stefan Blos on 17.11.23.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

class CalendarViewModel: ObservableObject {
    
    @Published var selectedDays: [Date] = []
    
    func add(_ date: Date) {
        selectedDays.append(date)
    }
    
    func remove(_ date: Date) {
        selectedDays = selectedDays.filter { $0 != date }
    }
    
    func isSelected(_ date: Date) -> Bool {
        selectedDays.contains(date)
    }
}

// Persistent store for users/shifts that survives picker open/close
final class UsersScheduleStore: ObservableObject {
    @Published var users: [UserSchedule]
    init(users: [UserSchedule] = []) {
        self.users = users
    }
}

struct CalendarAttachmentPickerView: View {
    
    @StateObject var viewModel = CalendarViewModel()
    // Create once per picker lifetime
    @StateObject private var scheduleStore = UsersScheduleStore()
    
    var onCustomAttachmentTap: (CustomAttachment) -> Void
    
    var body: some View {
        VStack {
            CalenderDemo(
                viewModel: viewModel,
                calendarAttachmentPickerMode: .createAttachment,
                onShiftTap: { name, shift, date in
                    onCustomAttachmentTap(
                        CustomAttachment(
                            id: UUID().uuidString,
                            content: AnyAttachmentPayload(
                                payload: ShiftAttachmentPayload(user: name, title: shift, date: date)
                            )
                        )
                    )
                }
            )
            // Inject the persistent store
            .environmentObject(scheduleStore)
        }
        .onAppear {
            // Seed once if empty; this won’t run again while the picker stays alive.
            if scheduleStore.users.isEmpty {
                scheduleStore.users = seedUsers()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

private func seedUsers() -> [UserSchedule] {
    let cal = Calendar.current
    let today = cal.startOfDay(for: Date())
    func shift(_ title: String, _ d: Int, _ p: TimeOfDay, _ c: Color) -> Shift {
        Shift(title: title, date: cal.date(byAdding: .day, value: d, to: today)!, partOfDay: p, color: c)
    }
    let colors: [Color] = [
        Color.blue.opacity(0.20),
        Color.yellow.opacity(0.35),
        Color.pink.opacity(0.25),
        Color.mint.opacity(0.30)
    ]
    return [
        UserSchedule(name: "Alex", avatarSystemImageName: "person.fill", shifts: [
            shift("Morning", 0, .morning, colors[0]),
            shift("Afternoon", 0, .afternoon, colors[1]),
            shift("Night", 2, .evening, colors[2])
        ]),
        UserSchedule(name: "Sam", avatarSystemImageName: "person.crop.circle.fill", shifts: [
            shift("Night", 0, .evening, colors[2]),
            shift("Afternoon", 3, .afternoon, colors[1])
        ]),
        UserSchedule(name: "Riley", avatarSystemImageName: "person.2.fill", shifts: [
            shift("Evening", 5, .evening, colors[2]),
            shift("Morning", 6, .morning, colors[0])
        ])
    ]
}

struct CalendarAttachmentPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarAttachmentPickerView { _ in }
    }
}
