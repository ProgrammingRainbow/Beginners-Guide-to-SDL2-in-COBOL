       IDENTIFICATION DIVISION.
       PROGRAM-ID. OPEN-WINDOW.

       DATA DIVISION.
       FILE SECTION.
       WORKING-STORAGE SECTION.
           77 WINDOW_TITLE PIC X(20) VALUE Z"Open Window".
           77 WINDOW_WIDTH USAGE BINARY-INT VALUE 800.
           77 WINDOW_HEIGHT USAGE BINARY-INT VALUE 600.

           77 SDL_INIT_EVERYTHING USAGE UNSIGNED-INT VALUE 62001.
           77 SDL_WINDOWPOS_CENTERED USAGE UNSIGNED-INT VALUE 805240832.

           77 error-ptr USAGE POINTER VALUE NULL.
           77 sdl-window USAGE POINTER VALUE NULL.
           77 sdl-renderer USAGE POINTER VALUE NULL.

           77 return-value USAGE BINARY-INT VALUE 0.

           77 error-message PIC X(50).
           77 error-buff-len USAGE UNSIGNED-INT VALUE 1.
           01 error-buff BASED.
               05 error-buff-arr USAGE
                   BINARY-CHAR UNSIGNED OCCURS 512 TIMES. 

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM INITIALIZE-SDL.
           PERFORM DRAW-ALL.

           CALL "SDL_Delay" USING
               BY VALUE 5000
           END-CALL.

           PERFORM CLEAN-AND-EXIT.

       INITIALIZE-SDL.
           CALL "SDL_Init" USING
               BY VALUE SDL_INIT_EVERYTHING
               RETURNING return-value
           END-CALL.

           IF return-value NOT EQUALS 0 THEN
               MOVE "Error initializing SDL2" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "SDL_CreateWindow" USING
               BY CONTENT WINDOW_TITLE
               BY VALUE SDL_WINDOWPOS_CENTERED
               BY VALUE SDL_WINDOWPOS_CENTERED
               BY VALUE WINDOW_WIDTH
               BY VALUE WINDOW_HEIGHT
               BY VALUE 0
               RETURNING sdl-window
           END-CALL.

           IF sdl-window EQUALS NULL THEN
               MOVE "Error creating Window" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "SDL_CreateRenderer" USING
               BY VALUE sdl-window
               BY VALUE -1
               BY VALUE 0
               RETURNING sdl-renderer
           END-CALL.

           IF sdl-renderer EQUALS NULL THEN
               MOVE "Error creating Renderer" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           EXIT.

       DRAW-ALL.
           CALL "SDL_RenderClear" USING
               BY VALUE sdl-renderer
               RETURNING return-value
           END-CALL

           CALL "SDL_RenderPresent"
               USING BY VALUE sdl-renderer
               RETURNING return-value
           END-CALL.

           EXIT.

       PRINT-ERROR.
           CALL "SDL_GetError" 
               RETURNING error-ptr
           END-CALL.
           SET ADDRESS OF error-buff TO error-ptr.
           
           PERFORM VARYING error-buff-len FROM 1 BY 1
               UNTIL error-buff-arr(error-buff-len) = 0
               OR error-buff-len > 512
               CONTINUE
           END-PERFORM.

           DISPLAY FUNCTION TRIM(error-message) ": "
               error-buff(1:error-buff-len) UPON STDERR
           END-DISPLAY.

           PERFORM CLEAN-AND-EXIT.

       CLEAN-AND-EXIT.
           CALL "SDL_DestroyRenderer" USING
               BY VALUE sdl-renderer
               RETURNING return-value
           END-CALL.
           SET sdl-renderer TO NULL.

           CALL "SDL_DestroyWindow" USING
               BY VALUE sdl-window
               RETURNING return-value
           END-CALL.
           SET sdl-window TO NULL.

           CALL "SDL_Quit"
               RETURNING return-value
           END-CALL.

           STOP RUN.

       END PROGRAM OPEN-WINDOW.
