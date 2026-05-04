import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Calculette solde")
                .font(.title)
                .fontWeight(.semibold)

            Text("Migration SwiftUI en cours")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
