import SwiftUI

struct DecimalTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .keyboardType(.decimalPad)
        #else
        content
        #endif
    }
}

struct AdaptiveListStyleModifier: ViewModifier {
    let style: ListStyle
    
    enum ListStyle {
        case sidebar
        case main
    }
    
    func body(content: Content) -> some View {
        #if os(macOS)
        switch style {
        case .sidebar:
            content.listStyle(.sidebar)
        case .main:
            content.listStyle(.inset)
        }
        #else
        switch style {
        case .sidebar:
            content.listStyle(.insetGrouped)
        case .main:
            content.listStyle(.plain)
        }
        #endif
    }
}

struct AdaptiveFormStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(macOS)
        content.formStyle(.grouped)
        #else
        content.formStyle(.insetGrouped)
        #endif
    }
}

extension View {
    func decimalTextField() -> some View {
        modifier(DecimalTextFieldModifier())
    }
    
    func adaptiveListStyle(_ style: AdaptiveListStyleModifier.ListStyle) -> some View {
        modifier(AdaptiveListStyleModifier(style: style))
    }
    
    func adaptiveFormStyle() -> some View {
        modifier(AdaptiveFormStyleModifier())
    }
} 