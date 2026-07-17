param(
  [Parameter(Mandatory = $true)]
  [string]$InputDirectory,
  [Parameter(Mandatory = $true)]
  [string]$OutputFile
)

# Uses the Arabic Windows OCR language pack and preserves a page delimiter so
# the scholarly source can be cited page-by-page during review.
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$null = [Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime]
$null = [Windows.Storage.Streams.IRandomAccessStream, Windows.Storage.Streams, ContentType = WindowsRuntime]
$null = [Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics.Imaging, ContentType = WindowsRuntime]
$null = [Windows.Graphics.Imaging.SoftwareBitmap, Windows.Graphics.Imaging, ContentType = WindowsRuntime]
$null = [Windows.Media.Ocr.OcrEngine, Windows.Media.Ocr, ContentType = WindowsRuntime]
$null = [Windows.Media.Ocr.OcrResult, Windows.Media.Ocr, ContentType = WindowsRuntime]
$null = [Windows.Globalization.Language, Windows.Globalization, ContentType = WindowsRuntime]

function Await-WinRt($Operation, [Type]$Type) {
  $method = [System.WindowsRuntimeSystemExtensions].GetMethods() |
    Where-Object {
      $_.Name -eq 'AsTask' -and
      $_.GetParameters().Count -eq 1 -and
      $_.GetGenericArguments().Count -eq 1
    } |
    Select-Object -First 1
  $task = $method.MakeGenericMethod($Type).Invoke($null, @($Operation))
  return $task.GetAwaiter().GetResult()
}

$engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromLanguage(
  [Windows.Globalization.Language]::new('ar-SA')
)
if ($null -eq $engine) { throw 'Arabic Windows OCR is unavailable.' }

$writer = [System.IO.StreamWriter]::new($OutputFile, $false, [System.Text.UTF8Encoding]::new($false))
try {
  $files = Get-ChildItem -LiteralPath $InputDirectory -Filter '*.jpg' |
    Sort-Object Name
  foreach ($filePath in $files) {
    $file = Await-WinRt (
      [Windows.Storage.StorageFile]::GetFileFromPathAsync($filePath.FullName)
    ) ([Windows.Storage.StorageFile])
    $stream = Await-WinRt (
      $file.OpenAsync([Windows.Storage.FileAccessMode]::Read)
    ) ([Windows.Storage.Streams.IRandomAccessStream])
    try {
      $decoder = Await-WinRt (
        [Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream)
      ) ([Windows.Graphics.Imaging.BitmapDecoder])
      $bitmap = Await-WinRt (
        $decoder.GetSoftwareBitmapAsync()
      ) ([Windows.Graphics.Imaging.SoftwareBitmap])
      try {
        $result = Await-WinRt ($engine.RecognizeAsync($bitmap)) ([Windows.Media.Ocr.OcrResult])
        $writer.WriteLine("`n===== $($filePath.Name) =====")
        $writer.WriteLine($result.Text)
      } finally {
        $bitmap.Dispose()
      }
    } finally {
      $stream.Dispose()
    }
  }
} finally {
  $writer.Dispose()
}
