//
//  PreviewCalendarView.swift
//  SportsTeamSample
//
//  Created by Stefan Blos on 07.09.22.
//

import SwiftUI

struct PreviewCalendarView: View {
    
    @Environment(\.calendar) var calendar
    
    var suggestedDays: [Date]
    
    private var month: DateInterval {
        calendar.dateInterval(of: .month, for: Date())!
    }
    
    private var months: [Date] {
        calendar.generateDates(
            inside: month,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
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
                        .background(suggestedDays.contains(date) ? Color.blue : Color.clear, in: Circle())
                        .padding(.vertical, 2)
                        .overlay(
                            Text(String(self.calendar.component(.day, from: date)))
                                .font(.caption)
                                .foregroundColor(suggestedDays.contains(date) ? .white : .primary)
                        )
                }
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

struct PreviewCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewCalendarView(
            suggestedDays: [Date()]
        )
    }
}

extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        
        NSCalendar.current.enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }

        return dates
    }
}
