

import Foundation
import SwiftUI

struct MovieDetailView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject var model = MovieDetailsViewModel()
    let movie: Movie
    let headerHeight: CGFloat = 400

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { geo in
                VStack {
                    AsyncImage(url: movie.backdropURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: geo.size.width, maxHeight: headerHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    } placeholder: {
                        ProgressView()
                    }
                    Spacer()
                }
            }

            ScrollView {
                VStack(spacing: 12) {
                    Spacer()
                        .frame(height: headerHeight)
                    HStack {
                        Text(movie.title)
                            .foregroundColor(.white)
                            .font(.title)
                            .fontWeight(.heavy)
                        Spacer()
                        // ratings here
                    }

                    HStack {
                        // genre tags

                        // running time
                    }

                    HStack {
                        Text("About film")
                            .foregroundColor(.white)
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                        // see all button
                    }

                    Text(movie.overview)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        

                    HStack {
                        Text("Cast & Crew")
                            .font(.title3)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        Spacer()
                        // see all button
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(model.castProfiles) { cast in
                                CastView(cast: cast)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .ignoresSafeArea()
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .fontWeight(.bold)
            }
            .padding(.leading)
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await model.movieCredits(for: movie.id)
            await model.loadCastProfiles()
        }
    }

}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(movie: .preview)
    }
}

