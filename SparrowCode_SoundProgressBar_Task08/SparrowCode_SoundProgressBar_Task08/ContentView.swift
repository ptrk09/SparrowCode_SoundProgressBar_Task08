import SwiftUI

private enum Constants {
    enum Offset {
        static let topOffsetForExpand: CGFloat = -20
        static let bottomOffsetForExpand: CGFloat = 20
    }

    enum Height {
        static let expandHeight: CGFloat = 220
        static let stdHeight: CGFloat = 200
    }

    enum Width {
        static let expandWidth: CGFloat = 80
        static let stdWidth: CGFloat = 90
    }

    enum Layout {
        static let cornerRadius: CGFloat = 22
    }
}

struct ContentView: View {
    enum ExpandDirection {
        case top
        case bottom
        case `default`
    }

    @State private var expandDirection: ExpandDirection = .default
    @State private var currentProgress: CGFloat = 0
    @State private var lastProgress: CGFloat = 0

    var body: some View {
        ZStack {
            Background()

            GeometryReader { proxy in
                SoundBar()
                    .gesture(makeNeedGesture(geometryProxy: proxy))
            }
            .frame(width: calculateWidth(), height: calculateHeight())
            .offset(y: calculateVertcalOffset())
        }
        .environment(\.colorScheme, .dark)
    }
}

extension ContentView {
    @ViewBuilder
    private func Background() -> some View {
        Image("Background")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .blur(radius: 20)
            .ignoresSafeArea()
    }

    @ViewBuilder
    private func SoundBar() -> some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.ultraThinMaterial)
            Rectangle()
                .fill(.white)
                .scaleEffect(y: currentProgress, anchor: .bottom)
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: Constants.Layout.cornerRadius
            )
        )
    }
}

extension ContentView {
    fileprivate func makeNeedGesture(
        geometryProxy: GeometryProxy
    ) -> some Gesture {
        DragGesture()
            .onChanged {
                let offset = $0.startLocation.y - $0.location.y
                let progress = lastProgress + (offset / geometryProxy.size.height)

                withAnimation {
                    estimateExpand(progressOffset: progress)
                }

                currentProgress = max(0, min(1, progress))
            }
            .onEnded { _ in
                withAnimation {
                    commitProgressEditing()
                }
            }
    }
}

extension ContentView {
    private func commitProgressEditing() {
        expandDirection = .default
        lastProgress = currentProgress
    }

    private func estimateExpand(progressOffset: CGFloat) {
        if progressOffset > 1 {
            expandDirection = .top
            return
        }

        if progressOffset < 0 {
            expandDirection = .bottom
            return
        }

        expandDirection = .default
    }
}

extension ContentView {
    private func calculateVertcalOffset() -> CGFloat {
        switch expandDirection {
        case .top: Constants.Offset.topOffsetForExpand
        case .bottom: Constants.Offset.bottomOffsetForExpand
        case .default: 0
        }
    }

    private func calculateHeight() -> CGFloat {
        switch expandDirection {
        case .top, .bottom: Constants.Height.expandHeight
        case .default: Constants.Height.stdHeight
        }
    }

    private func calculateWidth() -> CGFloat {
        switch expandDirection {
        case .top, .bottom: Constants.Width.expandWidth
        case .default: Constants.Width.stdWidth
        }
    }
}

#Preview {
    ContentView()
}
