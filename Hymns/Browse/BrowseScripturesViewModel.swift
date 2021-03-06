import Combine
import Resolver

class BrowseScripturesViewModel: ObservableObject {

    @Published var scriptures: [ScriptureViewModel]? = [ScriptureViewModel]()

    private let backgroundQueue: DispatchQueue
    private let mainQueue: DispatchQueue
    private let repository: BrowseRepository

    private var disposables = Set<AnyCancellable>()

    init(backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         repository: BrowseRepository = Resolver.resolve()) {
        self.backgroundQueue = backgroundQueue
        self.mainQueue = mainQueue
        self.repository = repository
    }

    // swiftlint:disable:next cyclomatic_complexity
    func fetchScriptureSongs() {
        repository.scriptureSongs()
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .sink(receiveCompletion: { state in
                switch state {
                case .failure :
                    self.scriptures = nil
                case .finished:
                    break
                }
            }, receiveValue: { results in
                guard !results.isEmpty else {
                    self.scriptures = nil
                    return
                }
                let sorted = results.sorted { result1, result2 -> Bool in
                    if result1.book != result2.book {
                        return result1.book.rawValue < result2.book.rawValue
                    }
                    if result1.chapter?.isEmpty ?? true && result2.chapter?.isEmpty ?? true {
                        return true
                    }
                    guard let chapter1 = result1.chapter, let chapter2 = result2.chapter else {
                        if result1.chapter?.isEmpty ?? true {
                            return true
                        } else {
                            return false
                        }
                    }
                    if chapter1 != chapter2 {
                        return chapter1 < chapter2
                    }

                    if result1.verse?.isEmpty ?? true && result2.verse?.isEmpty ?? true {
                        return true
                    }
                    guard let verse1 = result1.verse, let verse2 = result2.verse else {
                        if result1.verse?.isEmpty ?? true {
                            return true
                        } else {
                            return false
                        }
                    }
                    return verse1 < verse2
                }

                var previousBook: Book?
                var songs = [ScriptureSongViewModel]()
                self.scriptures = sorted.reduce(into: [ScriptureViewModel]()) { results, result in
                    let hymnIdentifier = result.hymnIdentifier
                    let title = result.title.replacingOccurrences(of: "Hymn: ", with: "")
                    let book = result.book

                    if previousBook == nil {
                        previousBook = book
                    } else if previousBook != book {
                        // add the current book to viewModels and reset the list for the next book
                        let viewModel = ScriptureViewModel(book: previousBook!, scriptureSongs: songs)
                        results.append(viewModel)

                        previousBook = book
                        songs = [ScriptureSongViewModel]()
                    }

                    let reference: String
                    if let chapter = result.chapter, !chapter.isEmpty {
                        if let verse = result.verse, !verse.isEmpty {
                            reference = "\(chapter):\(verse)"
                        } else {
                            reference = chapter
                        }
                    } else {
                        reference = "General"
                    }

                    let song = ScriptureSongViewModel(reference: reference, title: title, hymnIdentifier: hymnIdentifier)
                    songs.append(song)

                    // we are at the end of the list, so we add the current song to the list and add the book to the
                    // list of books
                    if result == sorted.last {
                        let viewModel = ScriptureViewModel(book: previousBook!, scriptureSongs: songs)
                        results.append(viewModel)
                    }
                }
            }).store(in: &disposables)
    }
}
