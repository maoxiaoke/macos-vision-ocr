class Ocr < Formula
  desc "Command-line OCR tool built with Apple's Vision framework"
  homepage "https://github.com/maoxiaoke/macos-vision-ocr"
  version "VERSION"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/maoxiaoke/macos-vision-ocr/releases/download/vVERSION/ocr-macos-arm64-vVERSION.zip"
      sha256 "SHA256_ARM64"
    else
      url "https://github.com/maoxiaoke/macos-vision-ocr/releases/download/vVERSION/ocr-macos-x86_64-vVERSION.zip"
      sha256 "SHA256_X86_64"
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
