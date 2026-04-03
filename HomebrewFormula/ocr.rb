class Ocr < Formula
  desc "Command-line OCR tool built with Apple's Vision framework"
  homepage "https://github.com/maoxiaoke/macos-vision-ocr"
  version "1.0.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/maoxiaoke/macos-vision-ocr/releases/download/v1.0.0/ocr-macos-arm64-v1.0.0.zip"
      sha256 "cd44b874fc105a1bb0b649013e537dda3d4c9445e73b3c3d61818231be15fba7"
    else
      url "https://github.com/maoxiaoke/macos-vision-ocr/releases/download/v1.0.0/ocr-macos-x86_64-v1.0.0.zip"
      sha256 "4685dea7c03fe4fc58f20e376079c9d7a1ed1ce0d042bfb04164b8b233b68019"
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
