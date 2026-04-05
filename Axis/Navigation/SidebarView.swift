import SwiftUI

struct SidebarView: View {
    @Binding var isVisible: Bool
    var onSignedOut: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                SidebarHeader()
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                Divider()
                    .background(Color.axisBorderDefault)
                    .padding(.vertical, 16)

                SidebarNavItem(icon: "bell.fill", label: "Signal") { }
                SidebarNavItem(icon: "calendar", label: "Schedule") { }
                SidebarNavItem(icon: "network", label: "Connections") { }
                SidebarNavItem(icon: "cpu", label: "Capabilities") { }

                Spacer()

                Divider().background(Color.axisBorderDefault)

                SidebarNavItem(icon: "gearshape.fill", label: "Settings") { }
                    .padding(.bottom, 32)
            }
            .frame(width: min(UIScreen.main.bounds.width * 0.8, 320))
            .background(Color.axisSurface1)
            .overlay(
                Rectangle()
                    .fill(Color.axisBorderDefault)
                    .frame(width: 0.5),
                alignment: .trailing
            )

            Color.black.opacity(0.5)
                .onTapGesture { withAnimation(.easeInOut(duration: 0.25)) { isVisible = false } }
        }
        .ignoresSafeArea()
    }
}

struct SidebarHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            AxisMark(size: 28, color: .axisViolet)
            VStack(alignment: .leading, spacing: 2) {
                Text("AXIS")
                    .font(.axisSyne(18))
                    .foregroundColor(.axisTextPrimary)
                Text("extend the mind")
                    .font(.axisMono(9))
                    .foregroundColor(.axisViolet.opacity(0.4))
                    .kerning(2)
            }
        }
    }
}

struct SidebarNavItem: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.axisViolet)
                    .frame(width: 22)
                Text(label)
                    .font(.axisBody(15, weight: .medium))
                    .foregroundColor(.axisTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.axisTextMuted)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .background(Color.clear)
        .contentShape(Rectangle())
    }
}
