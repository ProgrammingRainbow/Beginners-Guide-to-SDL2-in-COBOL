       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEMO.

       DATA DIVISION.
       FILE SECTION.
       WORKING-STORAGE SECTION.
           77 hello-stdout PIC X(20) VALUE "Hello Standard".
           77 hello-stderr PIC X(20) VALUE "Hello Error".

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM PRINT-STDOUT.
           PERFORM PRINT-STDERR.

           STOP RUN.

       PRINT-STDOUT.
           DISPLAY hello-stdout END-DISPLAY.

           EXIT.

       PRINT-STDERR.
           DISPLAY hello-stderr UPON STDERR END-DISPLAY.

           EXIT.

       END PROGRAM DEMO.
