//
//  PickedCalendarView.swift
//  SportsTeamSample
//
//  Created by Stefan Blos on 07.09.22.
//

import SwiftUI

struct PickedCalendarView: View {
    
    var selectedDate: Date
    
    var body: some View {
        VStack(alignment: .trailing) {
            Text("Selected date")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(selectedDate.debugDescription)
                .font(.headline)
                .foregroundColor(.primary)
            
            Button {
                // add to calendar
            } label: {
                Text("Add to calendar")
                    .font(.caption)
                    
            }
            .buttonStyle(.bordered)

        }
    }
}

struct PickedCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        PickedCalendarView(selectedDate: Date())
    }
}
