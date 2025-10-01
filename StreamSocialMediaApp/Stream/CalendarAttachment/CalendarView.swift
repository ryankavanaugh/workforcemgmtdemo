//
//  CalendarView.swift
//  SportsTeamSample
//
//  Created by Stefan Blos on 06.09.22.
//  Reworked to a swipeable week schedule view with vertical users and daily 3-slot (Morning/Afternoon/Evening) layout.
//  Added shift tap confirmation and callback.
//

import SwiftUI

// MARK: - Models

enum TimeOfDay: String, CaseIterable, Identifiable {
    case morning
    case afternoon
    case evening
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        }
    }
}

// Stable identity via UUID. Do NOT derive from content.
struct Shift: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let partOfDay: TimeOfDay
    var color: Color
    
    init(id: UUID = UUID(), title: String, date: Date, partOfDay: TimeOfDay, color: Color = .blue.opacity(0.2)) {
        self.id = id
        self.title = title
        self.date = date
        self.partOfDay = partOfDay
        self.color = color
    }
}

// Stable identity via UUID. Do NOT derive from shifts.
struct UserSchedule: Identifiable {
    let id: UUID
    let name: String
    let avatarSystemImageName: String?
    var shifts: [Shift]
    
    init(id: UUID = UUID(), name: String, avatarSystemImageName: String? = nil, shifts: [Shift]) {
        self.id = id
        self.name = name
        self.avatarSystemImageName = avatarSystemImageName
        self.shifts = shifts
    }
}

// MARK: - Main View

struct CalendarView: View {
    @Environment(\.calendar) private var calendar
    
    // Input: list of users with their shifts
    let users: [UserSchedule]
    // Callback when the user confirms taking over a shift
    var onTakeOver: (UserSchedule, Shift) -> Void = { _, _ in }
    
    // State: current week index relative to the reference start (0 = this week)
    @State private var currentWeekOffset: Int = 0
    @State private var selectedDay: Date = Calendar.current.startOfDay(for: Date())
    
    private var currentWeekInterval: DateInterval {
        weekInterval(for: Date(), offsetBy: currentWeekOffset)
    }
    
    private var daysInCurrentWeek: [Date] {
        daysInWeek(interval: currentWeekInterval, calendar: calendar)
    }
    
