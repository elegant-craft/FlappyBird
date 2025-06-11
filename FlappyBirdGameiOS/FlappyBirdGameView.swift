//
//  ContentView.swift
//  FlappyBird Watch App
//
//  Created by Moon Jongseek on 3/18/24.
//

import SwiftUI
import SpriteKit

public struct FlappyBirdGameView: View{
    @State var screenSize: CGSize
    
    public init(screenSize: CGSize) {
        self.screenSize = screenSize
    }
    
    public var body: some View {
        GeometryReader { geometryProxy in
//            let scene = GameScene(size: geometryProxy.size)
            let scene = GameScene(size: CGSize(width: screenSize.width / 2, height: screenSize.height / 2))
            SpriteView(scene: scene)
            .onTapGesture {
                scene.tapGesture()
            }
        }
        .ignoresSafeArea()
    }
}
