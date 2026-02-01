import SwiftUI

struct ResultView: View {
    @Environment(\.dismiss) private var dismiss

    let originalImage: UIImage
    let originalData: Data
    let quality: Double

    @State private var compressedData: Data?
    @State private var compressedImage: UIImage?
    @State private var showSaveAlert = false
    @State private var saveMessage = ""
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 圧縮後画像プレビュー
                    if let image = compressedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .cornerRadius(12)
                    }

                    // サイズ比較
                    if let compressed = compressedData {
                        VStack(spacing: 12) {
                            HStack {
                                Text("元サイズ")
                                Spacer()
                                Text(ImageCompressor.formatFileSize(originalData.count))
                                    .foregroundColor(.secondary)
                            }

                            HStack {
                                Text("圧縮後")
                                Spacer()
                                Text(ImageCompressor.formatFileSize(compressed.count))
                                    .foregroundColor(.green)
                                    .fontWeight(.semibold)
                            }

                            Divider()

                            HStack {
                                Text("削減率")
                                Spacer()
                                Text(String(format: "%.1f%%", ImageCompressor.compressionRatio(
                                    original: originalData.count,
                                    compressed: compressed.count
                                )))
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }

                    // アクションボタン
                    VStack(spacing: 12) {
                        // カメラロールに保存
                        Button(action: saveToPhotoLibrary) {
                            Label("カメラロールに保存", systemImage: "square.and.arrow.down")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        // 共有
                        if compressedImage != nil {
                            Button(action: { showShareSheet = true }) {
                                Label("共有", systemImage: "square.and.arrow.up")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("圧縮結果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                compressImage()
            }
            .alert("保存", isPresented: $showSaveAlert) {
                Button("OK") {}
            } message: {
                Text(saveMessage)
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = compressedImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }

    private func compressImage() {
        if let data = ImageCompressor.compress(originalImage, quality: quality) {
            compressedData = data
            compressedImage = UIImage(data: data)
        }
    }

    private func saveToPhotoLibrary() {
        guard let image = compressedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        saveMessage = "カメラロールに保存しました"
        showSaveAlert = true
    }
}

// 共有シート
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ResultView(
        originalImage: UIImage(systemName: "photo")!,
        originalData: Data(),
        quality: 0.7
    )
}
