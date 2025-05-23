//
//  ContentView.swift
//  FlappyBird Watch App
//
//  Created by Moon Jongseek on 3/18/24.
//

import SwiftUI
import SpriteKit

public struct ContentView3: View{ //
    @Binding var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
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
