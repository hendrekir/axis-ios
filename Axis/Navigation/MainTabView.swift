import SwiftUI
import UIKit

struct MainTabView: View {
    var onSignedOut: () -> Void
    @State private var selectedTab: Int = 0
    @State private var sidebarPresented: Bool = false

    init(onSignedOut: @escaping () -> Void) {
        self.onSignedOut = onSignedOut
        // Tab bar chrome
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.axisSurface1)
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.06)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private func sidebarToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                sidebarPresented = true
            } label: {
                Image(systemName: "person.crop.circle")
                    .foregroundColor(.axisTextSecondary)
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                SituationView(selectedTab: $selectedTab)
                    .toolbar { sidebarToolbar() }
            }
            .tabItem { Label("Situation", systemImage: "eye.fill") }
            .tag(0)

            NavigationStack {
                ThreadView()
                    .toolbar { sidebarToolbar() }
            }
            .tabItem { Label("Axis", systemImage: "sparkles") }
            .tag(1)

            NavigationStack {
                MindView()
                    .toolbar { sidebarToolbar() }
            }
            .tabItem { Label("Mind", systemImage: "brain.head.profile") }
            .tag(2)

            NavigationStack {
                BriefView()
                    .toolbar { sidebarToolbar() }
            }
            .tabItem { Label("Brief", systemImage: "sun.max.fill") }
            .tag(3)
        }
        .tint(Color.axisViolet)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
        .sheet(isPresented: $sidebarPresented) {
            SidebarView(isVisible: $sidebarPresented, onSignedOut: onSignedOut)
        }
        .preferredColorScheme(.dark)
    }
}
