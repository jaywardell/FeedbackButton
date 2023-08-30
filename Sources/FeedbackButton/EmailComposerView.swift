//
//  EmailComposerView.swift
//  All Day iOS
//
//  Created by Joseph Wardell on 2/19/23.
//

import SwiftUI
import MessageUI

struct EmailData {
    var subject: String = ""
    var recipients: [String]?
    var body: String = ""
    var isBodyHTML = false
    var attachments = [AttachmentData]()
    
    struct AttachmentData {
        var data: Data
        var mimeType: String
        var fileName: String
    }
}

// MARK: -

struct EmailComposerView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) private var presentationMode
    let emailData: EmailData
    let onError: (Error) -> Void
    let onSuccess: ()->()

    static var canSendEmail: Bool {
        MFMailComposeViewController.canSendMail()
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        
        let emailComposer = MFMailComposeViewController()
        emailComposer.mailComposeDelegate = context.coordinator
        emailComposer.setSubject(emailData.subject)
        emailComposer.setToRecipients(emailData.recipients)
        emailComposer.setMessageBody(emailData.body, isHTML: emailData.isBodyHTML)
        for attachment in emailData.attachments {
            emailComposer.addAttachmentData(attachment.data, mimeType: attachment.mimeType, fileName: attachment.fileName)
        }
        return emailComposer

    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    struct UnknownError: Error {}
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: EmailComposerView
        
        init(_ parent: EmailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            
            if let error = error {
                parent.onError(error)
                return
            }
            
            switch result {
            case .saved, .sent:
                parent.onSuccess()
            default:
                parent.onError(UnknownError())
            }
                        
            parent.presentationMode.wrappedValue.dismiss()
        }

    }

}

