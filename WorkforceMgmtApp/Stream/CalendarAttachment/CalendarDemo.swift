//
//  CalenderDemo.swift
//  SportsTeamSample
//
//  Created by Stefan Blos on 06.09.22.
//

import SwiftUI

struct CalenderDemo: View {
    @Environment(\.calendar) var calendar
    
    @ObservedObject var viewModel: CalendarViewModel
    var calendarAttachmentPickerMode: CalendarAttachmentPickerMode
    
    // Read the persistent store from the environment
    @EnvironmentObject private var scheduleStore: UsersScheduleStore
    
    // Callback for shift tap -> attachment creation upstream
    var onShiftTap: (String, String, Date) -> Void = { _, _, _ in }
    
    private var month: DateInterval {
        calendar.dateInterval(of: .month, for: Date())!
    }
    
    let colors: [Color] = [
        Color.blue.opacity(0.20),
        Color.yellow.opacity(0.35),
        Color.pink.opacity(0.25),
        Color.mint.opacity(0.30)
    ]
    
    var body: some View {
        CalendarView(
            users: scheduleStore.users,
            onTakeOver: { user, shift in
                // Keep empty behavior here; still forward to the picker if you want to create an attachment.
                onShiftTap(user.name, shift.title, shift.date)
            }
        )
    }
    
    // Not used for seeding anymore, but kept for potential utilities
    func shift(_ title: String, dayOffset: Int, part: TimeOfDay, color: Color) -> Shift {
        Shift(title: title,
              date: cal.date(byAdding: .day, value: dayOffset, to: today)!,
              partOfDay: part,
              color: color)
    }
    
    let today = Calendar.current.startOfDay(for: Date())
    let cal = Calendar.current
}

struct Calendar_Previews: PreviewProvider {
    static var previews: some View {
        CalenderDemo(viewModel: CalendarViewModel(), calendarAttachmentPickerMode: .createAttachment)
            .environmentObject(UsersScheduleStore(users: []))
    }
}
