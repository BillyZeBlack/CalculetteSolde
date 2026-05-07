import Charts
import SwiftUI

struct ProductRecapView: View {
    @StateObject private var viewModel: ProductRecapViewModel

    init(viewModel: ProductRecapViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                totalSummary

                if shouldShowCategoryChart {
                    categoryChart
                }

                ForEach(viewModel.categorySections) { section in
                    categorySection(section)
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Récapitulatif")
        .navigationBarTitleDisplayMode(.large)
    }

    private var totalSummary: some View {
        VStack(spacing: 0) {
            summaryRow(
                title: "Prix final",
                value: viewModel.formattedTotalFinalPrice,
                systemImageName: "cart.fill",
                tint: .blue
            )

            Divider()
                .padding(.leading)

            summaryRow(
                title: "Remise",
                value: viewModel.formattedTotalDiscountAmount,
                systemImageName: "arrow.down.to.line.compact",
                tint: .green
            )
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.separator).opacity(0.45), lineWidth: 2)
        }
        .padding(.horizontal)
    }

    private var categoryChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Répartition par catégorie")
                .font(.headline.weight(.semibold))

            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Chart(chartSections) { section in
                        SectorMark(
                            angle: .value("Total", chartValue(for: section)),
                            innerRadius: .ratio(0.62),
                            angularInset: 2
                        )
                        .cornerRadius(4)
                        .foregroundStyle(chartColor(for: section))
                    }
                    .chartLegend(.hidden)
                    .frame(width: 132, height: 132)

                    VStack(spacing: 2) {
                        Text(viewModel.formattedTotalFinalPrice)
                            .font(.headline.weight(.bold))
                            .minimumScaleFactor(0.75)
                            .lineLimit(1)

                        Text("Total")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 82)
                }

                VStack(spacing: 8) {
                    ForEach(chartSections) { section in
                        chartLegendRow(section)
                    }
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.separator).opacity(0.25), lineWidth: 1)
        }
        .padding(.horizontal)
    }

    private func chartLegendRow(_ section: ProductCategorySection) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(chartColor(for: section))
                .frame(width: 9, height: 9)

            Text(section.title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer(minLength: 8)

            Text(viewModel.formattedTotalFinalPrice(for: section))
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
    }

    private func summaryRow(
        title: LocalizedStringKey,
        value: String,
        systemImageName: String,
        tint: Color
    ) -> some View {
        HStack {
            Label(title, systemImage: systemImageName)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)

            Spacer()

            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }

    private func categorySection(_ section: ProductCategorySection) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: section.category?.systemImageName ?? "tray.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 34, height: 34)
                    .background(Color.blue.opacity(0.1), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(section.title)
                        .font(.headline.weight(.semibold))

                    Text(productCountText(for: section.products.count))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.formattedTotalFinalPrice(for: section))
                        .font(.headline.weight(.bold))

                    Text(viewModel.formattedDiscountAmount(for: section))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.green)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 14)

            ForEach(section.products) { product in
                Divider()
                    .padding(.leading)

                productRow(product)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.separator).opacity(0.45), lineWidth: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }

    private func productRow(_ product: Product) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(product.name.isEmpty ? "Produit sans nom" : product.name)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)

                Text(product.discountRate?.label ?? "0%")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            Text(viewModel.formattedFinalPrice(for: product))
                .font(.body.weight(.bold))
                .contentTransition(.numericText())
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private func productCountText(for count: Int) -> String {
        count == 1 ? "1 produit" : "\(count) produits"
    }

    private var chartSections: [ProductCategorySection] {
        viewModel.categorySections.filter { $0.totalFinalPrice > 0 }
    }

    private var shouldShowCategoryChart: Bool {
        chartSections.count >= 2
    }

    private func chartValue(for section: ProductCategorySection) -> Double {
        NSDecimalNumber(decimal: section.totalFinalPrice).doubleValue
    }

    private func chartColor(for section: ProductCategorySection) -> Color {
        let palette: [Color] = [
            .blue,
            .green,
            .orange,
            .pink,
            .teal,
            .indigo,
            .mint,
            .brown
        ]

        let index = abs(section.id.hashValue) % palette.count
        return palette[index]
    }
}

#Preview {
    let store = ProductStore(products: [
        Product(
            name: "Pull",
            originalPrice: Decimal(100),
            discountRate: DiscountRate(percentage: 30),
            category: Category.defaults[0]
        ),
        Product(
            name: "Pates",
            originalPrice: Decimal(10),
            discountRate: DiscountRate(percentage: 0),
            category: Category.defaults.first { $0.id == "groceries" }
        )
    ])

    NavigationStack {
        ProductRecapView(viewModel: ProductRecapViewModel(productStore: store))
    }
}
