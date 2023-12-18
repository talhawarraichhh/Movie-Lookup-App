//
//  MovieCard.swift
//  MovieLookup
//
//  Created by Talha Warraich on 2023-05-01.
//

import Foundation
import SwiftUI

struct MovieCard: View {

    let MovieItem: Movie
    @State private var isFavorite = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: MovieItem.backdropURL) { image in
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
                    Text(MovieItem.title)
                        .foregroundColor(.white)
                        .fontWeight(.heavy)
                    Spacer()
                    Button(action: {
                        isFavorite.toggle()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .yellow)
                    }
                }
                HStack {
                    Image(systemName: "hand.thumbsup.fill")
                    Text(String(format: "%.1f", MovieItem.vote_average))
                    Spacer()
                }
                .foregroundColor(MovieItem.vote_average > 5 ? Color.green : Color.red)
                .fontWeight(.heavy)
            }
            .padding()
            .background(.black)
        }
        .cornerRadius(10)
    }
}

