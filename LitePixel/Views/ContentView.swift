import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var originalData: Data?
    @State private var compressionQuality: Double = 0.7
    @State private var showResult = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // ヘッダー
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.blue)
                        Text("LitePixel")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                    }
                    Text("画像を圧縮してファイルサイズを軽くしよう")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // 画像プレビュー
                if let image = selectedImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .cornerRadius(12)

                        // ×ボタン
                        Button {
                            selectedImage = nil
                            originalData = nil
                            selectedItem = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white, .red)
                        }
                        .padding(8)
                    }
                    .frame(height: 300)

                    // 元画像サイズ
                    if let data = originalData {
                        Text("元サイズ: \(ImageCompressor.formatFileSize(data.count))")
                            .foregroundColor(.secondary)
                    }

                    // 品質スライダー
                    VStack(alignment: .leading, spacing: 8) {
                        Text("圧縮品質: \(Int(compressionQuality * 100))%")
                            .font(.headline)
                        Slider(value: $compressionQuality, in: 0.1...1.0, step: 0.1)
                    }
                    .padding(.horizontal)

                    // 圧縮ボタン
                    Button(action: { showResult = true }) {
                        Label("圧縮する", systemImage: "arrow.down.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                } else {
                    // プレースホルダー（タップで画像選択）
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .overlay {
                                VStack {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("タップして画像を選択")
                                        .foregroundColor(.gray)
                                }
                            }
                    }
                }

                Spacer()

                // 画像選択ボタン
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("写真を選択", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedItem) { _, newItem in
                loadImage(from: newItem)
            }
            .sheet(isPresented: $showResult) {
                if let image = selectedImage, let original = originalData {
                    ResultView(
                        originalImage: image,
                        originalData: original,
                        quality: compressionQuality
                    )
                }
            }
        }
    }

    private func loadImage(from item: PhotosPickerItem?) {
        guard let item else { return }
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data, let uiImage = UIImage(data: data) {
                        self.originalData = data
                        self.selectedImage = uiImage
                    }
                case .failure:
                    break
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
