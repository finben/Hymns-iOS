import SwiftUI
import Resolver

struct TagSheetView: View {

    @ObservedObject private var viewModel: TagSheetViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var tagNames = ""
    @State private var tagColor = TagColor.none
    @Binding var tagOn: Bool

    init(viewModel: TagSheetViewModel, tagOn: Binding<Bool>) {
        self.viewModel = viewModel
        self._tagOn = tagOn
    }

    var body: some View {
        VStack {
            HStack {
                Text("Name your tag").font(.body).fontWeight(.bold)
                Spacer()
            }
            HStack {
                TextField("Label it however you like", text: self.$tagNames)
            }
            Divider()
            SelectLabelView(tagColor: self.$tagColor)
            if self.viewModel.tags.isEmpty {
                EmptyView()
            } else {
                Section {
                    HStack {
                        Text("Tags").font(.body).fontWeight(.bold)
                        Spacer()
                    }.padding(.top)
                    HStack {
                        ForEach(self.viewModel.tags, id: \.self) { tag in
                            Button(action: {
                                //TODO FIX Delete is deleting all the tags because the button when clicked is clicking all of them.
                                self.viewModel.deleteTag(tagTitle: tag.title, tagColor: .blue)
                            }, label: {
                                HStack {
                                    Text(tag.title)
                                    Image(systemName: "xmark.circle")
                                }
                            })
                                .padding()
                                .foregroundColor(Color(tag.color.foreground))
                                .background(Color(tag.color.background))
                                .cornerRadius(30)
                                .lineLimit(1)
                        }
                    }
                }
            }
            HStack {
                Spacer()
                Button(action: {
                    self.tagOn.toggle()
                }, label: {
                    Text("Cancel")
                })
                Button("Add") {
                    self.viewModel.addTag(tagName: self.tagNames, tagColor: self.tagColor)
                }.disabled(tagNames.isEmpty || (tagColor == .none))
            }
        }.onAppear {
            self.viewModel.fetchHymn()
            self.viewModel.fetchTagsByHymn()
        }.padding()
    }
}

struct TagSheetView_Previews: PreviewProvider {
    static var previews: some View {
        TagSheetView(viewModel: TagSheetViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151), tagOn: .constant(true))
    }
}
