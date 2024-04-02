//
//  Message.swift
//  Photo Squarer
//
//  Created by Dillan Wrye on 6/26/23.
//

import Foundation
import SwiftUI

struct Message<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    let text: Text

    var body: some View {
        ZStack(alignment: .center) {
            self.presenting()
                .blur(radius: isShowing ? 3 : 0)

            VStack {
                text
            }
            .frame(width: 200, height: 100)
            .background(Color.secondary.colorInvert())
            .foregroundColor(Color.primary)
            .cornerRadius(20)
            .transition(.slide)
            .opacity(self.isShowing ? 1 : 0)
        }
    }
}

extension View {
    func message(isShowing: Binding<Bool>, text: Text) -> some View {
        Message(isShowing: isShowing,
              presenting: { self },
              text: text)
    }
}
