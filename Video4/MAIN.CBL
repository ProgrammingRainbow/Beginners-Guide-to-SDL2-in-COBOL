       IDENTIFICATION DIVISION.
       PROGRAM-ID. BACKGROUND.

       DATA DIVISION.
       FILE SECTION.
       WORKING-STORAGE SECTION.
           77 WINDOW_TITLE PIC X(20) VALUE Z"Background".
           77 WINDOW_WIDTH USAGE BINARY-INT VALUE 800.
           77 WINDOW_HEIGHT USAGE BINARY-INT VALUE 600.

           77 SDL_INIT_EVERYTHING USAGE UNSIGNED-INT VALUE 62001.
           77 IMG_INIT_PNG USAGE BINARY-INT VALUE 2.
           77 SDL_WINDOWPOS_CENTERED USAGE UNSIGNED-INT VALUE 805240832.

           77 SDL_QUIT USAGE BINARY-INT VALUE 256.
           77 SDL_KEYDOWN USAGE BINARY-INT VALUE 768.
           77 SDL_SCANCODE_ESCAPE USAGE BINARY-INT VALUE 41.

           77 error-ptr USAGE POINTER VALUE NULL.
           77 sdl-window USAGE POINTER VALUE NULL.
           77 sdl-renderer USAGE POINTER VALUE NULL.
           77 background USAGE POINTER VALUE NULL.

           77 playing USAGE BINARY-INT VALUE 1.
           77 return-value USAGE BINARY-INT VALUE 0.

           77 error-message PIC X(50).
           77 error-buff-len USAGE UNSIGNED-INT VALUE 1.
           01 error-buff BASED.
               05 error-buff-arr USAGE
                   BINARY-CHAR UNSIGNED OCCURS 512 TIMES. 

           01 sdl-event.
             05 sdl-event-default.
               10 sdl-event-type USAGE BINARY-INT UNSIGNED.
               10 FILLER USAGE BINARY-CHAR OCCURS 52 TIMES.
             05 keyboard-event REDEFINES sdl-event-default.
               10 keyboard-event-type USAGE BINARY-INT UNSIGNED.
               10 keyboard-event-timestamp USAGE BINARY-INT UNSIGNED.
               10 keyboard-event-windowID USAGE BINARY-INT UNSIGNED.
               10 keyboard-event-state USAGE BINARY-CHAR UNSIGNED.
               10 keyboard-event-repeat USAGE BINARY-CHAR UNSIGNED.
               10 keyboard-event-padding2 USAGE BINARY-CHAR UNSIGNED.
               10 keyboard-event-padding3 USAGE BINARY-CHAR UNSIGNED.
               10 keyboard-event-scancode USAGE BINARY-INT.
               10 keyboard-event-sym USAGE BINARY-INT.
               10 keyboard-event-mod USAGE BINARY-SHORT UNSIGNED.
               10 keyboard-event-unused USAGE BINARY-INT UNSIGNED.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM INITIALIZE-SDL.
           PERFORM LOAD-MEDIA.

           PERFORM UNTIL playing EQUALS 0
               PERFORM CHECK-INPUT
               PERFORM DRAW-ALL

               CALL "SDL_Delay" USING
                   BY VALUE 16
               END-CALL

           END-PERFORM.

       INITIALIZE-SDL.
           CALL "SDL_Init" USING
               BY VALUE SDL_INIT_EVERYTHING
               RETURNING return-value
           END-CALL.

           IF return-value NOT EQUALS 0 THEN
               MOVE "Error initializing SDL2" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "IMG_Init" USING
               BY VALUE IMG_INIT_PNG
               RETURNING return-value
           END-CALL.

           IF return-value NOT EQUAL IMG_INIT_PNG THEN
               MOVE "Error initializing SDL2_image" TO error-message
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

       LOAD-MEDIA.
           CALL "IMG_LoadTexture" USING
               BY VALUE SDL-RENDERER
               BY REFERENCE Z"images/background.png"
               RETURNING background
           END-CALL.

           IF background EQUALS NULL THEN
               MOVE "Error loading Texture" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           EXIT.

       CHECK-INPUT.
           PERFORM WITH TEST AFTER UNTIL return-value EQUALS 0
               CALL "SDL_PollEvent"
                  USING BY REFERENCE sdl-event
                  RETURNING return-value
               END-CALL
               EVALUATE sdl-event-type
                   WHEN SDL_QUIT
                      PERFORM CLEAN-AND-EXIT
                   WHEN SDL_KEYDOWN
                       EVALUATE keyboard-event-scancode
                           WHEN SDL_SCANCODE_ESCAPE
                               PERFORM CLEAN-AND-EXIT
                      END-EVALUATE
              END-EVALUATE
           END-PERFORM.

           EXIT.

       DRAW-ALL.
           CALL "SDL_RenderClear" USING
               BY VALUE sdl-renderer
               RETURNING return-value
           END-CALL

           CALL "SDL_RenderCopy" USING
               BY VALUE sdl-renderer
               BY VALUE background
               BY REFERENCE NULL
               BY REFERENCE NULL
               RETURNING return-value
           END-CALL.

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
           CALL "SDL_DestroyTexture" USING
               BY VALUE background
               RETURNING return-value
           END-CALL.
           SET background TO NULL.

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

           CALL "IMG_Quit"
               RETURNING return-value
           END-CALL.

           CALL "SDL_Quit"
               RETURNING return-value
           END-CALL.

           STOP RUN.

       END PROGRAM BACKGROUND.
