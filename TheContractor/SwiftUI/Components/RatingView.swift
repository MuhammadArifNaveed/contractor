//
//  RatingView.swift
//  TheContractor
//
//  Reusable rating display component
//

import SwiftUI

struct RatingView: View {
    let rating: Double
    let maxRating: Int = 5
    var size: CGFloat = 16
    var color: Color = AppTheme.Colors.starYellow
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxRating, id: \.self) { index in
                Image(systemName: starType(for: index))
                    .font(.system(size: size))
                    .foregroundColor(color)
            }
        }
    }
    
    private func starType(for index: Int) -> String {
        let fillValue = rating - Double(index)
        if fillValue >= 1.0 {
            return "star.fill"
        } else if fillValue >= 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

struct RatingInputView: View {
    @Binding var rating: Int
    var maxRating: Int = 5
    var size: CGFloat = 30
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...maxRating, id: \.self) { index in
                Button(action: {
                    rating = index
                }) {
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .font(.system(size: size))
                        .foregroundColor(index <= rating ? AppTheme.Colors.starYellow : AppTheme.Colors.gray)
                }
            }
        }
    }
}

// MARK: - Preview
struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            RatingView(rating: 4.5)
            RatingView(rating: 3.0)
            RatingView(rating: 5.0)
            RatingInputView(rating: .constant(3))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
