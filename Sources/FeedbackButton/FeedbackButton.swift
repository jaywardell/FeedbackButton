//
//  FeedbackButton.swift
//  FeedbackButton
//
//  Created by Joseph Wardell on 2/19/23.
//

import SwiftUI

fileprivate struct Subject: Identifiable {
    let id = UUID()
    let title: String
    let subject: String
}


public struct FeedbackButton<LABELSTYLE: LabelStyle>: View {

    @Environment(\.openURL) var openURL

    fileprivate let subjects: [Subject]
    let feedbackEmailAddress: String
    let showSeparators: Bool
    let labelStyle: LABELSTYLE

    /// called whether the email is sent successfully or not.
    /// use this to know when the UI is finished
    let completed: () -> Void

    @State private var showEmailComposer = false
    @State private var selectedSubject: Subject?
    @State private var showingAlert = false
    @State private var alertMessage: String = ""

    #if canImport(UIKit)


    private func emailData(for subject: Subject) -> EmailData {
        return EmailData(subject: subject.subject, recipients: [feedbackEmailAddress])
    }
    #endif

    private func options() -> some View {
        Group {
            Button("\(subjects[0].title)…", action: {  userChose(subjects[0]) })

            if showSeparators {
                Divider()
            }

            ForEach(subjects.suffix(from: 1)) { subject in
                Button("\(subject.title)…", action: {  userChose(subject) })
            }
        }
    }

    public var body: some View {
    #if os(macOS)
        options()
    #else
        Button(action: { userChose(subjects[0]) }) {
            Label(primaryLabel, systemImage: "questionmark.bubble")
                .labelStyle(labelStyle)
                .imageScale(.large)
                .overlay {
                    if subjects.count > 1 && labelStyle is IconOnlyLabelStyle {
                        Image(systemName: "ellipsis")
                            .imageScale(.small)
                            .accessibilityLabel(moreOptionsLabel)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
                }
        }
        .contextMenu(menuItems: {
            options()
        })

        #if canImport(MessageUI)
        .sheet(item: $selectedSubject) { subject in
            EmailComposerView(emailData: emailData(for: subject), onError: couldNotSendEmail(error:), onSuccess: emailWasSent)
        }
        #endif
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text(emailFailureTitle),
                  message: Text(alertMessage),
                  dismissButton: .cancel())
        })
    #endif
    }

    private func userChose(_ subject: Subject) {
        #if canImport(MessageUI)
        if EmailComposerView.canSendEmail {
            print(#function)
            selectedSubject = subject
            showEmailComposer = true
        }
        else {
            openEmailURL(subject: subject.subject)
        }
        #else
        openEmailURL(subject: subject.subject)
        #endif
    }

    private func openEmailURL(subject: String) {
        if !openURL.open(URLComponents(emailTo: feedbackEmailAddress, subject: subject)) {
            alertMessage = emailFailureMessage
            showingAlert = true
        }
    }

    private func couldNotSendEmail(error: Error) {
        print(#function, error)
        alertMessage = error.localizedDescription
        showingAlert = true
        completed()
    }

    private func emailWasSent() {
        print(#function)
        completed()
    }
}

fileprivate extension FeedbackButton {
    private var primaryLabel: String { "Send Feedback for \(Bundle.main.appName)…" }
    private var moreOptionsLabel: String { "press and hold for more options" }
    private var emailFailureTitle: String { "Could not send email" }
    private var emailFailureMessage: String { "could not create email" }
}

public extension FeedbackButton where LABELSTYLE == IconOnlyLabelStyle {
    init(_ address: String, subject: String, showSeparators: Bool = true, completed: @escaping ()->() = {}) {
        self.feedbackEmailAddress = address
        self.subjects = [Subject(title: subject, subject: subject)]
        self.labelStyle = .iconOnly
        self.completed = completed
        self.showSeparators = showSeparators
    }

    init(_ address: String, subjects: [(String, String)], showSeparators: Bool = true) {
        assert(subjects.count > 0)

        self.feedbackEmailAddress = address
        self.subjects = subjects.map { Subject(title: $0.0, subject: $0.1) }
        self.labelStyle = .iconOnly
        self.completed = {}
        self.showSeparators = showSeparators
    }
}

public extension FeedbackButton where LABELSTYLE == TitleOnlyLabelStyle {
    init(_ address: String, subject: String, showSeparators: Bool = true, completed: @escaping ()->() = {}) {
        self.feedbackEmailAddress = address
        self.subjects = [Subject(title: subject, subject: subject)]
        self.labelStyle = .titleOnly
        self.completed = completed
        self.showSeparators = showSeparators
    }

    init(_ address: String, subjects: [(String, String)], showSeparators: Bool = true) {
        assert(subjects.count > 0)

        self.feedbackEmailAddress = address
        self.subjects = subjects.map { Subject(title: $0.0, subject: $0.1) }
        self.labelStyle = .titleOnly
        self.completed = {}
        self.showSeparators = showSeparators
    }
}

@available(macOS 11.3, *)
public extension FeedbackButton where LABELSTYLE == TitleAndIconLabelStyle {
    init(_ address: String, subject: String, showSeparators: Bool = true, completed: @escaping ()->() = {}) {
        self.feedbackEmailAddress = address
        self.subjects = [Subject(title: subject, subject: subject)]
        self.labelStyle = .titleAndIcon
        self.completed = completed
        self.showSeparators = showSeparators
    }

    init(_ address: String, subjects: [(String, String)], showSeparators: Bool = true) {
        assert(subjects.count > 0)

        self.feedbackEmailAddress = address
        self.subjects = subjects.map { Subject(title: $0.0, subject: $0.1) }
        self.labelStyle = .titleAndIcon
        self.completed = {}
        self.showSeparators = showSeparators
    }
}

extension FeedbackButton {
    func onUserSelected(_ completion: @escaping ()->()) -> FeedbackButton {
        FeedbackButton(subjects: subjects, feedbackEmailAddress: feedbackEmailAddress, showSeparators: showSeparators, labelStyle: labelStyle, completed: completion)
    }
}

extension FeedbackButton {
    func labelStyle<LS: LabelStyle>(_ labelStyle: LS) -> FeedbackButton<LS> {
        FeedbackButton<LS>(subjects: self.subjects,
              feedbackEmailAddress: self.feedbackEmailAddress,
                           showSeparators: showSeparators, labelStyle: labelStyle,
              completed: self.completed)
    }
}


@available(iOS 14.5, macOS 11.3, tvOS 14.5, watchOS 7.4, *)
struct FeedbackButton_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackButton<IconOnlyLabelStyle>("someone@somewhere.net", subjects: [
            ("Help!!!", "Help"),
            ("Me", "Meeee"),
            ("Out", "OUTTTT")])
        .previewDisplayName("Multiple Subjects")
        .previewLayout(.sizeThatFits)
        
        FeedbackButton<TitleAndIconLabelStyle>("someone@somewhere.net", subjects: [
            ("Help!!!", "Help"),
            ("Me", "Meeee"),
            ("Out", "OUTTTT")])
        .previewDisplayName("Multiple Subjects")
        .previewLayout(.sizeThatFits)

        FeedbackButton<TitleOnlyLabelStyle>("someone@somewhere.net", subject: "Help")
            .previewDisplayName("Single Subject")
            .previewLayout(.sizeThatFits)
    }
}
