# Flutter clean and get dependencies
Write-Host "Cleaning project..." -ForegroundColor Green
flutter clean

Write-Host "Getting dependencies..." -ForegroundColor Green
flutter pub get

Write-Host "Running build_runner..." -ForegroundColor Green
flutter pub run build_runner build --delete-conflicting-outputs

Write-Host "Setup complete!" -ForegroundColor Green 