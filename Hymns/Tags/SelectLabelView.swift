import SwiftUI

struct SelectLabelView: View {
    @Binding var tagColor: TagColor
    @State var blueButton = false
    @State var greenButton = false
    @State var yellowButton = false
    @State var redButton = false

    var body: some View {
        VStack {
            HStack {
                Text("Select a color").font(.body).fontWeight(.bold)
                Spacer()
            }
            HStack {
                Button(action: {
                    self.tagColor = .blue
                    self.resetForBlue()
                }, label: {
                    Text("blue").font(.body).fontWeight(self.blueButton ? .bold : .none)
                }).padding(10)
                    .background(Color(CustomColors.backgroundBlue))
                    .foregroundColor(Color(CustomColors.foregroundBlue))
                    .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue, lineWidth: self.blueButton ? 3 : 0)
                )

                Button(action: {
                    self.tagColor = .green
                    self.resetForGreen()
                }, label: {
                    Text("green").font(.body).fontWeight(self.greenButton ? .bold : .none)
                }).padding(10)
                    .background(Color(CustomColors.backgroundGreen))
                    .foregroundColor(Color(CustomColors.foregroundGreen))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(CustomColors.foregroundGreen), lineWidth: self.greenButton ? 3 : 0)
                    )

                Button(action: {
                    self.tagColor = .yellow
                    self.resetForYellow()
                }, label: {
                    Text("yellow").font(.body).fontWeight(self.yellowButton ? .bold : .none)
                }).padding(10)
                    .background(Color(CustomColors.backgroundYellow))
                    .foregroundColor(Color(CustomColors.foregroundYellow))
                    .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(CustomColors.foregroundYellow), lineWidth: self.yellowButton ? 3 : 0)
                )

                Button(action: {
                    self.tagColor = .red
                    self.resetForRed()
                }, label: {
                    Text("red").font(.body).fontWeight(self.redButton ? .bold : .none)
                }).padding(10)
                    .background(Color(CustomColors.backgroundRed))
                    .foregroundColor(Color(CustomColors.foregroundRed))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(CustomColors.foregroundRed), lineWidth: self.redButton ? 3 : 0)
                )
                Spacer()
            }.padding(.top)
        }
    }

    private func resetForBlue() {
        self.greenButton = false
        self.redButton = false
        self.yellowButton = false
        self.blueButton.toggle()
    }

    private func resetForGreen() {
        self.blueButton = false
        self.redButton = false
        self.yellowButton = false
        self.greenButton.toggle()
    }

    private func resetForYellow() {
        self.blueButton = false
        self.greenButton = false
        self.redButton = false
        self.yellowButton.toggle()
    }

    private func resetForRed() {
        self.blueButton = false
        self.greenButton = false
        self.yellowButton = false
        self.redButton.toggle()
    }
}

struct SelectLabelView_Previews: PreviewProvider {
    static var previews: some View {
        SelectLabelView(tagColor: .constant(.blue))
    }
}
