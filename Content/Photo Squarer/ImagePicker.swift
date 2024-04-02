import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Binding var isPresented: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = Int.max // Allow maximum selection
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // No update needed
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false

            for result in results {
                if result.itemProvider.hasItemConformingToTypeIdentifier("public.image") {
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { url, error in
                        if let error = error {
                            print("Error loading image: \(error)")
                        } else if let url = url {
                            let data = try? Data(contentsOf: url)
                            if let imageData = data {
                                if let image = UIImage(data: imageData) {
                                    DispatchQueue.main.async {
                                        self.parent.selectedImages.append(image)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }



    }
}
