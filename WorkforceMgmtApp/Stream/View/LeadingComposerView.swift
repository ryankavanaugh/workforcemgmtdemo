//
//  LeadingComposerView.swift
//  StreamSocialMediaApp
//
//  Created by Stefan Blos on 20.09.22.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct LeadingComposerView: View {
    
    @ObservedObject var viewModel: AttachmentsViewModel
    
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    @Injected(\.chatClient) var chatClient
    
    @Binding var pickerTypeState: PickerTypeState
    var channelConfig: ChannelConfig?
    
    @State var addPollShown = false
    
    var body: some View {
        HStack(spacing: 16) {
            switch pickerTypeState {
            case let .expanded(attachmentPickerType):
                Button {
                    addPollShown = true
                } label: {
                    Image(systemName: "chart.bar.fill")
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 18)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
                .accessibilityIdentifier("PickerTypeInstaAttachment")
                .sheet(isPresented: $addPollShown) {
                    if let channelController = viewModel.channelController {
                        CreatePollView(chatController: channelController, messageController: nil)
                    } else {
                        EmptyView()
                    }
                }
                
                Button {
                    withAnimation {
                        viewModel.selectedCustomAttachment = .calendar
                        viewModel.tryCallingPickerStateChange()
                        if attachmentPickerType == .custom {
                            pickerTypeState = .expanded(.none)
                        } else {
                            pickerTypeState = .expanded(.custom)
                        }
                    }
                } label: {
                    Image(systemName: "calendar.circle")
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 18)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
            case .collapsed:
                Button {
                    withAnimation {
                        pickerTypeState = .expanded(.none)
                    }
                } label: {
                    Image(uiImage: images.shrinkInputArrow)
                        .renderingMode(.template)
                        .foregroundColor(Color(colors.highlightedAccentBackground))
                }
                .accessibilityIdentifier("PickerTypeButtonCollapsed")
            }
        }
        .padding(.bottom, 8)
    }
    
    private func foregroundColor(
        for pickerType: AttachmentPickerType,
        selected: AttachmentPickerType
    ) -> Color {
        if pickerType == selected {
            return Color(colors.highlightedAccentBackground)
        } else {
            return Color(colors.textLowEmphasis)
        }
    }
}

struct PickerTypeButton: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    
    @Binding var pickerTypeState: PickerTypeState
    
    let pickerType: AttachmentPickerType
    let selected: AttachmentPickerType
    
    var body: some View {
        Button {
            withAnimation {
                onTap(attachmentType: pickerType, selected: selected)
            }
        } label: {
            Image(uiImage: icon)
                .renderingMode(.template)
                .aspectRatio(contentMode: .fill)
                .frame(height: 18)
                .foregroundColor(
                    foregroundColor(for: pickerType, selected: selected)
                )
        }
    }
    
    private var icon: UIImage {
        if pickerType == .media {
            return images.openAttachments
        } else if pickerType == .custom {
            return UIImage(systemName: "plus.circle")!
        } else {
            return images.commands
        }
    }
    
    private func onTap(
        attachmentType: AttachmentPickerType,
        selected: AttachmentPickerType
    ) {
        if selected == attachmentType {
            pickerTypeState = .expanded(.none)
        } else {
            pickerTypeState = .expanded(attachmentType)
        }
    }
    
    private func foregroundColor(
        for pickerType: AttachmentPickerType,
        selected: AttachmentPickerType
    ) -> Color {
        if pickerType == selected {
            return Color(colors.highlightedAccentBackground)
        } else {
            return Color(colors.textLowEmphasis)
        }
    }
}

struct LeadingComposerView_Previews: PreviewProvider {
    static var previews: some View {
        LeadingComposerView(viewModel: AttachmentsViewModel(), pickerTypeState: .constant(.collapsed))
    }
}
