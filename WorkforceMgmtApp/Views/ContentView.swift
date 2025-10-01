import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct Post: Identifiable {
    let id: Int
    let userName, text, profileImageName, imageName: String
    let likes: Int
    let timePosted: String
}

struct Story {
    let id: Int
    let imageName: String
}

struct StoryView: View {
    let stories: [Story]
    var body: some View {
        HStack {
            ForEach(stories, id: \.id) { (story) in
                ZStack {
                    Circle()
                        .fill(Color.init(red: 193/255, green: 53/255, blue: 132/255))
                        .clipShape(Circle())
                        .frame(width: 64, height: 64)
                    Circle()
                        .fill(Color.white)
                        .clipShape(Circle())
                        .frame(width: 60, height: 60)
                    Image(story.imageName)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 56, height: 56)
                }
            }
        }
    }
}

struct ContentView: View {
    
    @StateObject var attachmentsViewModel = AttachmentsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ScrollView(.horizontal, showsIndicators: false) {
                    StoryView(stories: stories)
                }
                .frame(height: 76)
                .clipped()
                
                ForEach(posts) { post in
                    PostView(post: post)
                        .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .navigationBarTitle(Text("Chic-fil-A: Los Angeles"), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                print("click camera...")
            }, label: {
                Image(systemName: "house")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .padding(15)
            }), trailing: NavigationLink {
                ChatChannelListView(viewFactory: SocialViewFactory(attachmentsViewModel: attachmentsViewModel), viewModel: attachmentsViewModel, embedInNavigationView: false)
//                ChatChannelListContentView(viewFactory: SocialViewFactory.shared, viewModel: viewModel)
                    .environmentObject(attachmentsViewModel)
            } label: {
                Image(systemName: "paperplane")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 29, height: 29)
                    .padding(15)
            })
            
        }
    }
    
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
