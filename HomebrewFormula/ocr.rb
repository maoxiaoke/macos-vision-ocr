class Ocr < Formula
  desc "Command-line OCR tool built with Apple's Vision framework"
  homepage "https://github.com/maoxiaoke/macos-vision-ocr"
  version "1.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/maoxiaoke/macos-vision-ocr/releases/download/v1.1.0/ocr-macos-arm64-v1.1.0.zip"
      sha256 "b23b15b19b547e27a7fc14170e60264c7e7ee05f564c981528f53bfa7854b504"
    else
      url "https://github.com/maoxiaoke/macos-vision-ocr/releases/download/v1.1.0/ocr-macos-x86_64-v1.1.0.zip"
      sha256 "22d6e6b61b98bf2c476e39eac28acfac541ad5b4cda7a82a3854626abbf2245f"
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
