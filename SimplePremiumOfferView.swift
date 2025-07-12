import SwiftUI
import RevenueCat

struct SimplePremiumOfferView: View {
    @EnvironmentObject var revenueCatManager: RevenueCatManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPlan: PlanType = .yearly
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isCloseButtonEnabled = false
    @State private var showMoreInfo = false
    @State private var testimonialIndex = 0
    
    enum PlanType: CaseIterable {
        case monthly, yearly
        
        var revenueCatType: RevenueCatManager.SubscriptionType {
            switch self {
            case .monthly: return .monthly
            case .yearly: return .yearly
            }
        }
        
        var title: String {
            switch self {
            case .monthly: return "Monthly"
            case .yearly: return "Yearly"
            }
        }
        
        var priceText: String {
            switch self {
            case .monthly: return "/ month"
            case .yearly: return "/ year"
            }
        }
        
        var badge: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "MOST POPULAR"
            }
        }
        
        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "Save 62%"
            }
        }
    }
    
    let testimonials: [(avatar: String, name: String, text: String)] = [
        ("ER", "Emily R.", "Super easy to use! I always find a charger nearby."),
        ("JD", "John D.", "Favorites and the map are so practical, highly recommend."),
        ("SL", "Sophia L.", "Real-time station info saves me so much time!")
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.055, green: 0.082, blue: 0.106).ignoresSafeArea()
            VStack(spacing: 0) {
                // Top bar with close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                    }
                    .padding(.trailing, 18)
                    .padding(.top, 18)
                    .disabled(!isCloseButtonEnabled)
                    .opacity(isCloseButtonEnabled ? 1.0 : 0.5)
                }
                .frame(height: 44)
                // Scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero icon
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(red: 0.737, green: 0.918, blue: 0.051).opacity(0.18), Color.clear],
                                    startPoint: .top, endPoint: .bottom))
                                .frame(width: 100, height: 100)
                            Image(systemName: "bolt.car")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(Color(red: 0.737, green: 0.918, blue: 0.051))
                                .shadow(color: Color(red: 0.737, green: 0.918, blue: 0.051).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 8)
                        // Rating
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(red: 0.95, green: 0.85, blue: 0.2))
                                .font(.system(size: 18, weight: .bold))
                            Text("4.9")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("· 2,300+ reviews")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 8)
                        // Testimonials carousel
                        TabView(selection: $testimonialIndex) {
                            ForEach(Array(testimonials.enumerated()), id: \.offset) { idx, t in
                                TestimonialView(avatar: t.avatar, name: t.name, text: t.text)
                                    .tag(idx)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 70)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 4)
                        // Dots below testimonials
                        HStack(spacing: 8) {
                            ForEach(0..<testimonials.count, id: \.self) { idx in
                                Circle()
                                    .fill(idx == testimonialIndex ? Color(red: 0.737, green: 0.918, blue: 0.051) : Color.white.opacity(0.25))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.bottom, 20)
                        // Title & description
                        VStack(spacing: 12) {
                            Text("Unlock All Features")
                                .font(.system(size: 28, weight: .heavy, design: .default))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Text("Unlimited station, favorite and detail access. Real-time updated map and more!")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 18)
                        }
                        .padding(.bottom, 24)
                        // Feature list
                        VStack(alignment: .leading, spacing: 16) {
                            FeatureRow(icon: "bolt.fill", text: "Real-time station status")
                            FeatureRow(icon: "star.fill", text: "Save and manage favorites")
                            FeatureRow(icon: "map.fill", text: "Unlimited detail & map access")
                        }
                        .padding(.horizontal, 36)
                        .padding(.bottom, 32)
                        
                        // Plan selection section
                        VStack(spacing: 16) {
                            VStack(spacing: 12) {
                                PlanCard(
                                    plan: .yearly,
                                    isSelected: selectedPlan == .yearly,
                                    price: revenueCatManager.getLocalizedPrice(for: PlanType.yearly.revenueCatType),
                                    onTap: { selectedPlan = .yearly }
                                )
                                PlanCard(
                                    plan: .monthly,
                                    isSelected: selectedPlan == .monthly,
                                    price: revenueCatManager.getLocalizedPrice(for: PlanType.monthly.revenueCatType),
                                    onTap: { selectedPlan = .monthly }
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            // Continue button
                            Button(action: purchase) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(0.9)
                                    } else {
                                        Text("Continue")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .frame(height: 54)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(LinearGradient(
                                            colors: [Color(red: 0.737, green: 0.918, blue: 0.051), Color(red: 0.6, green: 0.8, blue: 0.05)],
                                            startPoint: .leading, endPoint: .trailing))
                                )
                            }
                            .disabled(isLoading)
                            .padding(.horizontal, 20)
                            
                            // Bottom links
                            HStack {
                                Button(action: {
                                    revenueCatManager.restorePurchases { _, _ in }
                                }) {
                                    Text("Restore Purchases")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(red: 0.737, green: 0.918, blue: 0.051))
                                        .underline()
                                }
                                
                                Spacer()
                                
                                Text("Cancel anytime")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .interactiveDismissDisabled(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                isCloseButtonEnabled = true
            }
        }
    }
    
    private func purchase() {
        guard let package = revenueCatManager.getPackage(for: selectedPlan.revenueCatType) else {
            alertMessage = "Selected plan is not available. Please try again."
            showingAlert = true
            return
        }
        isLoading = true
        revenueCatManager.purchasePackage(package) { success, message in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    dismiss()
                } else {
                    alertMessage = message ?? "Purchase failed. Please try again."
                    showingAlert = true
                }
            }
        }
    }
}

struct PlanCard: View {
    let plan: SimplePremiumOfferView.PlanType
    let isSelected: Bool
    let price: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(plan.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.85))
                        if let badge = plan.badge {
                            Text(badge)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color(red: 0.737, green: 0.918, blue: 0.051)))
                        }
                    }
                    if let savings = plan.savings {
                        Text(savings)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 0.737, green: 0.918, blue: 0.051))
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(price)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.85))
                    Text(plan.priceText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [Color(red: 0.737, green: 0.918, blue: 0.051).opacity(0.15), Color(red: 0.13, green: 0.19, blue: 0.11)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.white.opacity(0.05), Color.white.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color(red: 0.737, green: 0.918, blue: 0.051) : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color(red: 0.737, green: 0.918, blue: 0.051).opacity(0.2) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.737, green: 0.918, blue: 0.051))
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.92))
        }
    }
}

struct TestimonialView: View {
    let avatar: String
    let name: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar with initials
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.737, green: 0.918, blue: 0.051), Color(red: 0.6, green: 0.8, blue: 0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                
                Text(avatar)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    // 5 stars
                    HStack(spacing: 1) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(red: 0.95, green: 0.85, blue: 0.2))
                        }
                    }
                }
                
                Text(text)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color(red: 0.737, green: 0.918, blue: 0.051).opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.737, green: 0.918, blue: 0.051).opacity(0.15), lineWidth: 1)
                )
        )
    }
}

// BlurView for sticky bar background
import UIKit
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
