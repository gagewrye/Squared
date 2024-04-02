import SwiftUI
import UIKit
// TODO: make sure the photos are not distorted when displaying

struct ContentView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var squaredImages: [UIImage] = []
    @State private var selectedColor = Color.white
    @State private var isShowingImagePicker = false
    @State private var isBlurred = false
    @State private var isShowingMessage = false
    @State private var messageText = ""
    @State private var blurRegion: BlurRegion = .top
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer() // Push image to center

                // Display images if there are any
                if selectedImages.isEmpty {
                    Text("No Images Selected")
                        .font(.headline)
                        .foregroundColor(.gray)
                } else {
                    if squaredImages.isEmpty {
                        if selectedImages.count == 1 {
                            Image(uiImage: selectedImages.first!)
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width/1.2, height: UIScreen.main.bounds.width)
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(scale)
                                .gesture(MagnificationGesture()
                                    .onChanged { value in
                                        scale = value.magnitude
                                    })
                        } else {
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(selectedImages, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width/1.5, height: UIScreen.main.bounds.width/1.5)
                                        .aspectRatio(contentMode: .fit)
                                        .scaleEffect(scale)
                                        .gesture(MagnificationGesture()
                                            .onChanged { value in
                                                scale = value.magnitude
                                            }
                                        )
                                }
                            }
                        }
                    }
                }else {
                    if selectedImages.count == 1 {
                        Image(uiImage: squaredImages.first!)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/1.2, height: UIScreen.main.bounds.width)
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale)
                            .gesture(MagnificationGesture()
                            .onChanged { value in
                                scale = value.magnitude
                            })
                    } else {
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(squaredImages, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width/1.5, height: UIScreen.main.bounds.width/1.5)
                                        .aspectRatio(contentMode: .fit)
                                        .scaleEffect(scale)
                                        .gesture(MagnificationGesture()
                                            .onChanged { value in
                                                scale = value.magnitude
                                            }
                                        )
                            }
                        }
                    }
                }
            }
        }
                
                Spacer() // This will push the buttons to the bottom
                
                HStack {
                    VStack {
                        if isBlurred {
                            Button(action: {
                                blurRegion = .top
                            }) {
                                VStack {
                                    Text("Top")
                                }
                                .frame(width: 80, height: 40)
                                .background(blurRegion == .top ? Color.indigo : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.bottom, 3)
                            .padding(.leading, 30)
                            .onChange(of: blurRegion) { newBlur in
                                if !squaredImages.isEmpty {
                                    square(selectedImages: selectedImages)
                                }
                            }
                            
                            Button(action: {
                                blurRegion = .bottom
                            }) {
                                VStack {
                                    Text("Bottom")
                                }
                                .frame(width: 80, height: 40)
                                .background(blurRegion == .bottom ? Color.indigo : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.bottom, 3)
                            .padding(.leading, 30)
                            .onChange(of: blurRegion) { newBlur in
                                if !squaredImages.isEmpty {
                                    square(selectedImages: selectedImages)
                                }
                            }
                            
                            Button(action: {
                                blurRegion = .both
                            }) {
                                VStack {
                                    Text("Both")
                                }
                                .frame(width: 80, height: 40)
                                .background(blurRegion == .both ? Color.indigo : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.bottom, 10)
                            .padding(.leading, 30)
                            .onChange(of: blurRegion) { newBlur in
                                if !squaredImages.isEmpty {
                                    square(selectedImages: selectedImages)
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        isBlurred.toggle()
                        if isBlurred {
                            selectedColor = Color.white
                        }
                    }) {
                        Text("Blur")
                            .frame(width: 50, height: 20)
                            .font(.headline)
                            .padding()
                            .background(isBlurred ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .blur(radius: isBlurred ? 0.75 : 0)
                    }
                    .padding(20)
                    
                    // Color Picker Container
                    VStack {
                        ColorPicker("Color", selection: $selectedColor)
                            .labelsHidden()
                            .scaleEffect(2)
                            .padding(.bottom, 20)
                            .padding(.trailing, 132)
                            .onChange(of: selectedColor) { newColor in
                                if newColor != Color.white { isBlurred = false }
                                if !squaredImages.isEmpty {
                                    square(selectedImages: selectedImages)
                                }
                            }
                            .opacity(isBlurred ? 0 : 1) // Set opacity based on isBlurred value
                    }
                    .frame(maxWidth: .infinity) // Expand color picker container
                }
                
                HStack { // Horizontal Button stack
                    Button(action: { // Upload Images
                        selectedImages = []
                        squaredImages = []
                        isShowingImagePicker = true
                    }) {
                        Text("Upload Images")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $isShowingImagePicker) {
                        ImagePicker(selectedImages: $selectedImages, isPresented: $isShowingImagePicker)
                    }
                    
                    Button(action: { // Square images
                        if selectedImages.isEmpty {
                            showMessage(text: "Please select Images")
                        } else {
                            square(selectedImages: selectedImages)
                        }
                    }) {
                        Text("Square Images")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: { // Save Images
                    if squaredImages.isEmpty {
                        showMessage(text: "Images are not Squared")
                    } else {
                        for image in squaredImages {
                            saveImage(image)
                        }
                        showMessage(text: "Images Saved")
                        squaredImages = []
                        selectedImages = []
                    }
                }) {
                    Text("Save Images")
                        .font(.headline)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .message(isShowing: $isShowingMessage, text: Text(messageText))
        }
    }
    
    func showMessage(text: String) {
        messageText = text
        isShowingMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isShowingMessage = false
        }
    }
    
    func square(selectedImages: [UIImage]) {
        squaredImages = []
        if isBlurred {
            for image in selectedImages {
                if let squaredImage = squareImage(image: image, blurRegion: blurRegion) {
                    squaredImages.append(squaredImage)
                }
            }
        } else {
            for image in selectedImages {
                if let squaredImage = squareImage(image: image, color: selectedColor) {
                    squaredImages.append(squaredImage)
                }
            }
        }
    }
}