    init(users: [UserSchedule], onTakeOver: @escaping (UserSchedule, Shift) -> Void = { _, _ in }) {
        self.users = users
        self.onTakeOver = onTakeOver
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            TabView(selection: $currentWeekOffset) {
                // A reasonable swipe range
                ForEach(-52...52, id: \.self) { offset in
                    WeekPage(
                        users: users,
                        weekInterval: weekInterval(for: Date(), offsetBy: offset),
                        selectedDay: bindingForWeek(offset: offset),
                        calendar: calendar,
                        onTakeOver: onTakeOver
                    )
                    .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
    // MARK: - Header with Day Selector
    
    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    withAnimation {
                        currentWeekOffset -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(weekTitle(interval: currentWeekInterval, calendar: calendar))
                    .font(.headline)
                
                Spacer()
                
                Button {
                    withAnimation {
                        currentWeekOffset += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            DaySelector(
                days: daysInCurrentWeek,
                selected: $selectedDay,
                calendar: calendar
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
    
    // Find a day in the given week that actually has any shift across all users.
    private func firstDayWithShifts(in interval: DateInterval) -> Date? {
        let days = daysInWeek(interval: interval, calendar: calendar)
        for day in days {
            let hasShift = users.contains { user in
                user.shifts.contains { shift in
                    calendar.isDate(shift.date, inSameDayAs: day)
                }
            }
            if hasShift { return calendar.startOfDay(for: day) }
        }
        return nil
    }
    
    // Bind the selected day only when the page matches current offset
    private func bindingForWeek(offset: Int) -> Binding<Date> {
        Binding<Date>(
            get: {
                let interval = weekInterval(for: Date(), offsetBy: offset, calendar: calendar)
                if interval.contains(selectedDay) {
                    return selectedDay
                } else {
                    // Prefer a day that has data; fall back to week start.
                    return firstDayWithShifts(in: interval) ?? interval.start
                }
            },
            set: { newValue in
                selectedDay = calendar.startOfDay(for: newValue)
            }
        )
    }
}

// MARK: - Week Page (Daily table with 3 slots)

private struct WeekPage: View {
    let users: [UserSchedule]
    let weekInterval: DateInterval
    @Binding var selectedDay: Date
    let calendar: Calendar
    let onTakeOver: (UserSchedule, Shift) -> Void
    
    // Local alert state
    @State private var pendingSelection: (UserSchedule, Shift)? = nil
    @State private var showAlert: Bool = false
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                // Users vertically; each row has 3 horizontal slots (M/A/E) for the selected day only
                VStack(spacing: 0) {
                    ForEach(users) { user in
                        UserRow(
                            user: user,
                            selectedDay: selectedDay,
                            calendar: calendar
                        ) { shift in
                            pendingSelection = (user, shift)
                            showAlert = true
                        }
                        Divider()
                    }
                }
            }
        }
        .alert(
            "Do you want to take over the \(pendingSelection?.1.title ?? "") shift with \(pendingSelection?.0.name ?? "")?",
            isPresented: $showAlert
        ) {
            Button("Cancel", role: .cancel) { pendingSelection = nil }
            Button("Yes", role: .destructive) {
                if let pending = pendingSelection {
                    onTakeOver(pending.0, pending.1)
                }
                pendingSelection = nil
            }
        }
    }
}

// MARK: - Subviews

private struct UserRow: View {
    let user: UserSchedule
    let selectedDay: Date
    let calendar: Calendar
    var onShiftTap: (Shift) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Avatar and name
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: user.avatarSystemImageName ?? "person.fill")
                        .foregroundColor(.blue)
                }
                Text(user.name)
                    .font(.caption)
                    .lineLimit(1)
            }
            .frame(width: 56)
            
            // Three slots: Morning / Afternoon / Evening
            ForEach(TimeOfDay.allCases) { slot in
                let chips = chipsFor(slot: slot)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if chips.isEmpty {
                            PlaceholderCard(slot: slot)
                        } else {
                            ForEach(chips) { shift in
                                ShiftCard(shift: shift)
                                    .onTapGesture {
                                        onShiftTap(shift)
                                    }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    private func chipsFor(slot: TimeOfDay) -> [Shift] {
        user.shifts.filter { shift in
            shift.partOfDay == slot //&& calendar.isDate(shift.date, inSameDayAs: selectedDay)
        }
    }
}

private struct ShiftCard: View {
    let shift: Shift
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(shift.title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(shift.color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(shift.color.opacity(0.5), lineWidth: 1)
        )
    }
}

private struct PlaceholderCard: View {
    let slot: TimeOfDay
    
    var body: some View {
        Text("—")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct DaySelector: View {
    let days: [Date]
    @Binding var selected: Date
    let calendar: Calendar
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(days, id: \.self) { day in
                let isSelected = calendar.isDate(selected, inSameDayAs: day)
                Button {
                    selected = calendar.startOfDay(for: day)
                } label: {
                    VStack(spacing: 4) {
                        Text(shortWeekday(for: day, calendar: calendar))
                            .font(.caption2)
                        Text("\(calendar.component(.day, from: day))")
                            .font(.footnote.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        isSelected ? Color.accentColor.opacity(0.15) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Date utilities (local to this file)

private func weekInterval(for reference: Date, offsetBy weekOffset: Int, calendar: Calendar = .current) -> DateInterval {
    let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: reference))!
    let offsetStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfWeek)!
    let end = calendar.date(byAdding: .day, value: 7, to: offsetStart)!
    return DateInterval(start: offsetStart, end: end)
}

private func daysInWeek(interval: DateInterval, calendar: Calendar = .current) -> [Date] {
    var days: [Date] = []
    var current = interval.start
    for _ in 0..<7 {
        days.append(current)
        current = calendar.date(byAdding: .day, value: 1, to: current)!
    }
    return days
}

private func shortWeekday(for date: Date, calendar: Calendar) -> String {
    let idx = calendar.component(.weekday, from: date) - 1
    return calendar.shortWeekdaySymbols[idx]
}

private func longWeekday(for date: Date, calendar: Calendar) -> String {
    let idx = calendar.component(.weekday, from: date) - 1
    return calendar.weekdaySymbols[idx]
}

private func weekTitle(interval: DateInterval, calendar: Calendar = .current) -> String {
    let df = DateFormatter()
    df.calendar = calendar
    df.dateFormat = "MMM d"
    let start = df.string(from: interval.start)
    df.dateFormat = "MMM d"
    let end = df.string(from: calendar.date(byAdding: .day, value: -1, to: interval.end)!)
    return "\(start) - \(end)"
}
