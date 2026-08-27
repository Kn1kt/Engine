import SwiftUI
import Engine

struct CrashWithMisalignedRawPointer: View {
  @State private var stepper: Int = .zero
  @State private var path: [Int] = []

  var body: some View {
    if #available(iOS 16.0, *) {
      NavigationStack(path: $path) {
        Button("Navigate to Crash") {
          path.append(0)
        }
        .navigationDestination(for: Int.self) { _ in
          Text("Detail View")
            .toolbar {
              ToolbarItem(placement: .title) {
                StepperView2 {
                  Text("\(stepper)")
                } onIncrement: {
                  stepper += 1
                } onDecrement: {
                  stepper -= 1
                }
              }
            }
        }
      }
    }
  }
}

protocol StepperViewStyle2: ViewStyle where Configuration == StepperViewStyleConfiguration2 {
  associatedtype Configuration = Configuration
}

struct StepperViewStyleConfiguration2 {
  struct Label: ViewAlias { }
  var label: Label { .init() }

  var onIncrement: () -> Void
  var onDecrement: () -> Void
}

struct AutomaticStepperViewStyle2: StepperViewStyle2 {
  func makeBody(configuration: Configuration) -> some View {
    StepperView2(configuration)
      .stepperViewStyle2(DefaultStepperViewStyle2(), predicate: .toolbar)
      .stepperViewStyle2(InlineStepperViewStyle2())
  }
}

struct DefaultStepperViewStyle2: StepperViewStyle2 {
  func makeBody(configuration: Configuration) -> some View {
    Stepper {
      configuration.label
    } onIncrement: {
      configuration.onIncrement()
    } onDecrement: {
      configuration.onDecrement()
    }
  }
}

struct InlineStepperViewStyle2: StepperViewStyle2 {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      Button {
        configuration.onDecrement()
      } label: {
        Image(systemName: "minus.circle.fill")
      }

      configuration.label

      Button {
        configuration.onIncrement()
      } label: {
        Image(systemName: "plus.circle.fill")
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityAdjustableAction { direction in
      switch direction {
      case .increment:
        configuration.onIncrement()
      case .decrement:
        configuration.onDecrement()
      default:
        break
      }
    }
  }
}

extension View {
  func stepperViewStyle2<Style: StepperViewStyle2>(_ style: Style) -> some View {
    styledViewStyle(StepperViewBody2.self, style: style)
  }

  func stepperViewStyle2<
    Style: StepperViewStyle2,
    Context: StyleContext,
  >(_ style: Style, predicate: Context) -> some View {
    styledViewStyle(StepperViewBody2.self, style: style, predicate: predicate)
  }
}

struct StepperView2<Label: View>: View {
  var label: Label
  var onIncrement: () -> Void
  var onDecrement: () -> Void

  init(
    @ViewBuilder label: () -> Label,
    onIncrement: @escaping () -> Void,
    onDecrement: @escaping () -> Void
  ) {
    self.label = label()
    self.onIncrement = onIncrement
    self.onDecrement = onDecrement
  }

  var body: some View {
    StepperViewBody2(
      configuration: .init(
        onIncrement: onIncrement,
        onDecrement: onDecrement
      )
    )
    .viewAlias(StepperViewStyleConfiguration2.Label.self) {
      label
    }
  }
}

extension StepperView2 where Label == StepperViewStyleConfiguration2.Label {
  init(_ configuration: StepperViewStyleConfiguration2) {
    self.label = configuration.label
    self.onIncrement = configuration.onIncrement
    self.onDecrement = configuration.onDecrement
  }
}

struct StepperViewBody2: ViewStyledView {
  var configuration: StepperViewStyleConfiguration2

  static var defaultStyle: some StepperViewStyle2 {
    AutomaticStepperViewStyle2()
  }
}
