//
//  ContentView.swift
//  FlappyBird Watch App
//
//  Created by Moon Jongseek on 3/18/24.
//

import SwiftUI
import SpriteKit

public struct FlappyBirdGameView: View{
    
    public init() {
    }
    
    public var body: some View {
        GeometryReader { geometryProxy in
            let scene = GameScene(size: geometryProxy.size)
            SpriteView(scene: scene)
            .onTapGesture {
                scene.tapGesture()
            }
        }
        .ignoresSafeArea()
    }
}
