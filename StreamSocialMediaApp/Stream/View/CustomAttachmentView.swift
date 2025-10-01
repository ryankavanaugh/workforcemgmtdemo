//
//  CustomAttachmentView.swift
//  StreamSocialMediaApp
//
//  Created by Stefan Blos on 19.05.23.
//

import SwiftUI
import StreamChatSwiftUI

struct CustomAttachmentView: View {
    
    @Binding var selectedCustomAttachment: SelectedCustomAttachment
    @ObservedObject var viewModel: AttachmentsViewModel
    var onCustomAttachmentTap: (CustomAttachment) -> Void
    
    var body: some View {
        switch selectedCustomAttachment {
        case .none:
            Text("Unknown attachment selected.")
        case .calendar:
            CalendarAttachmentPickerView(onCustomAttachmentTap: onCustomAttachmentTap)
        case .payment:
            PaymentAttachmentPickerView(viewModel: viewModel)
        }
    }
}
