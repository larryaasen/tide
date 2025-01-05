Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Write-Host "Starting screenshot capture..."

$screenshot = [System.Drawing.Bitmap]::new([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height)
$graphics = [System.Drawing.Graphics]::FromImage($screenshot)
$graphics.CopyFromScreen(0, 0, 0, 0, $screenshot.Size)
$screenshot.Save("screenshot.png", [System.Drawing.Imaging.ImageFormat]::Png)

Write-Host "Screenshot saved to screenshot.png"