import SwiftUI

struct AppIntroView: View {
    let onComplete: () -> Void

    @State private var titleOpacity = 0.0

    private let logoSize: CGFloat = 190
    private let logoCornerRadius: CGFloat = 42

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 20) {
                Image("IntroLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSize, height: logoSize)
                    .clipShape(RoundedRectangle(cornerRadius: logoCornerRadius, style: .continuous))
                    .accessibilityHidden(true)

                Text("Solde facile")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white.opacity(0.92))
                    .opacity(titleOpacity)
            }
        }
        .task {
            withAnimation(.easeOut(duration: 1.6).delay(0.1)) {
                titleOpacity = 1
            }
            try? await Task.sleep(for: .seconds(6))
            onComplete()
        }
    }
}
private struct AnimatedBackground: View {
    @State private var isShifted = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.949, green: 0.486, blue: 0.486),
                    Color(red: 1.0, green: 0.286, blue: 0.22)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            ColorBlob(color: Color(red: 1.0, green: 0.463, blue: 0.22), size: 360)
                .offset(x: isShifted ? 120 : -140, y: isShifted ? -260 : -120)

            ColorBlob(color: Color(red: 1.0, green: 0.18, blue: 0.39), size: 420)
                .offset(x: isShifted ? -170 : 140, y: isShifted ? 210 : 90)

            ColorBlob(color: Color(red: 0.78, green: 0.12, blue: 0.22), size: 340)
                .offset(x: isShifted ? 170 : -120, y: isShifted ? 190 : 280)
                .opacity(0.7)

            ColorBlob(color: Color(red: 1.0, green: 0.58, blue: 0.48), size: 300)
                .offset(x: isShifted ? -110 : 90, y: isShifted ? -160 : -280)
                .opacity(0.75)
        }
        .ignoresSafeArea()
        .blur(radius: 36)
        .scaleEffect(1.18)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 6)
                .repeatForever(autoreverses: true)
            ) {
                isShifted = true
            }
        }
    }
}

private struct ColorBlob: View {
    let color: Color
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blendMode(.softLight)
    }
}

#Preview {
    AppIntroView(onComplete: {})
}
