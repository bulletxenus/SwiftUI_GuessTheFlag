//
//  ContentView.swift
//  SwiftUI_GuessFlag
//
//  Created by Dzmitry Khamitsevich on 6.12.23.
//

import SwiftUI

struct CustomGradient: View {
    var body: some View {
        RadialGradient(stops: [
            Gradient.Stop(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
            Gradient.Stop(color: Color(red: 0.76, green: 0.12, blue: 0.26), location: 0.3)
        ], center: .top, startRadius: 300, endRadius: 800)
            .ignoresSafeArea()
    }
}

struct FlagStyles: ViewModifier {
    func body(content: Content) -> some View {
        content
            .border(Color(CGColor(red: 0, green: 0, blue: 0, alpha: 0.4)), width: 1)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
            .shadow(color: .black, radius: 10, x: 0, y: 20)
    }
}

struct FlagImage: View {
    var flagName: String
    var onPress: () -> Void
    
    
    var body: some View {
        Button {
            onPress()
        } label: {
            Image("\(flagName)")
        }
        .flagStyle()
    }
    
    init(_ flagName: String, onPress: @escaping () -> Void) {
        self.flagName = flagName
        self.onPress = onPress
    }
}

struct FlagAnimation: ViewModifier {
    var isSelected: Bool
    var animationValue: Double
    var isAnimate: Bool
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isSelected ? animationValue : 0),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .rotation3DEffect(.degrees(!isSelected ? -animationValue : 0),
                            axis: (x: 0.0, y: 0.0, z: 1.0))
            .opacity(!isSelected && isAnimate ? 0.25 : 1)
            .scaleEffect(!isSelected && isAnimate ? 0.5 : 1)
            .animation(isAnimate ? .bouncy : nil, value: animationValue)
    }
}

extension View {
    func flagStyle() -> some View {
        modifier(FlagStyles())
    }
}

extension View {
    func animateFlag(isSelected: Bool, animationValue: Double, isAnimate: Bool) -> some View {
        modifier(FlagAnimation(isSelected: isSelected, animationValue: animationValue, isAnimate: isAnimate))
        
    }
}



struct ContentView: View {
    let maxNumberOfQuestions = 8
    
    @State private var countries = [
    "Estonia", "France", "Germany", "Ireland", "Italy", "Monaco",
    "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"
    ]
    @State var correctAnswerIndex = Int.random(in: 0...2)
    @State private var showingScore = false
    @State private var alertTitle = ""
    @State private var score = 0
    @State private var alertMessage = ""
    @State private var currentQuestionNumber = -1
    @State private var showFinalAlert = false
    
    @State private var flagRotation = 0.0
    @State var selectedFlag = -1
    @State private var isAnimate = false
    
    func askQuestion() {
        currentQuestionNumber += 1
        countries.shuffle()
        correctAnswerIndex = Int.random(in: 0...2)
        isAnimate = false
        flagRotation = 0.0
        selectedFlag = -1
    }
    
    func flagTapped(_ number: Int) {
        isAnimate = true
        flagRotation += 360.0
        selectedFlag = number
        
        if number == correctAnswerIndex {
            alertTitle = "Correct"
            alertMessage = "Congrats, you've answered right!"
            score += 1
        } else {
            alertTitle = "Wrong"
            alertMessage = "You're tapped on the flag of \(countries[number])"
            score -= 1
        }
        
        checkIsGameFinished()
    }
    
    func checkIsGameFinished() {
        if currentQuestionNumber >= maxNumberOfQuestions {
            showFinalAlert = true
        } else {
            showingScore = true
        }
    }
    
    func resetGame() {
        showingScore = false
        alertTitle = ""
        score = 0
        alertMessage = ""
        currentQuestionNumber = -1
        showFinalAlert = false
        isAnimate = false
        
        askQuestion()
    }
    
    var body: some View {
       
            ZStack {
                CustomGradient()
                VStack(spacing: 30) {
                    HStack {
                        Spacer()
                        Spacer()
                        VStack {
                            Text("Tap the flag of:")
                                .font(.headline.weight(.bold))
                            Text(countries[correctAnswerIndex])
                                .font(.largeTitle.weight(.semibold))
                        }
            
                        Spacer()
                        VStack {
                            Text("Score:")
                            Text(score, format: .number)
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(width: 400, height: .none, alignment: .trailing)

                    
                    ForEach(0..<3) { idx in
                        FlagImage(countries[idx]) {
                            flagTapped(idx)
                        }
                        .animateFlag(isSelected: selectedFlag == idx, animationValue: flagRotation, isAnimate: isAnimate)
                        

                    }
                }
            }
            .alert(alertTitle, isPresented: $showingScore) {
                Button("Next question") {
                    askQuestion()
                }
            } message: {
                Text(alertMessage)
            }
            .alert("You've finished the game", isPresented: $showFinalAlert) {
                Button("Start new game") {
                    resetGame()
                }
            } message: {
                Text("Your score is \(score)")
            }
    }
}

#Preview {
    ContentView()
}
