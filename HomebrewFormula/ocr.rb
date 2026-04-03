class Ocr < Formula
  desc "Command-line OCR tool built with Apple's Vision framework"
  homepage "https://github.com/maoxiaoke/macos-vision-ocr"
  version "1.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/maoxiaoke/macos-vision-ocr/releases/download/v1.2.0/ocr-macos-arm64-v1.2.0.zip"
      sha256 "c0ed60d458639e2a9ea951ac2f8973acdd455a94c29fb021de6cc095daf13601"
    else
      url "https://github.com/maoxiaoke/macos-vision-ocr/releases/download/v1.2.0/ocr-macos-x86_64-v1.2.0.zip"
      sha256 "1837da651f623e280e794c571962c6d1279b8f17c36e030b52d73d6d6dbc0db5"
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
