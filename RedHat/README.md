Keyboard shortcuts:
Ctrl + A: Jump the start of the command line.
Ctrl + E: Jump the end of the command line.
Ctrl + U: Clear from the cursor to the beginning of the command line.
Ctrl + K: Clear from the cursor to the end of the command line.
Ctrl + LeftArrow: Jump to the previous word.
Ctrl + RightArrow: Same but to the end.
Ctrl + R: Search history. Start typing and press enter to execute the previous command.

Fájlkeresés:

1. 
Például adott a következő fájlok:
mkdir data
cd data
touch file1.txt file2.log file_a.txt file_b.log report_2023.txt report_2024.log
touch image.jpg document.pdf archive.zip
mkdir dir1 dir2 dir3
cd ..

Ki akarjuk nyerni az összes olyan fájlt ahol a file és .log kiterjesztésű:
ls data/file?.log
Ez kilistázza: data/file2.log

2.
Using [] for character sets:
List files that start with report_ and have either 2023 or 2024 in their name:

ls data/report_[2][0][2][34].*
Output:
data/report_2023.txt  data/report_2024.log

3.
Using {} for brace expansion:
List files starting with file and ending with .txt or .log:
ls data/file*.{txt,log}
Output:
data/file1.txt  data/file2.log  data/file_a.txt  data/file_b.log

4. 
# Brace expansion
1.
Comma-separated list:
Create files report_jan.txt, report_feb.txt, report_mar.txt:
touch data/report_{jan,feb,mar}.txt
Output:
data/report_2023.txt  data/report_jan.txt  data/report_feb.txt  data/report_mar.txt

2.
Range of numbers or letters:
Create files doc1.txt, doc2.txt, doc3.txt:

5.
# Command Substitution
touch data/log_$(date +%Y-%m-%d).txt

6.
Single quotes (''): Prevent all shell expansion within the quotes.
Output:
The current date is $(date +%Y-%m-%d).

7.
Double quotes (""): Prevent most shell expansion, but allow variable expansion ($VAR) and command substitution ($()).

MY_DATE=$(date +%Y-%m-%d)
echo "Today's date is $MY_DATE."
Output:
Today's date is 2024-03-07.
