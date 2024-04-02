//
//  VideoView.swift
//  Photo Squarer
//
//  Created by Dillan Wrye on 7/16/23.
//
//
//  VideoView.swift
//  Photo Squarer
//
//  Created by Dillan Wrye on 7/16/23.
//

import SwiftUI
import UIKit
import AVKit

struct VideoView: View {
    @State private var VideoURL: URL?
    @State private var squaredVideoURL: URL?
    @State private var selectedColor = Color.white
    @State private var isShowingVideoPicker = false
    @State private var isBlurred = false
    @State private var isShowingMessage = false
    @State private var messageText = ""
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                // Display video if there is one
                if let videoURL = VideoURL {
                    let player = AVPlayer(url: videoURL)
                    VideoPlayer(player: player)
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .gesture(MagnificationGesture()
                            .onChanged { value in
                                scale = value.magnitude
                            }
                        )
                } else {
                    Text("No Video Selected")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                Spacer()
                // Color Picker Container
                ColorPicker("Color", selection: $selectedColor)
                    .labelsHidden()
                    .scaleEffect(2)
                    .padding(.bottom, 35)
                HStack { // Horizontal Button stack
                    Button(action: {
                        VideoURL = nil
                        squaredVideoURL = nil
                        isShowingVideoPicker = true
                    }) {
                        Text("Upload Video")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $isShowingVideoPicker) {
                        VideoPicker(videoURL: $VideoURL, isPresented: $isShowingVideoPicker)
                    }
                    
                    Button(action: {
                        if VideoURL == nil {
                            showMessage(text: "Please Upload Video")
                        } else {
                            squareVideo()
                        }
                    }) {
                        Text("Square Video")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    if VideoURL == nil {showMessage(text: "No Video Uploaded")}
                    else if squaredVideoURL == nil {showMessage(text: "Video is not Squared")
                    } else {
                        if let videoURL = squaredVideoURL {
                            saveVideo(videoURL: videoURL) { success, error in
                                if success {
                                    showMessage(text: "Video Saved to Photos")
                                    squaredVideoURL = nil
                                    VideoURL = nil
                                } else if let error = error {
                                    showMessage(text: "Failed to save video: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }) {
                    Text("Save Video")
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
    
    func squareVideo() {
        Task {
            do {
                if let videoURL = VideoURL {
                    squaredVideoURL = try await Photo_Squarer.squareVideo(url: videoURL, color: selectedColor)
                }
            } catch {
                debugPrint("Error: \(error)")
                print("Error: \(error.localizedDescription)")
                showMessage(text: "Could not Square Video")
            }
        }
    }
}
