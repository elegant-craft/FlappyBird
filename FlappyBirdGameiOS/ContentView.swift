//
//  ContentView.swift
//  FlappyBird Watch App
//
//  Created by Moon Jongseek on 3/18/24.
//

import SwiftUI
import SpriteKit

public struct ContentView3: View{
    @Binding var isPresented: Bool
    @State var screenSize: CGSize
    
    public init(isPresented: Binding<Bool>, screenSize: CGSize) {
        self._isPresented = isPresented
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
            .onAppear {
                print("hello")
                print("\(geometryProxy.size)")
                print("\(geometryProxy.size.width)")
                print("\(geometryProxy.size.height)")
                print("hello")
            }
        }
        .ignoresSafeArea()
    }
}
