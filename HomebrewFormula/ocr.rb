class Ocr < Formula
  desc "Command-line OCR tool built with Apple's Vision framework"
  homepage "https://github.com/maoxiaoke/macos-vision-ocr"
  version "1.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/maoxiaoke/macos-vision-ocr/releases/download/v1.0.1/ocr-macos-arm64-v1.0.1.zip"
      sha256 "e2ced586caaea5f68aff7bf223e4b205c1acdf530de876eb5a99b62dbf356acc"
    else
      url "https://github.com/maoxiaoke/macos-vision-ocr/releases/download/v1.0.1/ocr-macos-x86_64-v1.0.1.zip"
      sha256 "70e24848a18131ca7bf7308e50eb4bdedeace23f6235529d821d7ba26bc0dd35"
    end
  end

  depends_on :macos

  def install
    if Hardware::CPU.arm?
      bin.install "ocr-arm64" => "ocr"
    else
      bin.install "ocr-x86_64" => "ocr"
    end
  end

  test do
    assert_match "ocr", shell_output("#{bin}/ocr --help")
  end
end
