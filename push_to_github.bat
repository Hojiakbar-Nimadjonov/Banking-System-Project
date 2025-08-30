@echo off
echo Pushing Banking System Project to GitHub...
git add .
git commit -m "Initial commit: Complete Banking System with BI Dashboard"
git remote add origin https://github.com/Hojiakbar-Nimadjonov/Banking-System-Project.git
git push -u origin master
echo Push completed!
pause
