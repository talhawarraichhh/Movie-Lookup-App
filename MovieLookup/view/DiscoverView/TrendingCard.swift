import Foundation
import SwiftUI

struct TrendingCard: View {

    let trendingItem: Movie
    @State private var isFavorite = false
    @Binding var favorites: Set<Int>
    @Binding var favoriteMovies: [Movie]

    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: trendingItem.backdropURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 340, height: 240)
            } placeholder: {
                Rectangle().fill(.black)
                        .frame(width: 340, height: 240)
            }

            VStack {
                HStack {
                    Text(trendingItem.title)
                        .foregroundColor(.white)
                        .fontWeight(.heavy)
                    Spacer()
                    Button(action: {
                                if favorites.contains(trendingItem.id) {
                                    favorites.remove(trendingItem.id)
                                    favoriteMovies.removeAll { $0.id == trendingItem.id }
                                } else {
                                    favorites.insert(trendingItem.id)
                                    favoriteMovies.append(trendingItem)
                                }
                            }) {
                                Image(systemName: favorites.contains(trendingItem.id) ? "heart.fill" : "heart")
                                    .foregroundColor(favorites.contains(trendingItem.id) ? .red : .red)
                            }
                }
                HStack {
                    Image(systemName: "hand.thumbsup.fill")
                    Text(String(format: "%.1f", trendingItem.vote_average))
                    Spacer()
                }
                .foregroundColor(trendingItem.vote_average > 5 ? Color.green : Color.red)
                .fontWeight(.heavy)
            }
            .padding()
            .background(.black)
        }
        .cornerRadius(10)
    }
}

