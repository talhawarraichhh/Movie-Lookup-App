import Foundation
import SwiftUI
import Combine
struct DiscoverView: View {
    
    @StateObject var viewModel = MovieDiscoverViewModel()
    @State var searchText = ""
    @State var favorites: Set<Int> = []
    @State var favoriteMovies: [Movie] = []
    @State var allFavoriteMovies: [Movie] = []
    private func updateAllFavoriteMovies() {
        allFavoriteMovies = viewModel.allFavoriteMovies(favorites: favorites)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if searchText.isEmpty {
                    if viewModel.trending.isEmpty {
                        Text("No Results")
                    } else {
                        HStack {
                            Text("Trending 🔥")
                                .font(.title)
                                .foregroundColor(.black)
                                .fontWeight(.heavy)
                            Spacer()
                        }
                        .padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            VStack {
                                ForEach(viewModel.trending, id: \.id) { trendingItem in
                                    NavigationLink {
                                        MovieDetailView(movie: trendingItem)
                                    } label: {
                                        TrendingCard(trendingItem: trendingItem, favorites: $favorites, favoriteMovies: $favoriteMovies)
                                            .frame(width: 360, height: 240)
                                            .clipped()
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else {
                    LazyVStack() {
                        ForEach(viewModel.searchResults, id: \.id) { item in
                            NavigationLink(destination: MovieDetailView(movie: item)) {
                                MovieRow(item: item, favorites: $favorites, favoriteMovies: $favoriteMovies, viewModel: viewModel)
                            }
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Discover")
                        .font(.headline)
                }
            }
            .onChange(of: favorites) { _ in
                saveFavorites()
                allFavoriteMovies = viewModel.allFavoriteMovies(favorites: favorites)
            }
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { newValue in
            if newValue.count > 2 {
                viewModel.search(term: newValue)
            }
            allFavoriteMovies = viewModel.loadAllFavoriteMovies(favorites: favorites)
        }
        .onChange(of: favorites) { _ in
            saveFavorites()
        }       .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NavigationLink(destination: FavoriteMoviesView(favoriteMovies: allFavoriteMovies, viewModel: viewModel, favorites: $favorites)) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(!allFavoriteMovies.isEmpty ? .red : .gray)
                }
            }
        }
        
        .onAppear {
            loadAndUpdateFavorites()
               viewModel.loadTrending()
               viewModel.loadFavorites()
        }
        .onChange(of: favorites) { _ in
            saveFavorites()
        }
    }
    
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favorites), forKey: "favorites")
    }
    
    private func loadFavorites() {
        if let favoritesArray = UserDefaults.standard.array(forKey: "favorites") as? [Int] {
            self.favorites = Set(favoritesArray) // Convert the array to a Set
            self.favoriteMovies = viewModel.searchResults.filter { favorites.contains($0.id) } + viewModel.trending.filter { favorites.contains($0.id) }
            self.allFavoriteMovies = viewModel.allFavoriteMovies(favorites: favorites) // Add this line
        }
    }

    private func loadAndUpdateFavorites() {
        loadFavorites()
        viewModel.fetchFavoriteMovies(movieIds: favorites) { fetchedFavoriteMovies in
            allFavoriteMovies = fetchedFavoriteMovies
        }
    }
    struct MovieRow: View {
        var item: Movie
        @Binding var favorites: Set<Int>
        @Binding var favoriteMovies: [Movie]
        var viewModel: MovieDiscoverViewModel
        
        var body: some View {
            HStack {
                AsyncImage(url: item.backdropURL) { image in
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
                
                VStack(alignment: .leading) {
                    Text(item.title)
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "hand.thumbsup.fill")
                            .foregroundColor(item.vote_average > 5 ? Color.green : Color.red)
                        Text(String(format: "%.1f", item.vote_average))
                        Spacer()
                        Button(action: {
                            if favorites.contains(item.id) {
                                favorites.remove(item.id)
                            } else {
                                favorites.insert(item.id)
                            }
                            saveFavorites()
                            favoriteMovies = viewModel.allFavoriteMovies(favorites: favorites) // Use the correct viewModel instance
                            print("Favorites: \(favorites)")
                        }) {
                            Image(systemName: favorites.contains(item.id) ? "heart.fill" : "heart")
                                .foregroundColor(favorites.contains(item.id) ? .red : .red)
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
        
        private func saveFavorites() {
            UserDefaults.standard.set(Array(favorites), forKey: "favorites")
        }
    }

    
}
        
    

