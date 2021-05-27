//
//  ContentView.swift
//  MatchedGeometryEffect
//
//  Created by Chris Eidhof on 25.05.21.
//

import SwiftUI

struct FrameKey: PreferenceKey, EnvironmentKey {
    static var defaultValue: CGRect? = nil
    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = value ?? nextValue()
    }
}

extension EnvironmentValues {
    var frameKey: FrameKey.Value {
        get { self[FrameKey.self] }
        set { self[FrameKey.self] = newValue }
    }
}

struct MatchedGeometryEffect<ID: Hashable>: ViewModifier {
    var id: ID
    var namespace: Namespace.ID
    var isSource: Bool = true
    @Environment(\.frameKey) var frame
    
    func body(content: Content) -> some View {
        Group {
            if isSource {
                content
                    .overlay(GeometryReader { proxy in
                        let frame = proxy.frame(in: .global)
                        Color.clear.preference(key: FrameKey.self, value: frame)
                    })
            } else {
                content
                    .hidden()
                    .overlay(
                        content
                            .frame(width: frame?.size.width, height: frame?.size.height)
                        , alignment: .topLeading
                    )
            }
        }
    }
}

extension View {
    func myMatchedGeometryEffect<ID: Hashable>(useBuiltin: Bool = true, id: ID, in ns: Namespace.ID, isSource: Bool = true) -> some View {
        Group {
            if useBuiltin {
                self.matchedGeometryEffect(id: id, in: ns, properties: .size, isSource: isSource)
            } else {
                modifier(MatchedGeometryEffect(id: id, namespace: ns, isSource: isSource))
            }
        }
    }
}

struct Sample: View {
    var builtin = true
    @Namespace var ns
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color.red)
                .myMatchedGeometryEffect(useBuiltin: builtin, id: "ID", in: ns)
                .frame(width: 100, height: 100)
            Circle()
                .fill(Color.green)
                .myMatchedGeometryEffect(useBuiltin: builtin, id: "ID", in: ns, isSource: false)
                .frame(height: 50)
                .border(Color.blue)
        }.frame(width: 150, height: 100)
    }
}

struct ApplyGeometryEffects: ViewModifier {
    @State var sourceFrame: CGRect = .zero
    
    func body(content: Content) -> some View {
        content
            .environment(\.frameKey, sourceFrame)
            .onPreferenceChange(FrameKey.self) {
                sourceFrame = $0 ?? .zero
            }

    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Sample()
            Sample(builtin: false)
        }
        .modifier(ApplyGeometryEffects())
        .padding(100)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
