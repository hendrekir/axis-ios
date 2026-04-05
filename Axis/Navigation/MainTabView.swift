import SwiftUI

struct MainTabView: View {
    var onSignedOut: () -> Void
    @State private var selectedTab: Int = 0
    @State private var sidebarVisible: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    SituationView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { withAnimation(.easeInOut(duration: 0.25)) { sidebarVisible.toggle() } }) {
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundColor(.axisTextSecondary)
                                }
                            }
                        }
                }
                .tabItem {
                    Label("Situation", systemImage: "eye.fill")
                }
                .tag(0)

                NavigationStack {
                    ThreadView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { withAnimation(.easeInOut(duration: 0.25)) { sidebarVisible.toggle() } }) {
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundColor(.axisTextSecondary)
                                }
                            }
                        }
                }
                .tabItem {
                    Label("Axis", systemImage: "bubble.left.fill")
                }
                .tag(1)

                NavigationStack {
                    MindView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { withAnimation(.easeInOut(duration: 0.25)) { sidebarVisible.toggle() } }) {
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundColor(.axisTextSecondary)
                                }
                            }
                        }
                }
                .tabItem {
                    Label("Mind", systemImage: "brain.head.profile")
                }
                .tag(2)

                NavigationStack {
                    BriefView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { withAnimation(.easeInOut(duration: 0.25)) { sidebarVisible.toggle() } }) {
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundColor(.axisTextSecondary)
                                }
                            }
                        }
                }
                .tabItem {
                    Label("Brief", systemImage: "newspaper.fill")
                }
                .tag(3)
            }
            .tint(.axisViolet)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color.axisSurface1, for: .tabBar)

            if sidebarVisible {
                SidebarView(isVisible: $sidebarVisible, onSignedOut: onSignedOut)
                    .transition(.move(edge: .leading))
            }
        }
        .preferredColorScheme(.dark)
    }
}
