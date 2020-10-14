//
//  ContentView.swift
//  SwiftUIGrids
//
//  Created by Ashish Tyagi on 14/10/20.
//

import SwiftUI
import KingfisherSwiftUI

struct RSS: Decodable {
    let feed: Feed
}

struct Feed: Decodable {
    let results: [Result]
}

struct Result: Decodable, Hashable {
    let copyright, name, artworkUrl100, releaseDate: String
}

class GridViewModel: ObservableObject {
    @Published var results = [Result]()
    init() {
            guard let url = URL(string: "https://rss.itunes.apple.com/api/v1/us/ios-apps/new-apps-we-love/all/100/explicit.json") else { return }

            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                do {
                let rss = try JSONDecoder().decode(RSS.self,from: data)
                print(rss)
                self.results = rss.feed.results
            }
            catch  {
                print("Failed to decode: \(error)")
            }
        }.resume()
  }
}


struct ContentView: View {
    @ObservedObject var gridViewModel = GridViewModel()
    var body: some View {
        NavigationView {
            ScrollView{
                LazyVGrid(columns:
                            [GridItem(.flexible(minimum: 100, maximum: 200),spacing: 12,alignment: .top),
                             GridItem(.flexible(minimum: 100, maximum: 200),spacing: 12,alignment: .top),
                             GridItem(.flexible(minimum: 100, maximum: 200),alignment: .top)],alignment: .leading, spacing: 16,
                    content:{
                        
                        ForEach(gridViewModel.results, id: \.self) { app in
                            VStack(alignment: .leading, spacing: 4) {
                                KFImage(URL(string: app.artworkUrl100))
                                .resizable()
                                .cornerRadius(8.0)
                                .scaledToFit()

                                Text(app.name)
                                    .font(.system(size: 10, weight: .semibold))
                                    .padding(.top, 4)
                                Text(app.releaseDate)
                                    .font(.system(size: 9, weight: .regular))
                                Text(app.copyright)
                                    .font(.system(size: 9, weight: .regular))
                                    .foregroundColor(.gray)
                                Spacer()

                            }
                        }
                    }).padding(.horizontal, 12)
            }
            .navigationTitle("Grid View")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
