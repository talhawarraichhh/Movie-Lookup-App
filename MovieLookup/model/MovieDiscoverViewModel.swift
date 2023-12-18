import Foundation


@MainActor
class MovieDiscoverViewModel: ObservableObject {
    @Published var trending: [Movie] = []
    @Published var searchResults: [Movie] = []
    @Published var favorites: [Movie] = []
    @Published var movies: [Int: Movie] = [:]
    @Published var allFetchedMovies: [Movie] = []
    
    static let apiKey = "ab8ca7862f2733af2356c592de5f9d45"
    
    func fetchMovieDetails(movieId: Int, completion: @escaping (Movie?) -> Void) {
        let apiKey = "ab8ca7862f2733af2356c592de5f9d45"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)?api_key=\(apiKey)&language=en-US")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let movie = try decoder.decode(Movie.self, from: data)
                    DispatchQueue.main.async {
                        completion(movie)
                    }
                } catch {
                    print("Error decoding movie details: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                print("Error fetching movie details: \(String(describing: error))")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
            
    
    
    
    func fetchFavoriteMovies(movieIds: Set<Int>, completion: @escaping ([Movie]) -> Void) {
        let group = DispatchGroup()
        var favoriteMovies: [Movie] = []

        for movieId in movieIds {
            group.enter()
            fetchMovieDetails(movieId: movieId) { movie in
                if let movie = movie {
                    favoriteMovies.append(movie)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(favoriteMovies)
        }
    }
    
    func loadTrending() {
        Task {
            let url = URL(string: "https://api.themoviedb.org/3/trending/movie/day?api_key=\(MovieDiscoverViewModel.apiKey)")!
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let trendingResults = try JSONDecoder().decode(TrendingResults.self, from: data)
                trending = trendingResults.results
                for movie in trending {
                    movies[movie.id] = movie
                }
                self.allFetchedMovies.append(contentsOf: trending)
            } catch {
                print(error.localizedDescription)
            }
            self.allFetchedMovies.append(contentsOf: trending)
            self.allFetchedMovies = removeDuplicates(from: allFetchedMovies)
        }
    }
    func allFavoriteMovies(favorites: Set<Int>) -> [Movie] {
        return allFetchedMovies.filter { favorites.contains($0.id) }
        }
    func loadAllFavoriteMovies(favorites: Set<Int>) -> [Movie] {
        return allFetchedMovies.filter { favorites.contains($0.id) }
    }

    
    func loadFavorites() {
        let userDefaults = UserDefaults.standard
        let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("favoriteMovie-") }
        favorites.removeAll()

        for key in keys {
            if let data = userDefaults.data(forKey: key), let movie = try? JSONDecoder().decode(Movie.self, from: data) {
                favorites.append(movie)
            }
        }
    }
    
    func search(term: String) {
        Task {
            let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(MovieDiscoverViewModel.apiKey)&language=en-US&page=1&include_adult=false&query=\(term)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let trendingResults = try JSONDecoder().decode(TrendingResults.self, from: data)
                searchResults = trendingResults.results
                for movie in searchResults {
                    movies[movie.id] = movie
                }
                self.allFetchedMovies.append(contentsOf: searchResults)
            } catch {
                print(error.localizedDescription)
            }
            self.allFetchedMovies.append(contentsOf: searchResults)
            self.allFetchedMovies = removeDuplicates(from: allFetchedMovies)
        }
    }
    
    func saveFavoriteMovie(movie: Movie) {
        if let encodedMovie = try? JSONEncoder().encode(movie) {
            UserDefaults.standard.set(encodedMovie, forKey: "favoriteMovie-\(movie.id)")
        }
    }
    private func removeDuplicates(from movies: [Movie]) -> [Movie] {
        var uniqueMovies: [Movie] = []
        var seenIds: Set<Int> = []

        for movie in movies {
            if !seenIds.contains(movie.id) {
                uniqueMovies.append(movie)
                seenIds.insert(movie.id)
            }
        }

        return uniqueMovies
    }

    

}
