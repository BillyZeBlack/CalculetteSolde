import SwiftUI

private let accentGradient = LinearGradient(
    colors: [Color.blue, Color.purple],
    startPoint: .leading,
    endPoint: .trailing
)

struct HeroHeaderView: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "percent")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(accentGradient)
                .symbolEffect(.bounce, options: .repeating)

            Text("Calculez vos remises")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text("Saisissez un prix et choisissez une remise")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

#Preview {
    HeroHeaderView()
}
