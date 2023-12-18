import SwiftUI
import Foundation

struct FavoriteMoviesView: View {
    @State var favoriteMovies: [Movie]
    @ObservedObject var viewModel: MovieDiscoverViewModel
    @Binding var favorites: Set<Int>

    var body: some View {
        VStack {
            Text("Favorites ❤️")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            ScrollView {
                LazyVStack {
                    ForEach(favoriteMovies) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            HStack {
                                AsyncImage(url: movie.backdropURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 120)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 80, height: 120)
                                }
                                .clipped()
                                .cornerRadius(10)

                                VStack(alignment:.leading) {
                                    Text(movie.title)
                                        .foregroundColor(.white)
                                        .font(.headline)

                                    HStack {
                                        Image(systemName: "hand.thumbsup.fill")
                                            .foregroundColor(movie.vote_average > 5 ? Color.green : Color.red)
                                        Text(String(format: "%.1f", movie.vote_average))
                                        Spacer()
                                        Button(action: {
                                            if favorites.contains(movie.id) {
                                                favorites.remove(movie.id)
                                                favoriteMovies.removeAll { $0.id == movie.id }
                                                UserDefaults.standard.set(Array(favorites), forKey: "favorites")
                                            }
                                        }) {
                                            Image(systemName: favorites.contains(movie.id) ? "heart.fill" : "heart")
                                                .foregroundColor(favorites.contains(movie.id) ? .red : .red)
                                        }
                                    }
                                    .foregroundColor(.yellow)
                                    .fontWeight(.heavy)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.black)
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .onAppear {
            print("Favorite movies: \(favoriteMovies)")
            loadFavorites()
        }
    }
    
    private func loadFavorites() {
        if let favorites = UserDefaults.standard.array(forKey: "favorites") as? [Int] {
            self.favorites = Set(favorites)
        }
    }
}



